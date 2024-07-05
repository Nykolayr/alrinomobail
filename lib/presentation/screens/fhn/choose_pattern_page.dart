import 'package:alrino/domain/models/fhn/pattern_fhn.dart';
import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/fhn/widgets.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Страница выбора шаблона ФХН
class FhnChoosePatternPage extends StatefulWidget {
  const FhnChoosePatternPage({Key? key}) : super(key: key);

  @override
  State<FhnChoosePatternPage> createState() => _FhnChoosePatternPageState();
}

class _FhnChoosePatternPageState extends State<FhnChoosePatternPage> {
  final bool isExecutor = Get.find<UserRepository>().user.isExecutor;

  @override
  Widget build(BuildContext context) {
    List<PatternFhn> patternsFhn = Get.find<FhnRepository>().patternsFhn;
    return SafeArea(
      child: Scaffold(
        appBar: const AppBars(title: 'Выберите шаблон '),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(50),
                    if (patternsFhn.isNotEmpty)
                      for (PatternFhn pattern in patternsFhn)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Buttons.button220(
                                    onPressed: () {
                                      Get.find<FhnRepository>().tempPattern =
                                          pattern;
                                      context.goNamed('Заполнение формы');
                                    },
                                    text: pattern.name),
                                const Gap(5),
                                getIconButton(
                                  'assets/svg/edit.svg',
                                  isBlock: !(!isExecutor || pattern.isMy),
                                  onTap: () {
                                    Get.find<FhnRepository>().tempPattern =
                                        pattern;
                                    context.goNamed('Редактирование шаблона');
                                  },
                                ),
                                getIconButton('assets/svg/trash.svg',
                                    isBlock: !(!isExecutor || pattern.isMy),
                                    onTap: () async {
                                  bool? isDelete = await deletePatternAlert(
                                      pattern.name, 'шаблон', context);
                                  if (isDelete != null && isDelete) {
                                    await Get.find<FhnRepository>()
                                        .deletePattern(pattern.id);
                                    setState(() {});
                                  }
                                }, isRed: true),
                              ]),
                        ),
                    if (patternsFhn.isEmpty) ...[
                      const Gap(245),
                      const Center(
                        child: Text('У Вас еще нет ни одного шаблона ',
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
    );
  }
}
