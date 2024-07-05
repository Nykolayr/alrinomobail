import 'dart:async';

import 'package:alrino/common/utils.dart';
import 'package:alrino/data/timer_bloc/timer_bloc.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/frd/table/enum_column_frd.dart';
import 'package:alrino/presentation/screens/frd/table/export_ecxel_frd.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:alrino/presentation/widgets/animation_clock.dart';
import 'package:alrino/presentation/widgets/buttons_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ColumnRightFrd extends StatefulWidget {
  final DataGridController dataGridcontroller;
  const ColumnRightFrd({required this.dataGridcontroller, Key? key})
      : super(key: key);

  @override
  State<ColumnRightFrd> createState() => _ColumnRightFrdState();
}

class _ColumnRightFrdState extends State<ColumnRightFrd>
    with TickerProviderStateMixin {
  late StreamSubscription<TimerState> subscription;
  UserRepository userRepo = Get.find<UserRepository>();
  bool isAudio = false;
  bool isTimer = true;
  FrdBloc bloc = Get.find<FrdBloc>();
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
    if (!bloc.state.isEdit) return;
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
    subscription = Get.find<TimerBloc>()
        .stream
        .listen((state) => bloc.add(AddTimerEvent(seconds: state.duration)));
  }

  /// останавливаем таймер
  void endTimer() async {
    Get.find<TimerBloc>().add(StopTimerEvent());
    subscription.cancel();
  }

  Future saveOperations() async {
    bloc.add(SaveFrdEvent());
  }

  Future saveFrd() async {
    bloc.add(SaveFrdEvent());
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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

                    if (bloc.state.frd.operations.isNotEmpty) {
                      Get.find<FrdRepository>()
                          .saveValuesFrd(bloc.state.frd.operations.last.name);
                      Get.find<FrdRepository>().tempFrd = bloc.state.frd;
                      Get.find<FrdRepository>().saveTempFrdToLocal();
                    }
                    startTimer();
                    bloc.add(AddOperationEvent());
                    await Future.delayed(const Duration(milliseconds: 50));
                    widget.dataGridcontroller.scrollToRow(
                        bloc.state.frd.operations.length.toDouble());
                    await Future.delayed(const Duration(milliseconds: 50));
                    bloc.add(AddEditCell(
                        indexRow: bloc.state.editRow - 1,
                        columnsData: ColumnsDataFrd.name));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedClock(controller: animationController),
                  ),
                ),
                ButtonsIconSvgFrd(
                  buttonIcon: ButtonIconSvg.redo,
                  onPressed: () async {
                    if (bloc.state.frd.operations.isEmpty) return;
                    bloc.add(RemoveFocusAllEvent());
                    widget.dataGridcontroller
                        .scrollToRow(bloc.state.frd.operations.length - 1);
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 100));
                    bloc.add(FocusLastEditEvent());
                  },
                ),
                ButtonsIconSvgFrd(
                    buttonIcon: ButtonIconSvg.info,
                    onPressed: () async {
                      await showInfoForExecutor(context, bloc.state.frd);
                    }),
                const Gap(20),
              ],
            ),
            ButtonsIconSvgFrd(
              buttonIcon: ButtonIconSvg.block,
              onPressed: () async {
                if (bloc.state.frd.operations.isEmpty) {
                  final isConfirmed = await showExitTableAlert(context);
                  if (context.mounted && isConfirmed == true) {
                    context.pop();
                  }
                  return;
                }

                if (animationController.isAnimating) {
                  final isConfirmed = await showEndTimerTableAlert(context);

                  if (isConfirmed == true) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    bloc.add(const AddTimeToLastEvent());
                    isTimer = false;
                    animationController.reset();
                    endTimer();
                    setState(() {});
                  }
                } else {
                  bloc.add(FocusHasEditEvent());
                  final isConfirmed = await showExitEditTableAlert(context);
                  if (isConfirmed == true) {
                    bloc.state.frd.operations.add(bloc.state.lastOperation);
                    exportDataGridToExcelFrd();
                    if (context.mounted) context.go('/main');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
