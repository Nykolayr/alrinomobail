import 'package:alrino/common/constants.dart';
import 'package:alrino/domain/models/sz/sz_operation.dart';
import 'package:alrino/domain/models/user.dart';

/// Класс СЗ
class Sz {
  int id; // идентификатор
  List<OperationSz> operations; // список операций
  bool isOuter; // флаг внешней работы или в офисе
  DateTime timeStamp; // время создания
  User user; // пользователь
  DateTime begin; // время начала работы
  DateTime end; // время окончания работы
  String intensity; // человеко часы работы
  String project; // проект
  String pathName; // путь к таблице
  DateTime endTime; // время окончания работы
  Duration workTime; // текущее время работы в таблице
  Duration maxWorkTimer; // максимальное время работы в таблице

  Sz({
    required this.operations,
    required this.isOuter,
    required this.timeStamp,
    required this.user,
    required this.id,
    required this.begin,
    required this.end,
    required this.intensity,
    required this.project,
    required this.pathName,
    required this.endTime,
    required this.workTime,
    required this.maxWorkTimer,
  });

  factory Sz.initial() {
    return Sz(
      isOuter: false,
      operations: [],
      user: User.initial(),
      timeStamp: DateTime.now(),
      id: 0,
      intensity: '',
      project: '',
      begin: DateTime.now(),
      end: DateTime.now(),
      pathName: '',
      endTime: DateTime.now(),
      workTime: const Duration(),
      maxWorkTimer: allTimerConst,
    );
  }

  factory Sz.fromJson(Map<String, dynamic> data) {
    String error = '';
    for (final item in data.values) {
      error += '/n${item.runtimeType}';
    }
    try {
      return Sz(
        isOuter: data['isOuter'] ?? false,
        operations: data['operations'] == null
            ? []
            : List<OperationSz>.from(
                data['operations'].map<OperationSz>(
                  (x) => OperationSz.fromJson(x),
                ),
              ),
        timeStamp: data['timeStamp'] == null
            ? DateTime.now()
            : DateTime.parse(data['timeStamp']),
        user:
            data['user'] == null ? User.initial() : User.fromJson(data['user']),
        id: data['id'] ?? 0,
        intensity: data['intensity'] ?? '',
        project: data['project'] ?? '',
        begin: data['begin'] == null
            ? DateTime.now()
            : DateTime.parse(data['begin']),
        end: data['end'] == null ? DateTime.now() : DateTime.parse(data['end']),
        pathName: data['pathName'] ?? '',
        endTime: data['endTime'] == null
            ? DateTime.now()
            : DateTime.parse(data['endTime']),
        workTime: data['workTime'] == null
            ? const Duration()
            : Duration(seconds: data['workTime']),
        maxWorkTimer: data['maxWorkTimer'] == null
            ? maxTimerConst
            : Duration(seconds: data['maxWorkTimer']),
      );
    } catch (e) {
      throw Exception(
          'ошибка парсинге Sz.fromJson == $e \n данные: $data, \n  логи: \n $error');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isOuter': isOuter,
      'operations': operations.map((x) => x.toJson()).toList(),
      'user': user.toJson(),
      'timeStamp': timeStamp.toString(),
      'id': id,
      'begin': begin.toIso8601String(),
      'end': end.toIso8601String(),
      'intensity': intensity,
      'project': project,
      'pathName': pathName,
      'endTime': endTime.toIso8601String(),
      'workTime': workTime.inSeconds,
      'maxWorkTimer': maxWorkTimer.inSeconds,
    };
  }

  bool isTimeStampExpired() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return timeStamp.isBefore(startOfDay) || timeStamp.isAfter(endOfDay);
  }
}
