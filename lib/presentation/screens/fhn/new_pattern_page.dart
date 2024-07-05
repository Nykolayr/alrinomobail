import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/domain/models/fhn/pattern_fhn.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/process.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/fhn/widgets.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/autocomplit_field.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:alrino/presentation/widgets/text_field.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Страница для создания и редактирования шаблона для ФХН
class NewPatternFhnPage extends StatefulWidget {
  final bool isEdit;
  const NewPatternFhnPage({required this.isEdit, super.key});

  @override
  State<NewPatternFhnPage> createState() => _NewPatternFhnPageState();
}

class _NewPatternFhnPageState extends State<NewPatternFhnPage> {
  Key key = GlobalKey();
  List<Organisation> orgs = Get.find<MainRepository>().orgs;
  List<String> orgNames = Get.find<MainRepository>().orgNames;
  List<String> divNames = [];
  Fhn tempFhn = Get.find<FhnRepository>().tempFhn;
  PatternFhn tempPattern = Get.find<FhnRepository>().tempPattern;
  late TextEditingController nameReqController;
  late TextEditingController dataReqController;
  late TextEditingController nameController;
  late TextEditingController orgController;
  late TextEditingController divController;
  late TextEditingController dateController;
  late TextEditingController operatingController;
  late TextEditingController fioController;
  late TextEditingController postController;
  late TextEditingController experienceController;
  TextEditingController phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final reqKey = GlobalKey<FormState>();
  FhnBloc bloc = Get.find<FhnBloc>();
  Key keyProcess = GlobalKey();
  TextEditingController activityController = TextEditingController();
  TextEditingController directionController = TextEditingController();
  List<String> activityNames = Get.find<MainRepository>().activityNames;
  List<Process> processes = Get.find<MainRepository>().process;
  List<String> directions = [];
  bool isProcess = Get.find<MainBloc>().state.isProcess;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    nameReqController = TextEditingController();
    dataReqController = TextEditingController();
    nameController = TextEditingController(text: tempPattern.name);
    orgController = TextEditingController(text: tempPattern.org);
    divController = TextEditingController(text: tempPattern.division);
    dateController =
        TextEditingController(text: Utils.getFormatDate(tempPattern.date));
    operatingController = TextEditingController(text: tempPattern.operating);
    postController = TextEditingController(text: tempPattern.post);
    fioController = TextEditingController(text: tempPattern.fio);
    postController = TextEditingController(text: tempPattern.post);
    experienceController = TextEditingController();
    phoneController.addListener(() => formatPhoneNumber(phoneController));
    super.initState();
  }

  @override
  dispose() {
    nameController.dispose();
    orgController.dispose();
    divController.dispose();
    dateController.dispose();
    operatingController.dispose();
    fioController.dispose();
    postController.dispose();
    experienceController.dispose();
    phoneController.dispose();
    phoneController.removeListener(() => formatPhoneNumber(phoneController));
    nameReqController.dispose();
    activityController.dispose();
    directionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FhnBloc, FhnState>(
        bloc: bloc,
        builder: (context, state) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: AppColor.white,
                appBar: AppBars(
                    title: widget.isEdit
                        ? 'Редактирование шаблона'
                        : 'Создание нового шаблона'),
                body: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    const FonPicture(),
                    SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width: double.infinity,
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Gap(30),
                              GestureDetector(
                                onTap: () async {
                                  await editName(context, nameController);
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(nameController.text,
                                        style: AppText.title20),
                                    const Gap(15),
                                    SvgPicture.asset('assets/svg/edit.svg',
                                        height: 20),
                                  ],
                                ),
                              ),
                              const Gap(20),
                              AutoComplitFormField(
                                suggestions: orgNames,
                                controller: orgController,
                                hint: 'Название проекта',
                                updateSuggestions: (value) {
                                  value = value.trim().split('_')[0];
                                  if (orgs.any(
                                      (element) => element.name == value)) {
                                    divController.clear();
                                    setState(() {
                                      divNames = orgs
                                          .firstWhere((element) =>
                                              element.name == value)
                                          .divNames;
                                      key = GlobalKey();
                                    });
                                  }
                                },
                                validator: (value) => Utils.validateOrg(value),
                                keyboardType: TextInputType.name,
                                isTitle: true,
                              ),
                              AutoComplitFormField(
                                key: key,
                                suggestions: divNames,
                                controller: divController,
                                hint: 'Структурное подразделение',
                                onChanged: (value) => () {},
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите cтруктурное подразделение'),
                                keyboardType: TextInputType.name,
                                isTitle: true,
                              ),
                              if (isProcess) ...[
                                AutoComplitFormField(
                                  suggestions: activityNames,
                                  controller: activityController,
                                  hint: 'Вид деятельности',
                                  updateSuggestions: (value) {
                                    value = value.trim().split('_')[0];
                                    if (processes.any((element) =>
                                        element.activity == value)) {
                                      directionController.clear();
                                      setState(() {
                                        directions = [];
                                        List<Process> filteredProcesses =
                                            processes
                                                .where((process) =>
                                                    process.activity == value)
                                                .toList();
                                        directions = filteredProcesses
                                            .map((e) => e.direction)
                                            .toSet()
                                            .toList();
                                        key = GlobalKey();
                                      });
                                    }
                                  },
                                  validator: (value) =>
                                      Utils.validateActivity(value),
                                  keyboardType: TextInputType.name,
                                  isTitle: true,
                                ),
                                AutoComplitFormField(
                                  key: keyProcess,
                                  suggestions: directions,
                                  controller: directionController,
                                  hint: 'Направление',
                                  onChanged: (value) => () {},
                                  validator: (value) => Utils.validateDirection(
                                      value, directions),
                                  keyboardType: TextInputType.name,
                                  isTitle: true,
                                ),
                              ],
                              AlrinoFormField(
                                readOnly: true,
                                controller: dateController,
                                hint: 'Дата наблюдения',
                                onTap: () async {
                                  List<DateTime?>? results =
                                      await showCalendarDatePicker2Dialog(
                                    context: context,
                                    config:
                                        CalendarDatePicker2WithActionButtonsConfig(),
                                    dialogSize: const Size(325, 400),
                                    // value: _dates,
                                    borderRadius: BorderRadius.circular(15),
                                  );
                                  if (results != null &&
                                      results.first != null) {
                                    dateController.text =
                                        Utils.getFormatDate(results.first!);
                                  }
                                },
                                isTitle: true,
                              ),
                              AlrinoFormField(
                                controller: operatingController,
                                hint: 'Режим работы, смена',
                                onChanged: (value) => () {},
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите режим работы, смены'),
                                keyboardType: TextInputType.name,
                                isTitle: true,
                              ),
                              AlrinoFormField(
                                controller: fioController,
                                hint: 'ФИО исполнителя(-ей)',
                                onChanged: (value) => () {},
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите ФИО'),
                                keyboardType: TextInputType.name,
                                isTitle: true,
                              ),
                              AlrinoFormField(
                                controller: postController,
                                hint: 'Должность (профессия) исполнителя(-ей)',
                                onChanged: (value) => () {},
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите должность'),
                                keyboardType: TextInputType.name,
                                isTitle: true,
                              ),
                              AlrinoFormField(
                                controller: experienceController,
                                hint:
                                    'Стаж (полных лет, по занимаемой профессии)',
                                onChanged: (value) => () {},
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите стаж'),
                                keyboardType: TextInputType.number,
                                isTitle: true,
                              ),
                              AlrinoFormField(
                                controller: phoneController,
                                hint: 'Контактный номер телефона',
                                onChanged: (value) => () {},
                                validator: (value) =>
                                    Utils.validatePhone(value),
                                keyboardType: TextInputType.phone,
                                isTitle: true,
                              ),
                              const Gap(15),
                              const Divider(thickness: 1.5),
                              Center(
                                  child: Text('Реквизиты',
                                      style: AppText.text14
                                          .copyWith(fontSize: 18))),
                              if (tempPattern.requisites.isEmpty) ...[
                                const Gap(10),
                                const Text('У Вас нет реквизитов',
                                    style: AppText.text14),
                              ],
                              if (tempPattern.requisites.isNotEmpty) ...[
                                for (var item in tempPattern.requisites)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: RequisiteItem(requisite: item),
                                      ),
                                      if (widget.isEdit) const Gap(5),
                                      if (widget.isEdit)
                                        getIconButton(
                                          'assets/svg/edit.svg',
                                          onTap: () async {
                                            await addRequisit(context, item,
                                                isEdit: true);
                                            setState(() {});
                                          },
                                        ),
                                      if (widget.isEdit)
                                        getIconButton('assets/svg/trash.svg',
                                            onTap: () async {
                                          bool? isDelete =
                                              await deletePatternAlert(
                                                  item.name,
                                                  'реквизит',
                                                  context);
                                          if (isDelete != null && isDelete) {
                                            tempPattern.requisites.remove(item);
                                            setState(() {});
                                          }
                                        }, isRed: true),
                                    ],
                                  ),
                              ],
                              if (tempPattern.requisites.length < 5) ...[
                                const Gap(35),
                                Buttons.button280(
                                    onPressed: () async {
                                      await addRequisit(
                                          context, Requisite.initial());
                                      setState(() {});
                                    },
                                    text: 'Добавить новый реквизит'),
                              ],
                              const Gap(15),
                              const Divider(thickness: 1.5),
                              Center(
                                  child: Text('Добавленные столбцы',
                                      style: AppText.text14
                                          .copyWith(fontSize: 18))),
                              if (tempPattern.addColumns.isEmpty) ...[
                                const Gap(10),
                                const Text('У Вас нет добавленных столбцов',
                                    style: AppText.text14),
                              ],
                              if (tempPattern.addColumns.isNotEmpty) ...[
                                for (var item in tempPattern.addColumns)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (!widget.isEdit) {
                                              String newName =
                                                  await editColumnAlert(
                                                context,
                                                item.name,
                                              );
                                              if (newName.isNotEmpty) {
                                                item.name = newName;
                                              }
                                              setState(() {});
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Text(
                                              item.name,
                                              style: AppText.text14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (widget.isEdit) const Gap(5),
                                      if (widget.isEdit)
                                        getIconButton(
                                          'assets/svg/edit.svg',
                                          onTap: () async {
                                            String newName =
                                                await editColumnAlert(
                                              context,
                                              item.name,
                                            );
                                            if (newName.isNotEmpty) {
                                              item.name = newName;
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      if (widget.isEdit)
                                        getIconButton('assets/svg/trash.svg',
                                            onTap: () async {
                                          bool? isDelete =
                                              await deletePatternAlert(
                                                  item.name,
                                                  'столбец',
                                                  context);
                                          if (isDelete != null && isDelete) {
                                            tempPattern.addColumns.remove(item);
                                            setState(() {});
                                          }
                                        }, isRed: true),
                                    ],
                                  ),
                              ],
                              if (tempPattern.addColumns.length < 6) ...[
                                const Gap(35),
                                Buttons.button280(
                                    onPressed: () async {
                                      String newName = await editColumnAlert(
                                        context,
                                        '',
                                      );
                                      if (newName.isNotEmpty) {
                                        tempPattern.addColumns.add(AddColumns(
                                          id: tempPattern.addColumns.length + 1,
                                          name: newName,
                                          value: '',
                                        ));
                                      }
                                      setState(() {});
                                    },
                                    text: 'Добавить новый столбец'),
                              ],
                              const Gap(15),
                              const Divider(thickness: 1.5),
                              const Gap(40),
                              Buttons.button180(
                                  onPressed: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    bool isValidate = true;
                                    if (!widget.isEdit) {
                                      isValidate =
                                          formKey.currentState!.validate();
                                    }
                                    if (isValidate) {
                                      if (isProcess) {
                                        List<Process> filteredProcesses =
                                            processes
                                                .where((process) =>
                                                    process.direction ==
                                                    directionController.text)
                                                .toSet()
                                                .toList();
                                        Get.find<FhnRepository>().valuesFhn =
                                            filteredProcesses
                                                .map((e) => e.operation)
                                                .toSet()
                                                .toList();
                                        Get.find<FhnRepository>()
                                                .operationsFhn =
                                            filteredProcesses
                                                .map((e) => e.operation)
                                                .toSet()
                                                .toList();
                                      }
                                      tempPattern.name = nameController.text;
                                      tempPattern.org = orgController.text;
                                      tempPattern.division = divController.text;
                                      tempPattern.date =
                                          DateFormat("dd.MM.yyyy")
                                              .parse(dateController.text);
                                      tempPattern.operating =
                                          operatingController.text;
                                      tempPattern.fio = fioController.text;
                                      tempPattern.post = postController.text;
                                      if (experienceController
                                          .text.isNotEmpty) {
                                        tempPattern.experience = int.parse(
                                            experienceController.text);
                                      }
                                      tempPattern.phone =
                                          Utils.formatPhoneNumberToPlain(
                                              phoneController.text);

                                      if (widget.isEdit) {
                                        int id = Get.find<FhnRepository>()
                                            .patternsFhn
                                            .indexWhere((element) =>
                                                element.id == tempPattern.id);
                                        Get.find<FhnRepository>()
                                            .patternsFhn[id] = tempPattern;
                                        Get.find<FhnRepository>()
                                            .savePatternToApi();
                                        context.pop();
                                      } else {
                                        // tempPattern.addColumns.clear();
                                        Get.find<FhnRepository>()
                                            .saveTempPattern();
                                        Get.find<FhnRepository>()
                                            .patternToFhn(tempPattern);
                                        bloc.add(NewOperationsEvent());
                                        await Future.delayed(
                                            const Duration(milliseconds: 100));
                                        if (context.mounted) {
                                          context.goNamed('Таблица ФХН');
                                        }
                                      }
                                    }
                                  },
                                  text: widget.isEdit
                                      ? 'Сохранить'
                                      : 'Перейти далее'),
                              const Gap(25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator.adaptive())
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// Алерт для добавления и редактирования имени столбца
  Future<String> editColumnAlert(BuildContext context, String name) async {
    TextEditingController controller = TextEditingController();
    controller.text = name;
    await showModalContent(
        context,
        name.isNotEmpty ? 'Редактирование столбца' : 'Добавление столбца',
        AlrinoFormField(
          autoFocus: true,
          controller: controller,
          hint: 'Наименование столбца',
          keyboardType: TextInputType.name,
        ), () {
      controller.text = name;
      Navigator.of(context).pop();
    }, () {
      if (controller.text.isNotEmpty) {
        Navigator.of(context).pop();
      }
    });
    return controller.text;
  }

  /// Алерт для удаления столбца
  Future<bool?> deleteColumnAlert(BuildContext context, String name) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertSelf(
            text: 'Внимание!',
            subText: 'Вы уверены, что хотите удалить столбец "$name"?');
      },
    );
  }

  Future<void> addRequisit(BuildContext context, Requisite requisit,
      {isEdit = false}) async {
    nameReqController.text = requisit.name;
    dataReqController.text = requisit.value;

    return showModalContent(
        context,
        isEdit ? 'Редактирование реквизита' : 'Добавление реквизита',
        Form(
          key: reqKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AlrinoFormField(
                autoFocus: true,
                controller: nameReqController,
                hint: 'Наименование реквизита',
                validator: (value) => Utils.validateNotEmpty(
                    value, 'Введите наименование реквизита'),
                keyboardType: TextInputType.name,
                isTitle: true,
              ),
              AlrinoFormField(
                controller: dataReqController,
                hint: 'Значение реквизита',
                validator: (value) =>
                    Utils.validateNotEmpty(value, 'Введите значение реквизита'),
                keyboardType: TextInputType.name,
                isTitle: true,
              ),
            ],
          ),
        ),
        () => Navigator.of(context).pop(false), () {
      if (reqKey.currentState!.validate()) {
        requisit.name = nameReqController.text;
        requisit.value = dataReqController.text;
        if (!isEdit) {
          requisit.id = tempPattern.requisites.length + 1;
          tempPattern.requisites.add(requisit);
        }
        Navigator.of(context).pop(false);
      }
    });
  }

  Future<void> editName(
      BuildContext context, TextEditingController controller) async {
    String text = controller.text;
    return showModalContent(
        context,
        'Редактирование наименования шаблона',
        AlrinoFormField(
          autoFocus: true,
          controller: controller,
          hint: 'Наименование шаблона',
          onChanged: (value) => () {},
          keyboardType: TextInputType.name,
        ), () {
      controller.text = text;
      Navigator.of(context).pop(false);
    }, () {
      if (controller.text.isEmpty) controller.text = text;
      Navigator.of(context).pop(false);
    });
  }
}
