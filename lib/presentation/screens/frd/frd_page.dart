import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/models/frd/frd.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/process.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/presentation/screens/frd/bloc/frd_bloc.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/theme/colors.dart';
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

/// Страница предварительного ввода информации для ФРД
class FrdPage extends StatefulWidget {
  const FrdPage({Key? key}) : super(key: key);

  @override
  State<FrdPage> createState() => _FrdPageState();
}

class _FrdPageState extends State<FrdPage> {
  Key key = GlobalKey();
  List<Organisation> orgs = Get.find<MainRepository>().orgs;
  List<String> orgNames = Get.find<MainRepository>().orgNames;
  List<String> divNames = [];
  Frd tempFrd = Frd.initial();

  TextEditingController divController = TextEditingController();
  TextEditingController orgController = TextEditingController();

  late TextEditingController dateController = TextEditingController();
  TextEditingController operatingController = TextEditingController();
  TextEditingController fioController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  FrdBloc bloc = Get.find<FrdBloc>();
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
    dateController =
        TextEditingController(text: Utils.getFormatDate(tempFrd.date));
    phoneController.addListener(() => formatPhoneNumber(phoneController));
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
    activityController.dispose();
    directionController.dispose();
    phoneController.removeListener(() => formatPhoneNumber(phoneController));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FrdBloc, FrdState>(
        bloc: bloc,
        builder: (context, state) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SafeArea(
              child: Scaffold(
                appBar: const AppBars(title: 'Сбор данных ФРД'),
                backgroundColor: AppColor.white,
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
                              const Gap(50),
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
                                validator: (value) =>
                                    Utils.validateDiv(value, divNames),
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
                                onChanged: (value) => () {
                                  setState(() {});
                                },
                                validator: (value) =>
                                    Utils.validatePhone(value),
                                keyboardType: TextInputType.phone,
                                isTitle: true,
                              ),
                              const Gap(45),
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
                                        Get.find<FrdRepository>().valuesFrd =
                                            filteredProcesses
                                                .map((e) => e.operation)
                                                .toSet()
                                                .toList();
                                        Get.find<FrdRepository>()
                                                .operationsFrd =
                                            filteredProcesses
                                                .map((e) => e.operation)
                                                .toSet()
                                                .toList();
                                      }
                                      Get.find<FrdRepository>().tempFrd.org =
                                          orgController.text;
                                      Get.find<FrdRepository>().tempFrd.org =
                                          orgController.text;
                                      Get.find<FrdRepository>()
                                          .tempFrd
                                          .division = divController.text;
                                      Get.find<FrdRepository>().tempFrd.date =
                                          DateFormat("dd.MM.yyyy")
                                              .parse(dateController.text);
                                      Get.find<FrdRepository>()
                                          .tempFrd
                                          .operating = operatingController.text;
                                      Get.find<FrdRepository>().tempFrd.fio =
                                          fioController.text;
                                      Get.find<FrdRepository>().tempFrd.post =
                                          postController.text;
                                      Get.find<FrdRepository>()
                                              .tempFrd
                                              .experience =
                                          int.parse(Utils.normalizePhone(
                                              experienceController.text));
                                      Get.find<FrdRepository>().tempFrd.phone =
                                          Utils.formatPhoneNumberToPlain(
                                              phoneController.text);
                                      Get.find<FrdRepository>()
                                          .tempFrd
                                          .operations = [];
                                      Get.find<FrdRepository>().saveAll();

                                      context.goNamed('ФРДТаблица');
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
