class Usersensor {
  final int id;
  final String userid;
  final String sensorid;
  final int code;
  final int checkcode;
  final int direct;
  final DateTime codetime;
  final int state;

  Usersensor({
    required this.id,
    required this.userid,
    required this.sensorid,
    required this.code,
    required this.checkcode,
    required this.direct,
    required this.codetime,
    required this.state
  });

  factory Usersensor.fromJson(Map<String, dynamic> json) {
    return Usersensor(
      id: json['id'] is int ? json['id'] : int.parse(json['id'] ?? '0'),
      userid: json['userid'],
      sensorid: json['sensorid'],
      code: json['code'] is int ? json['code'] : int.parse(json['code'] ?? '0'),
      checkcode: json['checkcode'] is int ? json['checkcode'] : int.parse(json['checkcode'] ?? '0'),
      direct: json['direct'] is int ? json['direct'] : int.parse(json['direct'] ?? '0'),
      codetime: DateTime.parse(json['codetime']),
      state: json['state'] is int ? json['state'] : int.parse(json['state'] ?? '0'),
    );
  }
}