import 'package:alrino/domain/repository/fhn_repository.dart';
import 'package:alrino/presentation/theme/theme.dart';
import 'package:alrino/presentation/widgets/app_bar.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:alrino/presentation/widgets/fon_picture.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Страница ФХН
class FhnPage extends StatelessWidget {
  const FhnPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const AppBars(title: 'Сбор данных ФХН'),
        backgroundColor: AppColor.white,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            const FonPicture(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(50),
                  Buttons.button280(
                      onPressed: () {
                        Get.find<FhnRepository>().createPatternFhn();
                        context.goNamed('Новый шаблон');
                      },
                      text: 'Создать новый шаблон'),
                  const Gap(30),
                  Buttons.button280(
                      onPressed: () {
                        context.goNamed('Выбор шаблона');
                      },
                      text: 'Выбрать шаблон'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
