class FrdHystory {
  int id;
  String name;
  String pathName;
  String year;
  String month;
  String org;
  String div;
  DateTime begin;
  DateTime end;
  String post;
  String phone;

  FrdHystory({
    required this.id,
    required this.name,
    required this.pathName,
    required this.year,
    required this.month,
    required this.org,
    required this.div,
    required this.begin,
    required this.end,
    required this.post,
    required this.phone,
  });

  factory FrdHystory.fromJson(Map<String, dynamic> data) {
    return FrdHystory(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      pathName: data['pathName'] ?? '',
      year: data['year'] ?? '',
      month: data['month'] ?? '',
      org: data['org'] ?? '',
      div: data['div'] ?? '',
      begin: data['begin'] == null
          ? DateTime.now()
          : DateTime.parse(data['begin']),
      end: data['end'] == null ? DateTime.now() : DateTime.parse(data['end']),
      post: data['post'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pathName': pathName,
      'year': year,
      'month': month,
      'org': org,
      'div': div,
      'begin': begin.toIso8601String(),
      'end': end.toIso8601String(),
      'post': post,
      'phone': phone,
    };
  }

  factory FrdHystory.initial() {
    return FrdHystory(
      id: 0,
      name: '',
      pathName: '',
      year: '',
      month: '',
      org: '',
      div: '',
      begin: DateTime.now(),
      end: DateTime.now(),
      post: '',
      phone: '',
    );
  }
}
