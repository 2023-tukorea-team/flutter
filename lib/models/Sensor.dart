class Sensor {
  final int sid;
  final String id;
  final DateTime logtime;
  final double latitude;
  final double longitude;

  Sensor({
    required this.sid,
    required this.id,
    required this.logtime,
    required this.latitude,
    required this.longitude
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sid: json['sid'],
      id: json['id'],
      logtime: DateTime.parse(json['logtime']),
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}