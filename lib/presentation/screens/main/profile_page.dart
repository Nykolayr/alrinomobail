import 'package:alrino/domain/models/user.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:alrino/presentation/screens/main/bloc/main_bloc.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:alrino/presentation/widgets/alerts.dart';
import 'package:alrino/presentation/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Страница профиля пользователя
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    User user = Get.find<UserRepository>().user;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemProfile(
            text: 'ФИО:',
            subText: user.fullName,
          ),
          ItemProfile(text: 'Должность:', subText: user.post),
          ItemProfile(text: 'СНИЛС:', subText: user.snils),
          ItemProfile(text: 'ИНН:', subText: user.inn),
          ItemProfile(text: 'Стаж работы:', subText: getYears(user.experience)),
          const Gap(20),
          Center(
            child: Buttons.button180(
              text: 'Обновить',
              onPressed: () => Get.find<MainBloc>().add(UpdateServerEvent()),
            ),
          ),
          const Gap(50),
          Center(
            child: Buttons.button180(
              text: 'Выйти',
              onPressed: () async {
                final isConfirmed = await showExitProfileAlert(context);
                if (isConfirmed == true) {
                  await Get.find<UserRepository>().clearUser();
                  if (context.mounted) context.goNamed('авторизация');
                }
              },
            ),
          ),
          const Gap(100),
        ],
      ),
    );
  }
}

class ItemProfile extends StatelessWidget {
  final String subText;
  final String text;

  const ItemProfile({required this.subText, required this.text, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        text,
        style: AppText.titleBlue24,
      ),
      const Gap(2),
      Text(
        subText,
        style: AppText.title20,
      ),
      const Gap(10),
    ]);
  }
}

String getYears(int year) {
  if (year % 10 == 1 && year % 100 != 11) {
    return '$year год';
  } else if ((year % 10 >= 2 && year % 10 <= 4) &&
      (year % 100 < 10 || year % 100 >= 20)) {
    return '$year года';
  } else {
    return '${(year + 1)} лет';
  }
}
