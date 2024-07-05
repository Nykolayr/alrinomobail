import 'dart:async';

import 'package:alrino/common/utils.dart';
import 'package:alrino/data/timer_bloc/timer_bloc.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/fhn/table/columns_fhn.dart';
import 'package:alrino/presentation/screens/fhn/table/export_ecxel_fhn.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:alrino/presentation/widgets/animation_clock.dart';
import 'package:alrino/presentation/widgets/buttons_icon.dart';
import 'package:alrino/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ColumnRightFhn extends StatefulWidget {
  final DataGridController dataGridcontroller;
  const ColumnRightFhn({required this.dataGridcontroller, Key? key})
      : super(key: key);

  @override
  State<ColumnRightFhn> createState() => _ColumnRightFhnState();
}

class _ColumnRightFhnState extends State<ColumnRightFhn>
    with TickerProviderStateMixin {
  late StreamSubscription<TimerState> subscription;
  UserRepository userRepo = Get.find<UserRepository>();
  bool isAudio = false;
  bool isTimer = true;
  FhnBloc bloc = Get.find<FhnBloc>();
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

  void endTimer() async {
    Get.find<TimerBloc>().add(StopTimerEvent());
    subscription.cancel();
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
        color: AppColor.greyFon,
        border: Border(
            top: BorderSide(
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
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (bloc.state.fhn.operations.isNotEmpty) {
                      Get.find<FhnRepository>()
                          .saveValuesfhn(bloc.state.fhn.operations.last.name);
                      Get.find<FhnRepository>().tempFhn = bloc.state.fhn;
                      Get.find<FhnRepository>().saveAll();
                    }
                    startTimer();
                    bloc.add(AddOperationEvent());
                    await Future.delayed(const Duration(milliseconds: 50));
                    widget.dataGridcontroller.scrollToRow(
                        bloc.state.fhn.operations.length.toDouble());
                    await Future.delayed(const Duration(milliseconds: 50));
                    bloc.add(AddEditCell(
                        indexRow: bloc.state.editRow - 1,
                        columnsData: ColumnsDataFhn.name));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedClock(controller: animationController),
                  ),
                ),
                ButtonsIconSvgFhn(
                  buttonIcon: ButtonIconSvg.delete,
                  onPressed: () async {
                    if (bloc.state.fhn.operations.isEmpty) return;
                    String name = bloc.state.editColumn.label;
                    int index = bloc.state.fhn.addColumns
                        .indexWhere((e) => e.name == name);
                    if (index == -1) return;
                    bool? isDelete = await deleteColumnAlert(name);
                    if (isDelete != null && isDelete) {
                      bloc.add(RemoveColumnTableEvent(index: index));
                      bloc.add(SavePatternEvent());
                    }
                  },
                ),
                ButtonsIconSvgFhn(
                  buttonIcon: ButtonIconSvg.plus,
                  onPressed: () async {
                    String? name = await addColumnAlert();
                    if (name.isNotEmpty) {
                      bloc.add(AddColumnTableEvent(name: name));
                      bloc.add(SavePatternEvent());
                    }
                  },
                ),
                ButtonsIconSvgFhn(
                  buttonIcon: ButtonIconSvg.redo,
                  onPressed: () async {
                    if (bloc.state.fhn.operations.isEmpty) return;
                    bloc.add(RemoveFocusAllEvent());
                    widget.dataGridcontroller
                        .scrollToRow(bloc.state.fhn.operations.length - 1);
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 100));
                    bloc.add(FocusLastEditEvent());
                  },
                ),
                ButtonsIconSvgFrd(
                    buttonIcon: ButtonIconSvg.info,
                    onPressed: () async {
                      await showInfoForExecutor(context, bloc.state.fhn);
                    }),
              ],
            ),
            ButtonsIconSvgFhn(
              isSmall: false,
              buttonIcon: ButtonIconSvg.block,
              onPressed: () async {
                if (bloc.state.fhn.operations.isEmpty) {
                  final isConfirmed = await showExitTableAlert(context);
                  if (context.mounted && isConfirmed == true) {
                    context.pop();
                  }
                  return;
                }
                if (animationController.isAnimating) {
                  final isConfirmed = await showEndTimerTableAlert(context);
                  if (isConfirmed == true) {
                    isTimer = false;
                    animationController.reset();
                    endTimer();
                    bloc.add(const AddTimeToLastEvent());
                    setState(() {});
                  }
                } else {
                  final isConfirmed = await showExitEditTableAlert(context);
                  if (isConfirmed == true) {
                    bloc.state.fhn.operations.add(bloc.state.lastOperation);
                    await exportDataGridToExcelFhn();
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

  /// Алерт для добавления имени столбца
  Future<String> addColumnAlert() async {
    TextEditingController controller = TextEditingController();
    await showModalWideContent(
        context,
        '',
        AlrinoFormField(
          autoFocus: true,
          controller: controller,
          hint: 'Наименование столбца',
          keyboardType: TextInputType.name,
        ), () {
      controller.text = '';
      Navigator.of(context).pop();
    }, () {
      if (controller.text.isNotEmpty) {
        Navigator.of(context).pop();
      }
    });
    return controller.text;
  }

  /// Алерт для удаления столбца
  Future<bool?> deleteColumnAlert(String name) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertSelf(
            text: 'Внимание!',
            subText: 'Вы уверены, что хотите удалить столбец "$name"?');
      },
    );
  }
}
