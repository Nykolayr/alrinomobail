class Divisition {
  String name;
  List<String> positions;
  String city;

  Divisition({
    required this.name,
    required this.positions,
    required this.city,
  });
  factory Divisition.fromJson(Map<String, dynamic> data) {
    
    List<dynamic> positions = [];
    if (data['positions'] != null) {
      if (data['positions'] is String) {
        positions = data['positions'].split(',');
      }
      if (data['positions'] is List) {
        positions = data['positions'];
      }
    }

    return Divisition(
      name: data['name'] ?? '',
      positions: List<String>.from(positions),
      city: data['city'] ?? '',
    );
  }

  /// класс подразделения для ФРД, ФРХ, СЗ.

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'positions': positions.join(','),
      'city': city,
    };
  }

  factory Divisition.initial() {
    return Divisition(
      name: '',
      positions: [],
      city: '',
    );
  }
}
