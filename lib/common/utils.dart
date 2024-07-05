import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/process.dart';
import 'package:alrino/domain/repository/main_repositoty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Документация класса Utils
///
/// Класс Utils содержит вспомогательные функции для работы с данными в приложении.
/// Включает в себя методы для форматирования номера телефона, капитализации текста,
/// вычисления разницы между двумя датами и другие полезные утилиты.
class Utils {
  /// Форматирование телефона без пробелов и без -
  static String formatPhoneNumberToPlain(String formattedNumber) {
    // Удаляем все символы, кроме цифр, и возвращаем результат с добавлением + в начале
    return '+${formattedNumber.replaceAll(RegExp(r'[^0-9]'), '')}';
  }

  /// возвращает текст с заглавными буквами первого слова
  /// и после точки
  static String capitalizeText(String text) {
    bool isDotLast = text[text.length - 1] == '.';

    List<String> sentences = text.split('.');

    String result = '';

    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i].trim();

      if (sentence.isNotEmpty) {
        String firstLetter = sentence[0].toUpperCase();
        sentence = firstLetter + sentence.substring(1);

        if (sentence.length > 1 && sentence[1] != ' ') {
          sentence = sentence.substring(0, 1) + sentence.substring(1);
        }

        result += '$sentence. ';
      }
    }
    result = result.trim();
    if (isDotLast) {
      result = '${result.substring(0, result.length - 1)}.';
    } else {
      result = result.substring(0, result.length - 1);
    }
    return result.trim();
  }

  /// высчитываем разницу между двумя датами вплоть до миллисекунд
  static Duration getDurationDifferent(
    DateTime date1,
    DateTime date2,
  ) {
    int diffInMilliseconds = date2.difference(date1).inMilliseconds;

    int hours = (diffInMilliseconds ~/ (1000 * 60 * 60)) % 24;
    int minutes = (diffInMilliseconds ~/ (1000 * 60)) % 60;
    int seconds = (diffInMilliseconds ~/ 1000) % 60;
    int milliseconds = diffInMilliseconds % 1000;
    return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds);
  }

  static String getFormatDurationWithOneCifra(Duration duration) {
    return '${duration.inHours.toString().padLeft(1, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  static String getFormatDuration(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  static String getDateYear(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy', 'ru');
    return formatter.format(date);
  }

  static String getDateMonth(DateTime date) {
    final DateFormat formatter = DateFormat('MMMM', 'ru');
    return formatter.format(date);
  }

  static String getDateDay(DateTime date) {
    final DateFormat formatter = DateFormat('dd', 'ru');
    return formatter.format(date);
  }

  static String getFormatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd.MM.yyyy', 'ru');
    return formatter.format(date);
  }

  static String getFormatDateHour(DateTime date) {
    final DateFormat formatter = DateFormat('H:mm', 'ru');
    return formatter.format(date);
  }

  static String getFormatDateHourWithSeconds(DateTime date) {
    final DateFormat formatter = DateFormat('H:mm:ss', 'ru');
    return formatter.format(date);
  }

  static String getFormatDateHourWithMilliseconds(DateTime date) {
    String milliseconds = date.millisecond.toString().padLeft(3, '0');
    DateFormat dateFormat = DateFormat('H:mm:ss', 'ru');
    return '${dateFormat.format(date)},$milliseconds';
  }

  static String getFormatDurationWithMilliseconds(Duration duration) {
    int milliseconds = duration.inMilliseconds % 1000;
    return '${duration.inHours.toString().padLeft(1, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')},${milliseconds.toString().padLeft(3, '0')}';
  }

  // static String hashPassword(String password) {
  //   var bin = utf8.encode(password);
  //   return sha256.convert(bin).toString();
  // }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Поле не может быть пустым';
    }

    final errors = <String>[];

    if (!RegExp('^(?=.*?[a-z])').hasMatch(password)) {
      errors.add('Хотя бы 1 строчная буква');
    }

    if (!RegExp('^(?=.*?[A-Z])').hasMatch(password)) {
      errors.add('Хотя бы 1 заглавная буква');
    }

    if (!RegExp('^(?=.*?[0-9])').hasMatch(password)) {
      errors.add('Хотя бы 1 цифра');
    }

    if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(password)) {
      errors.add('Хотя бы 1 символ');
    }

    if (!RegExp(r'^.{8,}$').hasMatch(password)) {
      errors.add('Минимум 8 символов');
    }

    if (errors.isNotEmpty) return 'Требования к паролю:\n${errors.join('\n')}';

    return null;
  }

  static String normalizePhone(String phone) {
    return phone
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('+', '');
  }

  /// Проверка деятельности по списку деятельностей
  static String? validateActivity(String? value) {
    if (value == null || value.isEmpty) return 'Введите название деятельности';
    value = value.trim().split('_')[0];
    Process? process = Get.find<MainRepository>()
        .process
        .firstWhereOrNull((e) => e.activity == value);
    if (process == null) return 'Введите название деятельности из списка';
    return null;
  }

  /// Проверка   направления по списку направлений
  static String? validateDirection(String? value, List<String> divs) {
    if (value == null || value.isEmpty) return 'Введите название направления';

    if (!divs.contains(value)) {
      return 'Введите название направления из списка';
    }
    return null;
  }

  /// Проверка организации по списку организаций
  static String? validateOrg(String? value) {
    if (value == null || value.isEmpty) return 'Введите название проекта';
    value = value.trim().split('_')[0];
    Organisation? org = Get.find<MainRepository>()
        .orgs
        .firstWhereOrNull((e) => e.name == value);
    if (org == null) return 'Введите название проекта из списка';
    return null;
  }

  /// Проверка подразделения по списку  подразделений
  static String? validateDiv(String? value, List<String> divs) {
    if (value == null || value.isEmpty) return 'Введите название проекта';

    if (!divs.contains(value)) {
      return 'Введите название подразделения из списка';
    }
    return null;
  }

  /// Проверка на пустоту
  static String? validateNotEmpty(String? value, String message) {
    return (value == null || value.isEmpty) ? message : null;
  }

  /// Проверка телефона на корректность
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Телефон обязателен';
    // Удаляем все символы, кроме цифр, и проверяем длину
    String numericOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.length != 11) {
      return 'Введите полный номер телефона (11 цифр)';
    }
    return null; // Возвращает null, если данные валидны
  }

  static String? validateEmail(String? value, String message) {
    final re = RegExp(r'.+@.+\..+');
    return (value == null || value.isEmpty || !re.hasMatch(value))
        ? message
        : null;
  }

  static String? validateCompareValues(
      String? value1, String? value2, String message) {
    return (value1 == null ||
            value1.isEmpty ||
            value2 == null ||
            value2.isEmpty ||
            value1 != value2)
        ? message
        : null;
  }

  static Widget circularProgressIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}
