import 'package:alrino/presentation/theme/colors.dart';
import 'package:alrino/presentation/theme/different.dart';
import 'package:alrino/presentation/theme/text.dart';
import 'package:flutter/material.dart';

/// общий класс для кнопок приложения
class ButtonSelf extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool isBlue;
  final bool isSmall;
  const ButtonSelf(
      {required this.text,
      required this.width,
      required this.height,
      required this.onPressed,
      this.isSmall = false,
      this.isBlue = true,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isBlue ? AppColor.blue : AppColor.cyan,
          borderRadius: AppDif.borderRadius20,
        ),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: isSmall ? AppText.button12 : AppText.button18,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

/// класс с прессетами кнопок приложения
class Buttons {
  /// кнопка входа в приложение
  static ButtonSelf button180(
      {required void Function() onPressed,
      required String text,
      isWidth = false}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 180,
      height: 50,
    );
  }

  /// широка кнопка 280
  static ButtonSelf button280(
      {required void Function() onPressed,
      required String text,
      isWidth = false}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 280,
      height: 50,
    );
  }

  /// широка кнопка 220
  static ButtonSelf button220(
      {required void Function() onPressed,
      required String text,
      isWidth = false}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 220,
      height: 50,
    );
  }

  /// кнопка выхода из профиля
  static ButtonSelf alert(
      {required void Function() onPressed, required String text}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 120,
      height: 40,
      isSmall: true,
    );
  }

  /// кнопка выбора дальнейшего действия
  static ButtonSelf selfChooseBlue(
      {required void Function() onPressed,
      required String text,
      bool isBlue = true}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 156,
      height: 71,
      isBlue: isBlue,
    );
  }

  /// кнопка перехода на таблицы
  static ButtonSelf goTable(
      {required void Function() onPressed,
      required String text,
      bool isBlue = true}) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 156,
      height: 71,
      isBlue: isBlue,
    );
  }
}
