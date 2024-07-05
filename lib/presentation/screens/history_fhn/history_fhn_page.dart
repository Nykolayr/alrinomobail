import 'package:alrino/domain/models/fhn/fhn_history.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/autocomplit_field.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Страница истории ФХН
class HistoryFhnPage extends StatefulWidget {
  const HistoryFhnPage({Key? key}) : super(key: key);

  @override
  State<HistoryFhnPage> createState() => HistoryFhnPageState();
}

class HistoryFhnPageState extends State<HistoryFhnPage> {
  String error = '';
  List<Organisation> orgs = Get.find<MainRepository>().orgs;
  late TextEditingController orgController;
  late TextEditingController divController;
  late TextEditingController yearController;
  late TextEditingController monthController;
  List<String> years = [];
  List<String> months = [];
  List<String> orgNames = [];
  List<String> divNames = [];
  List<FhnHystory> hystories = Get.find<FhnRepository>().hystoryFhn;
  List<FhnHystory> hystoriesFilter = [];
  Key key = GlobalKey();

  @override
  void initState() {
    years = hystories.map((h) => h.year).toSet().toList();
    months = hystories.map((h) => h.month).toSet().toList();
    months = months.map((month) {
      return month.substring(0, 1).toUpperCase() + month.substring(1);
    }).toList();
    orgNames = hystories.map((h) => h.org).toSet().toList();
    divNames = hystories.map((h) => h.div).toSet().toList();
    orgController = TextEditingController();
    divController = TextEditingController();
    yearController = TextEditingController();
    monthController = TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  dispose() {
    orgController.dispose();
    divController.dispose();
    yearController.dispose();
    monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: SafeArea(
        child: Scaffold(
          appBar: const AppBars(title: 'История ФХН'),
          backgroundColor: AppColor.white,
          body: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              const FonPicture(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(45),
                      if (hystories.isNotEmpty) ...[
                        AutoComplitFormField(
                          initialValue: years.last,
                          suggestions: years,
                          controller: yearController,
                          hint: 'Выберите год',
                          onChanged: (value) => () {},
                          // validator: (value) =>
                          //     Utils.validateNotEmpty(value, 'Выберите месяц'),
                          keyboardType: TextInputType.name,
                          isTitle: true,
                        ),
                        const Gap(20),
                        AutoComplitFormField(
                          suggestions: months,
                          controller: monthController,
                          hint: 'Выберите месяц',
                          onChanged: (value) => () {},
                          // validator: (value) =>
                          //     Utils.validateNotEmpty(value, 'Выберите месяц'),
                          keyboardType: TextInputType.name,
                          isTitle: true,
                        ),
                        const Gap(20),
                        AutoComplitFormField(
                          suggestions: orgNames,
                          controller: orgController,
                          hint: 'Выберите проект',
                          onChanged: (value) => () {},
                          // validator: (value) =>
                          //     Utils.validateNotEmpty(value, 'Выберите проект'),
                          keyboardType: TextInputType.name,
                          isTitle: true,
                          updateSuggestions: (value) {
                            value = value.trim().split('_')[0];
                            if (orgs.any((element) => element.name == value)) {
                              setState(() {
                                divController.clear();
                                divNames = hystories
                                    .map((h) => h.div)
                                    .toSet()
                                    .toList();
                                List<String> divNamesAll = orgs
                                    .firstWhere(
                                        (element) => element.name == value)
                                    .divNames;
                                divNames = divNamesAll
                                    .where((name) => divNames.contains(name))
                                    .toList();
                                key = GlobalKey();
                              });
                            }
                          },
                        ),
                        const Gap(20),
                        AutoComplitFormField(
                          key: key,
                          suggestions: divNames,
                          controller: divController,
                          hint: 'Выберите структурное подразделение',
                          onChanged: (value) => () {},
                          // validator: (value) => Utils.validateNotEmpty(
                          //     value, 'Выберите Структурное подразделение'),
                          keyboardType: TextInputType.name,
                          isTitle: true,
                        ),
                        const Gap(25),
                        Center(
                          child: Text(error,
                              style: AppText.textField12
                                  .copyWith(color: AppColor.redPro)),
                        ),
                        const Gap(25),
                        Center(
                          child: Buttons.button180(
                              onPressed: () {
                                hystoriesFilter = filterHystories();
                                Logger.d(
                                    '${hystories.length} == ${hystoriesFilter.length}');
                                if (hystoriesFilter.isEmpty) {
                                  error =
                                      'Ничего не найдено, попробуйте изменить фильтры';
                                  setState(() {});
                                  Future.delayed(
                                      const Duration(seconds: 4),
                                      () => setState(() {
                                            error = '';
                                            hystoriesFilter = [];
                                          }));
                                  return;
                                }
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                context.goNamed(
                                  'История ФХН таблица',
                                  extra: hystoriesFilter,
                                );
                              },
                              text: 'Посмотреть'),
                        ),
                        const Gap(25),
                      ],
                      if (hystories.isEmpty) ...[
                        const Gap(245),
                        const Center(
                          child: Text('У Вас еще нет ФХН ',
                              textAlign: TextAlign.center,
                              style: AppText.title18),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FhnHystory> filterHystories() {
    // Создаем новый список для фильтрованных значений
    List<FhnHystory> hystoriesFilter = [];

    // Проверяем каждый объект в исходном списке
    for (FhnHystory hystory in hystories) {
      // Проверяем значение поля "year"
      if (yearController.text.isNotEmpty &&
          hystory.year != yearController.text) {
        continue; // Пропускаем объект, если значение "year" не соответствует фильтру
      }

      // Проверяем значение поля "month"
      if (monthController.text.isNotEmpty &&
          hystory.month.toLowerCase() != monthController.text.toLowerCase()) {
        continue; // Пропускаем объект, если значение "month" не соответствует фильтру
      }

      // Проверяем значение поля "org"
      if (orgController.text.isNotEmpty && hystory.org != orgController.text) {
        continue; // Пропускаем объект, если значение "org" не соответствует фильтру
      }

      // Проверяем значение поля "div"
      if (divController.text.isNotEmpty && hystory.div != divController.text) {
        continue; // Пропускаем объект, если значение "div" не соответствует фильтру
      }
      // Если объект проходит все проверки, добавляем его в фильтрованный список
      hystoriesFilter.add(hystory);
    }
    // Возвращаем фильтрованный список
    return hystoriesFilter;
  }
}
