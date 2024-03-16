class Sensorlog {
  final String id;
  final int start;
  final int door;
  final int person;
  final int speed;
  final int warning;
  final DateTime logtime;

  Sensorlog({
    required this.id,
    required this.start,
    required this.door,
    required this.person,
    required this.speed,
    required this.warning,
    required this.logtime
  });

  factory Sensorlog.fromJson(Map<String, dynamic> json) {
    return Sensorlog(
      id: json['id'],
      start: json['start'] is int ? json['start'] : int.parse(json['start'] ?? '0'),
      door: json['door'] is int ? json['door'] : int.parse(json['door'] ?? '0'),
      person: json['person'] is int ? json['person'] : int.parse(json['person'] ?? '0'),
      speed: json['speed'] is int ? json['speed'] : int.parse(json['speed'] ?? '0'),
      warning: json['warning'] is int ? json['warning'] : int.parse(json['warning'] ?? '0'),
      logtime: DateTime.parse(json['logtime']),
    );
  }
}