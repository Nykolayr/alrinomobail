import 'package:alrino/common/utils.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:get/get.dart';

/// Класс предок для ФРД, ФХН
abstract class PhotoDay {
  String org;
  String division;
  DateTime date;
  String operating; // режим работы
  String fio;
  String post;
  int experience;
  String phone;
  DateTime endTime;

  PhotoDay({
    required this.org,
    required this.division,
    required this.date,
    required this.operating,
    required this.fio,
    required this.post,
    required this.experience,
    required this.phone,
    required this.endTime,
  });
}

enum FrdStatus {
  org,
  div,
  date,
  operating,
  fio,
  post,
  experience,
  phone,
  fioShow;

  String get title => switch (this) {
        FrdStatus.org => 'Название организации:',
        FrdStatus.div => 'Структурное подразделения:',
        FrdStatus.date => 'Дата наблюдения:',
        FrdStatus.operating => 'Режим работы, смены',
        FrdStatus.fio => 'ФИО исполнителя(-ей):',
        FrdStatus.post => 'Должность (профессия) исполнителя(-ей):',
        FrdStatus.experience => 'Стаж (полных лет):',
        FrdStatus.phone => 'Контактный номер телефона:',
        FrdStatus.fioShow => 'ФИО наблюдателя:',
      };
  String value(PhotoDay frd) => switch (this) {
        FrdStatus.org => frd.org,
        FrdStatus.div => frd.division,
        FrdStatus.date => Utils.getFormatDate(frd.date),
        FrdStatus.operating => frd.operating,
        FrdStatus.fio => frd.fio,
        FrdStatus.post => frd.post,
        FrdStatus.experience => frd.experience.toString(),
        FrdStatus.phone => frd.phone,
        FrdStatus.fioShow => Get.find<UserRepository>().user.fullName,
      };
}
