import 'package:alrino/domain/models/fhn/fhn.dart';
import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/domain/models/photo_day.dart';

/// PatternFhn - это класс, представляющий шаблон ФХН (Фото дня).
/// Он наследует от класса PhotoDay и добавляет специфические поля и методы,
/// необходимые для работы с шаблонами ФХН.
///
/// Поля:
/// - id: уникальный идентификатор шаблона
/// - name: название шаблона
/// - isMy: флаг, указывающий на то, является ли шаблон собственным
/// - requisites: список дополнительных реквизитов, связанных с шаблоном
/// - addColumns: список добавленных столбцов, которые необходимо отобразить в шаблоне
///
/// Конструкторы:
/// - PatternFhn: основной конструктор, инициализирующий все поля класса
/// - PatternFhn.initial: конструктор для инициализации шаблона с значениями по умолчанию
/// - PatternFhn.fromJson: конструктор для создания экземпляра класса из JSON-объекта
///
/// Этот класс используется для работы с шаблонами ФХН в приложении, позволяя управлять
/// их созданием, редактированием и отображением.

class PatternFhn extends PhotoDay {
  int id; // Идентификатор шаблона
  String name; // Название шаблона
  bool isMy; // Флаг, указывающий на то, является ли шаблон собственным
  List<Requisite> requisites;
  List<AddColumns> addColumns;

  PatternFhn({
    required super.org,
    required super.division,
    required super.date,
    required super.operating,
    required super.fio,
    required super.post,
    required super.experience,
    required super.phone,
    required super.endTime,
    required this.id,
    required this.name,
    required this.requisites,
    required this.addColumns,
    required this.isMy,
  });

  factory PatternFhn.initial() {
    return PatternFhn(
      org: '',
      division: '',
      date: DateTime.now(),
      operating: '',
      fio: '',
      post: '',
      experience: 0,
      phone: '',
      id: -1,
      name: '',
      requisites: [],
      addColumns: [],
      endTime: DateTime.now(),
      isMy: true,
    );
  }

  factory PatternFhn.fromJson(Map<String, dynamic> data) {
    return PatternFhn(
      org: data['org'] ?? '',
      division: data['division'] ?? '',
      date:
          data['date'] == null ? DateTime.now() : DateTime.parse(data['date']),
      operating: data['operating'] ?? '',
      fio: data['fio'] ?? '',
      post: data['post'] ?? '',
      experience: data['experience'] ?? 0,
      phone: data['phone'] ?? '',
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      requisites: List<Requisite>.from(
        data['requisites'].map<Requisite>(
          (x) => Requisite.fromJson(x),
        ),
      ),
      addColumns: List<AddColumns>.from(
        data['addColumns'].map<AddColumns>(
          (x) => AddColumns.fromJson(x),
        ),
      ),
      endTime: data['endTime'] == null
          ? DateTime.now()
          : DateTime.parse(data['endTime']),
      isMy: data['isMy'] == null ? false : data['isMy'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'requisites': requisites.map((x) => x.toJson()).toList(),
      'addColumns': addColumns.map((x) => x.toJson()).toList(),
      'org': org,
      'division': division,
      'date': date.toString(),
      'operating': operating,
      'fio': fio,
      'post': post,
      'experience': experience,
      'phone': phone,
      'endTime': endTime.toString(),
      'isMy': isMy ? 1 : 0,
    };
  }
}
