/// Элемент операций(трудового процесса)
/// id - идентификатор операции
/// name - наименование  операции
/// beginDate - дата начала операции
/// durationOperation - продолжительность операции
///  hours - часы
///  minutes - минуты
///  seconds - секунды
/// description - Краткое описание выполненных задач
/// linesEdit - массив количества строк в редактируемом элементе
class OperationSz {
  int id;
  String org;
  DateTime beginDate;
  Duration durationOperation;
  String tasks;
  List<int> linesEdit;

  OperationSz({
    required this.id,
    required this.org,
    required this.beginDate,
    required this.durationOperation,
    required this.tasks,
    required this.linesEdit,
  });

  factory OperationSz.initial() {
    return OperationSz(
      id: 0,
      org: '',
      beginDate: DateTime.now(),
      durationOperation: const Duration(hours: 0, minutes: 0, seconds: 0),
      tasks: '',
      linesEdit: [1, 1],
    );
  }

  factory OperationSz.fromJson(Map<String, dynamic> data) {
    return OperationSz(
      id: data['id'] ?? 0,
      org: data['name'] ?? '',
      beginDate: data['beginDate'] == null
          ? DateTime.now()
          : DateTime.parse(data['beginDate']),
      durationOperation: data['durationOperation'] == null
          ? const Duration(hours: 0, minutes: 0, seconds: 0)
          : Duration(
              hours: data['durationOperation']['hours'] ?? 0,
              minutes: data['durationOperation']['minutes'] ?? 0,
              seconds: data['durationOperation']['seconds'] ?? 0,
            ),
      tasks: data['tasks'] ?? '',
      linesEdit:
          data['linesEdit'] == null ? [] : List<int>.from(data['linesEdit']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': org,
      'beginDate': beginDate.toIso8601String(),
      'durationOperation': {
        'hours': durationOperation.inHours,
        'minutes': durationOperation.inMinutes.remainder(60),
        'seconds': durationOperation.inSeconds.remainder(60),
      },
      'tasks': tasks,
      'linesEdit': linesEdit
    };
  }
}
