import 'package:alrino/domain/models/frd/frd_operation.dart';
import 'package:alrino/domain/models/photo_day.dart';

/// Класс ФРД
class Frd extends PhotoDay {
  List<OperationFrd> operations = []; // список операций

  Frd({
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
  });

  factory Frd.initial() {
    return Frd(
      org: '',
      division: '',
      date: DateTime.now(),
      operating: '',
      fio: '',
      post: '',
      experience: 0,
      phone: '',
      operations: [],
      endTime: DateTime.now(),
    );
  }

  factory Frd.fromJson(Map<String, dynamic> data) {
    return Frd(
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
          ? List<OperationFrd>.from(
              data['operations']
                  .map<OperationFrd>((x) => OperationFrd.fromJson(x)),
            )
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
      'endTime': endTime.toString(),
    };
  }
}
