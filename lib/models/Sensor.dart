class Sensor {
  final int sid;
  final String id;
  final DateTime logtime;

  Sensor({
    required this.sid,
    required this.id,
    required this.logtime
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sid: json['sid'],
      id: json['id'],
      logtime: DateTime.parse(json['logtime']),
    );
  }
}