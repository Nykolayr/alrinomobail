/// Элемент операций(трудового процесса)
/// id - идентификатор операции
/// name - наименование  операции
/// beginDate - дата начала операции
/// durationOperation - продолжительность операции
///  hours - часы
///  minutes - минуты
///  seconds - секунды
/// comment - комментарий операции
/// problem - проблема операции
/// linesEdit - массив количества строк в редактируемом элементе
class OperationFrd {
  int id;
  String name;
  DateTime beginDate;
  Duration durationOperation;
  String comment;
  String problem;
  List<int> linesEdit;

  OperationFrd({
    required this.id,
    required this.name,
    required this.beginDate,
    required this.durationOperation,
    required this.comment,
    required this.problem,
    required this.linesEdit,
  });

  factory OperationFrd.initial() {
    return OperationFrd(
      id: 0,
      name: '',
      beginDate: DateTime.now(),
      durationOperation: const Duration(hours: 0, minutes: 0, seconds: 0),
      comment: '',
      problem: '',
      linesEdit: [1, 1, 1],
    );
  }

  factory OperationFrd.fromJson(Map<String, dynamic> data) {
    return OperationFrd(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      beginDate: data['beginDate'] == null
          ? DateTime.now()
          : DateTime.parse(data['beginDate']),
      durationOperation: data['durationOperation'] != null
          ? Duration(
              hours: data['durationOperation']['hours'],
              minutes: data['durationOperation']['minutes'],
              seconds: data['durationOperation']['seconds'],
            )
          : Duration.zero,
      comment: data['comment'] ?? '',
      problem: data['problem'] ?? '',
      linesEdit:
          data['linesEdit'] != null ? List<int>.from(data['linesEdit']) : [],
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
      'linesEdit': linesEdit
    };
  }
}
