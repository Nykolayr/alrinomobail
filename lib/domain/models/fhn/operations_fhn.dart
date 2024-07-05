/// Элемент операций(трудового процесса)
/// id - идентификатор операции
/// name - наименование  операции
/// beginDate - дата начала операции
/// durationOperation - продолжительность операции
///  hours - часы
///  minutes - минуты
///  seconds - секунды
/// addColumns - добавляемые столбцы
/// measured - Замеренный объем работ, га
/// distance - пройденное расстояние
/// fuelConsumption - Расход топлива на объем работ, л
/// comment - комментарий операции
/// problem - проблема операции
/// linesEdit - массив количества строк в редактируемом элементе
class OperationFhn {
  int id;
  String name;
  DateTime beginDate;
  Duration durationOperation;
  String comment;
  String problem;
  List<int> linesEdit;
  List<AddColumns> addColumns;

  OperationFhn({
    required this.id,
    required this.name,
    required this.beginDate,
    required this.durationOperation,
    required this.comment,
    required this.problem,
    required this.linesEdit,
    required this.addColumns,
  });

  bool get isFiveColumns => addColumns.length < 5;

  factory OperationFhn.initial() {
    return OperationFhn(
      id: 0,
      name: '',
      beginDate: DateTime.now(),
      durationOperation: const Duration(hours: 0, minutes: 0, seconds: 0),
      comment: '',
      problem: '',
      linesEdit: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      addColumns: [],
    );
  }

  factory OperationFhn.fromJson(Map<String, dynamic> data) {
    return OperationFhn(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      beginDate: data['beginDate'] == null
          ? DateTime.now()
          : DateTime.parse(data['beginDate']),
      durationOperation: Duration(
        hours: data['durationOperation']['hours'],
        minutes: data['durationOperation']['minutes'],
        seconds: data['durationOperation']['seconds'],
      ),
      comment: data['comment'] ?? '',
      problem: data['problem'] ?? '',
      linesEdit:
          data['linesEdit'] != null ? List<int>.from(data['linesEdit']) : [],
      addColumns: data['addColumns'] != null
          ? List<AddColumns>.from(
              data['addColumns'].map((x) => AddColumns.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'beginDate': beginDate.toIso8601String(),
      'durationOperation': {
        'hours': durationOperation.inHours,
        'minutes': durationOperation.inMinutes.remainder(60),
        'seconds': durationOperation.inSeconds.remainder(60),
      },
      'comment': comment,
      'problem': problem,
      'linesEdit': linesEdit,
      'addColumns': addColumns.map((x) => x.toJson()).toList(),
    };
  }
}

/// класс дополнительных столбцов
class AddColumns {
  int id;
  String name;
  String value;

  AddColumns({required this.id, required this.name, required this.value});

  factory AddColumns.fromJson(Map<String, dynamic> data) {
    return AddColumns(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      value: data['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }

  factory AddColumns.initial() {
    return AddColumns(id: 0, name: '', value: '');
  }
}
