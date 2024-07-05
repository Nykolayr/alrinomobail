class Process {
  int id;
  String activity;
  DateTime date;
  String direction;
  String station;
  String process;
  String operation;
  String executor;
  String driver;
  String personhour;

  Process({
    required this.id,
    required this.activity,
    required this.date,
    required this.direction,
    required this.station,
    required this.process,
    required this.operation,
    required this.executor,
    required this.driver,
    required this.personhour,
  });

  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      id: json['id'] ?? 0,
      activity: json['activity'] ?? '',
      direction: json['direction'] ?? '',
      station: json['station'] ?? '',
      process: json['process'] ?? '',
      operation: json['operation'] ?? '',
      executor: json['executor'] ?? '',
      driver: json['driver'] ?? '',
      personhour: json['personhour'] ?? '',
      date:
          json['date'] == null ? DateTime.now() : DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity': activity,
      'date': date.toString(),
      'direction': direction,
      'station': station,
      'process': process,
      'operation': operation,
      'executor': executor,
      'driver': driver,
      'personhour': personhour,
    };
  }

  factory Process.init() {
    return Process(
      id: 0,
      activity: '',
      date: DateTime.now(),
      direction: '',
      station: '',
      process: '',
      operation: '',
      executor: '',
      driver: '',
      personhour: '',
    );
  }
}
