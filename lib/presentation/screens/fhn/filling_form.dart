import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/fhn/pattern_fhn.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/process.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/presentation/screens/fhn/bloc/fhn_bloc.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/autocomplit_field.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:alrino/presentation/widgets/text_field.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Страница для заполнения реквизитов после выбора шаблона для ФХН
class FillingFormFhnPage extends StatefulWidget {
  const FillingFormFhnPage({super.key});

  @override
  State<FillingFormFhnPage> createState() => _FillingFormFhnPageState();
}

class _FillingFormFhnPageState extends State<FillingFormFhnPage> {
  Key key = GlobalKey();
  List<Organisation> orgs = Get.find<MainRepository>().orgs;
  List<String> orgNames = Get.find<MainRepository>().orgNames;
  List<String> divNames = [];
  PatternFhn tempPattern = Get.find<FhnRepository>().tempPattern;
  late TextEditingController dataReqController;
  late TextEditingController orgController;
  late TextEditingController divController;
  late TextEditingController dateController;
  late TextEditingController operatingController;
  late TextEditingController fioController;
  late TextEditingController postController;
  late TextEditingController experienceController;
  TextEditingController phoneController = TextEditingController();
  List<TextEditingController> textEditingControllers = [];

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

  /// добавляем реквизитное поле
  void addTextFormField(String name) {
    final textEditingController = TextEditingController();
    textEditingControllers.add(textEditingController);
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    dataReqController = TextEditingController();
    orgController = TextEditingController();
    divController = TextEditingController();
    dateController =
        TextEditingController(text: Utils.getFormatDate(DateTime.now()));
    operatingController = TextEditingController();
    postController = TextEditingController();
    fioController = TextEditingController();
    postController = TextEditingController();
    experienceController = TextEditingController();
    phoneController.addListener(() => formatPhoneNumber(phoneController));
    // ignore: unused_local_variable
    for (var requisite in tempPattern.requisites) {
      addTextFormField(requisite.name);
    }
    super.initState();
  }

  @override
  dispose() {
    orgController.dispose();
    divController.dispose();
    dateController.dispose();
    operatingController.dispose();
    fioController.dispose();
    postController.dispose();
    experienceController.dispose();
    phoneController.dispose();
    phoneController.removeListener(() => formatPhoneNumber(phoneController));
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
                appBar: const AppBars(title: 'Заполнение реквизитов'),
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
                              const Gap(20),
                              Text('Шаблон  ${tempPattern.name}',
                                  style: AppText.title20,
                                  textAlign: TextAlign.center),
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
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите название проекта'),
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
                                validator: (value) => Utils.validateNotEmpty(
                                    value, 'Введите стаж'),
                                keyboardType: TextInputType.number,
                                isTitle: true,
                              ),
                              AlrinoFormField(
                                controller: phoneController,
                                hint: 'Контактный номер телефона',
                                validator: (value) =>
                                    Utils.validatePhone(value),
                                keyboardType: TextInputType.phone,
                                isTitle: true,
                              ),
                              if (tempPattern.requisites.isNotEmpty) ...[
                                for (int k = 0;
                                    k < tempPattern.requisites.length;
                                    k++)
                                  AlrinoFormField(
                                    controller: textEditingControllers[k],
                                    hint: tempPattern.requisites[k].name,
                                    onChanged: (value) => () {},
                                    validator: (value) => Utils.validateNotEmpty(
                                        value,
                                        'Введите реквизит ${tempPattern.requisites[k].name}'),
                                    keyboardType: TextInputType.name,
                                    isTitle: true,
                                    title: tempPattern.requisites[k].name,
                                  ),
                              ],
                              const Gap(40),
                              Buttons.button180(
                                  onPressed: () {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    if (formKey.currentState!.validate()) {
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
                                      tempPattern.org = orgController.text;
                                      tempPattern.division = divController.text;
                                      tempPattern.date =
                                          DateFormat("dd.MM.yyyy")
                                              .parse(dateController.text);
                                      tempPattern.operating =
                                          operatingController.text;
                                      tempPattern.fio = fioController.text;
                                      tempPattern.post = postController.text;
                                      tempPattern.experience =
                                          int.parse(experienceController.text);
                                      tempPattern.phone =
                                          Utils.formatPhoneNumberToPlain(
                                              phoneController.text);
                                      for (int k = 0;
                                          k < tempPattern.requisites.length;
                                          k++) {
                                        tempPattern.requisites[k].value =
                                            textEditingControllers[k].text;
                                      }
                                      Get.find<FhnRepository>()
                                          .patternToFhn(tempPattern);
                                      bloc.add(NewOperationsEvent());
                                      context.goNamed('Таблица ФХН');
                                    }
                                  },
                                  text: 'Перейти далее'),
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
}
