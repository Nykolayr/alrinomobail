import 'dart:async';

import 'package:alrino/common/constants.dart';
import 'package:alrino/common/utils.dart';
import 'package:alrino/data/timer_bloc/timer_bloc.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/main.dart';
import 'package:alrino/presentation/screens/sz/bloc/sz_bloc.dart';
import 'package:alrino/presentation/screens/sz/table/columns_sz.dart';
import 'package:alrino/presentation/screens/sz/table/export_excel_sz.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:alrino/presentation/widgets/animation_clock.dart';
import 'package:alrino/presentation/widgets/buttons_icon.dart';
import 'package:alrino/presentation/widgets/switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:workmanager/workmanager.dart';

class ColumnRightSz extends StatefulWidget {
  final DataGridController dataGridcontroller;
  const ColumnRightSz({required this.dataGridcontroller, Key? key})
      : super(key: key);

  @override
  State<ColumnRightSz> createState() => _ColumnRightSzState();
}

class _ColumnRightSzState extends State<ColumnRightSz>
    with TickerProviderStateMixin {
  bool isTimeAlert = false; // когда вызван алерт о продлении работы
  late StreamSubscription<TimerState> subscription;
  UserRepository userRepo = Get.find<UserRepository>();
  bool isAudio = false; // микрофон включен
  bool isTimer = true; // таймер запускается
  bool isEndWork = false; // через 15 минут завершить рабочий день
  bool isGlobalTimer =
      false; // глобальный таймер для запуска системного таймера
  SzBloc bloc = Get.find<SzBloc>();
  late stt.SpeechToText speech;
  late AnimationController animationController;
  bool isHasAudioPermission =
      false; // переменная для  разрешения на использование микрофона
  bool isHasFilePermission =
      false; // переменная для разрешения для записи файлов
  /// инициализируем аудио
  void initializeSpeechToText() async {
    isHasAudioPermission = userRepo.user.isPermissonAudio;
    if (!isHasAudioPermission) return;
    speech = stt.SpeechToText();
    await speech.initialize();
    if (!speech.isAvailable) {
      Logger.e('Speech recognition is not available');
      return;
    }
    if (!isHasAudioPermission) {
      Logger.e('Speech recognition permission not granted');
      return;
    }
  }

  void stopAudio() {
    if (!bloc.state.isAudio) return;
    speech.stop();
    bloc.add(const AudioEditEvent(isAudio: false));
  }

  /// Старт прослушивания аудио
  void startAudio() async {
    if (!bloc.state.isEdit || bloc.state.editColumn == ColumnsDataSz.org) {
      return;
    }
    if (speech.isAvailable && isHasAudioPermission) {
      bloc.add(const AudioEditEvent(isAudio: true));
      await Future.delayed(const Duration(milliseconds: 200));
      speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            String text = result.recognizedWords;
            if (bloc.state.editController.text.isNotEmpty) {
              bloc.state.editController.text += ' $text ';
            } else {
              if (text.isNotEmpty) {
                bloc.state.editController.text = Utils.capitalizeText(text);
              }
            }

            await endRecord();
          }
        },
      );
    } else {
      Logger.e('Speech recognition not initialized or permission not granted');
    }
    speech.errorListener = (error) {
      Logger.e('Speech recognition error: $error');
    };
    speech.statusListener = (status) async {
      if (status == 'notListening' || status == 'done') {
        stopAudio();
      }
    };
  }

  /// окончание записи
  Future endRecord() async {
    await Future.delayed(const Duration(milliseconds: 150));
    bloc.add(FocusHasEditEvent());
  }

  /// Запускаем таймер
  void startTimer() async {
    Get.find<TimerBloc>().add(StartTimerEvent());
    if (isGlobalTimer) {
      subscription.cancel();
    }
    subscription = Get.find<TimerBloc>()
        .stream
        .listen((state) => bloc.add(AddTimerEvent(seconds: state.duration)));
    if (!isGlobalTimer) {
      // создаем первый глобальный таймер для вывода из фона
      Workmanager().registerOneOffTask(
        "firstWork",
        "firstWork",
        tag: "firstWork",
        initialDelay: allTimerConst,
      );
      // создаем глобальный таймер для вывода из фона для закрытия таблицы
      Workmanager().registerOneOffTask(
        "endWork",
        "endWork",
        tag: "endWork",
        initialDelay: maxTimerConst,
      );
    }
    isGlobalTimer = true;
  }

  void endTimer() async {
    Get.find<TimerBloc>().add(StopTimerEvent());
    subscription.cancel();
  }

  Future saveOperations() async {
    bloc.add(NewSzEvent());
  }

  Future saveFrd() async {
    bloc.add(NewSzEvent());
  }

  @override
  initState() {
    isHasFilePermission = userRepo.user.isPermissonFile;
    initializeSpeechToText();
    animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    super.initState();
  }

  /// окончание работы с таблицей
  Future endWorkTable() async {
    // showNotification();
    endTimer();
    bloc.state.sz.operations.add(bloc.state.lastOperation);
    Get.find<FrdRepository>().tempSz = bloc.state.sz;
    bloc.add(FocusHasEditEvent());
    await exportDataGridToExcelSz();
    Workmanager().cancelAll();
    // ignore: use_build_context_synchronously
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/main');
    }
  }

  /// Отобразить алерт о продлении работы
  Future showAlertEndWork() async {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.sentMessage,
      looping: false,
      volume: 1,
    );
    showNotification();
    isTimeAlert = true;
    isEndWork = true;
    bloc.add(const AddDurationEvent(duration: workTimerExternal));
    Workmanager().registerOneOffTask(
      "external",
      "external",
      tag: "external",
      initialDelay: workTimerExternal,
    );
    Workmanager().registerOneOffTask(
      "workTimerhour",
      "workTimerhour",
      tag: "workTimerhour",
      initialDelay: workTimerhour + workTimerExternal,
    );
    final bool? isConfirmed =
        await showEndTime(context, bloc.state.sz.workTime);
    if (isConfirmed != null && !isConfirmed) {
      bloc.add(const AddDurationEvent(duration: workTimerhour));
      Workmanager().cancelByTag("external");
      isEndWork = false;
    }
    isTimeAlert = false;
  }

  @override
  void dispose() {
    animationController.dispose();
    if (isGlobalTimer) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SzBloc, SzState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          if (previous.isTimer != current.isTimer && current.isTimer) {
            if (isEndWork) {
              endWorkTable();
            } else {
              if (!isTimeAlert) showAlertEndWork();
            }
          }
          if (previous.isEndTimer != current.isEndTimer && current.isEndTimer) {
            endWorkTable();
          }
          return true;
        },
        builder: (context, state) {
          return Container(
            width: 80,
            decoration: const BoxDecoration(
              color: AppColor.white,
              border: Border(
                  left: BorderSide(
                color: AppColor.grey,
                width: 1.0,
              )),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      if (isHasAudioPermission)
                        ButtonsIcon(
                            buttonIcon: bloc.state.isAudio
                                ? ButtonIcon.micOff
                                : ButtonIcon.micOn,
                            onPressed: () {
                              if (bloc.state.isAudio) {
                                stopAudio();
                              } else {
                                startAudio();
                              }
                            }),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (!isTimer) return;
                          bloc.add(RemoveFocusAllEvent());
                          animationController.reset();
                          animationController.repeat();
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          if (bloc.state.sz.operations.isNotEmpty) {
                            Get.find<FrdRepository>().tempSz = bloc.state.sz;
                            Get.find<FrdRepository>().saveSzToLocal();
                          }
                          startTimer();
                          bloc.add(AddOperationEvent());
                          await Future.delayed(
                              const Duration(milliseconds: 50));
                          widget.dataGridcontroller.scrollToRow(
                              bloc.state.sz.operations.length.toDouble());
                          await Future.delayed(
                              const Duration(milliseconds: 50));
                          bloc.add(AddEditCell(
                              indexRow: bloc.state.editRow - 1,
                              columnsData: ColumnsDataSz.org));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: AnimatedClock(controller: animationController),
                        ),
                      ),
                      const Gap(15),
                      ButtonsIconSvgFrd(
                        buttonIcon: ButtonIconSvg.redo,
                        onPressed: () async {
                          if (bloc.state.sz.operations.isEmpty) return;
                          bloc.add(RemoveFocusAllEvent());
                          widget.dataGridcontroller
                              .scrollToRow(bloc.state.sz.operations.length - 1);
                          setState(() {});
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          bloc.add(FocusLastEditEvent());
                        },
                      ),
                      setOuter(),
                    ],
                  ),
                  ButtonsIconSvgFrd(
                    buttonIcon: ButtonIconSvg.block,
                    onPressed: () async {
                      if (bloc.state.sz.operations.isEmpty) {
                        final isConfirmed = await showExitTableAlert(context);
                        if (context.mounted && isConfirmed == true) {
                          context.pop();
                        }
                        return;
                      }

                      if (animationController.isAnimating) {
                        final isConfirmed =
                            await showEndTimerTableAlert(context);
                        if (isConfirmed == true) {
                          isTimer = false;
                          animationController.reset();
                          endTimer();
                          bloc.add(const AddTimeToLastEvent());
                          setState(() {});
                        }
                      } else {
                        final isConfirmed =
                            await showExitEditTableAlert(context);
                        if (isConfirmed == true) {
                          await endWorkTable();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget setOuter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Column(
        children: [
          const Text('На выезде', style: AppText.table10),
          SwitchAlrino(
              value: bloc.state.sz.isOuter,
              onChanged: (value) {
                bloc.add(SetIsOuterEvent());
              }),
        ],
      ),
    );
  }
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(
    subtitle: 'Нажмите, чтобы открыть приложение',
  );
  const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails, iOS: iosNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      0,
      'Приложение Алрино требует внимание',
      'Нажмите, чтобы открыть приложение',
      notificationDetails,
      payload: 'item x');
}
