import 'package:alrino/domain/models/fhn/operations_fhn.dart';
import 'package:alrino/domain/models/photo_day.dart';

/// Класс [Fhn] представляет собой модель для работы с Фото на день (ФХН).
/// 
/// Включает в себя информацию о различных операциях, дополнительных реквизитах и колонках,
/// связанных с конкретным ФХН. Наследует основные свойства от класса [PhotoDay],
/// добавляя специфичные поля и методы для работы с ФХН.
/// 
/// Поля класса:
/// - [operations] список операций, связанных с ФХН.
/// - [requisites] список дополнительных реквизитов ФХН.
/// - [addColumns] список дополнительных колонок для ФХН.
/// 
/// Конструкторы:
/// - [Fhn] основной конструктор класса, требующий инициализации всех полей.
/// - [Fhn.initial] конструктор для инициализации объекта с начальными значениями.
/// - [Fhn.fromJson] конструктор для создания объекта из JSON-объекта.
/// 
/// Методы:
/// - [toJson] метод для преобразования объекта в JSON-объект.

/// Класс ФХН
class Fhn extends PhotoDay {
  List<OperationFhn> operations = []; // список операций
  List<Requisite> requisites = []; // список дополнительных реквизитов
  List<AddColumns> addColumns = []; // список дополнительных колонок

  Fhn({
    required super.org,
    required super.division,
    required super.date,
    required super.operating,
    required super.fio,
    required super.post,
    required super.experience,
    required super.phone,
    required super.endTime,
    required this.operations,
    required this.requisites,
    required this.addColumns,
  });

  factory Fhn.initial() {
    return Fhn(
      org: '',
      division: '',
      date: DateTime.now(),
      operating: '',
      fio: '',
      post: '',
      experience: 0,
      phone: '',
      operations: [],
      requisites: [],
      addColumns: [],
      endTime: DateTime.now(),
    );
  }

  factory Fhn.fromJson(Map<String, dynamic> data) {
    return Fhn(
      org: data['org'] ?? '',
      division: data['division'] ?? '',
      date:
          data['date'] == null ? DateTime.now() : DateTime.parse(data['date']),
      operating: data['operating'] ?? '',
      fio: data['fio'] ?? '',
      post: data['post'] ?? '',
      experience: data['experience'] ?? 0,
      phone: data['phone'] ?? '',
      operations: data['operations'] != null
          ? List<OperationFhn>.from(data['operations'].map<OperationFhn>(
              (x) => OperationFhn.fromJson(x),
            ))
          : [],
      requisites: data['requisites'] != null
          ? List<Requisite>.from(data['requisites'].map<Requisite>(
              (x) => Requisite.fromJson(x),
            ))
          : [],
      addColumns: data['addColumns'] != null
          ? List<AddColumns>.from(data['addColumns'].map<AddColumns>(
              (x) => AddColumns.fromJson(x),
            ))
          : [],
      endTime: data['endTime'] == null
          ? DateTime.now()
          : DateTime.parse(data['endTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org': org,
      'division': division,
      'date': date.toString(),
      'operating': operating,
      'fio': fio,
      'post': post,
      'experience': experience,
      'phone': phone,
      'operations': operations.map((x) => x.toJson()).toList(),
      'requisites': requisites.map((x) => x.toJson()).toList(),
      'addColumns': addColumns.map((x) => x.toJson()).toList(),
      'endTime': endTime.toString(),
    };
  }
}

/// класс реквизитов
class Requisite {
  int id;
  String name;
  String value;

  Requisite({required this.id, required this.name, required this.value});

  factory Requisite.fromJson(Map<String, dynamic> data) {
    return Requisite(
      id: data['id'],
      name: data['name'],
      value: data['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }

  factory Requisite.initial() {
    return Requisite(id: 0, name: '', value: '');
  }
}
