import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';
import 'package:team2/config/NaverMapConfig.dart';

import '../models/Sensor.dart';
import '../models/Sensorlog.dart';
import '../models/User.dart';
import '../models/Usersensor.dart';
import '../theme/Colors.dart';
import 'SignupPage.dart';

class DashboardPage extends StatefulWidget {
  final Usersensor usersensor;
  final User user;

  DashboardPage({required this.usersensor, required this.user});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String url = ApiConfig.baseUrl;
  DateTime? lastBackPressedTime;
  bool doorState = false;
  bool startState = false;
  bool personState = false;
  int speedState = 0;
  Timer? _timer;
  String doorOpenImage = 'assets/images/free-icon-door-open.png';
  String doorCloseImage = 'assets/images/free-icon-door-close.png';
  String startOnImage = 'assets/images/free-icon-power-button-fill.png';
  String startOffImage = 'assets/images/free-icon-power-button-blank.png';
  String speedImage = 'assets/images/free-icon-speedometer.png';
  String personTrueImage = 'assets/images/free-icon-fill-person.png';
  String personFalseImage = 'assets/images/free-icon-blank-person.png';

  @override
  void initState() {
    super.initState();
    fetchSensorlogData();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchSensorlogData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchSensorlogData() async {
    final response = await http.post(
      Uri.parse('$url/sensor/logrequest1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': widget.usersensor.sensorid}),
    );
    if (response.statusCode == 200) {
      List<dynamic> sensorlogJsonList = json.decode(response.body);
      if (sensorlogJsonList.isNotEmpty) {
        Sensorlog s = Sensorlog.fromJson(sensorlogJsonList.first);
        setState(() {
          doorState = (s.door == 1) ? true : false;
          startState = (s.start == 1) ? true : false;
          personState = (s.person == 1) ? true : false;
          speedState = s.speed;
        });
      } else {
        setState(() {
          doorState = false;
          startState = false;
          personState = false;
          speedState = 0;
        });
      }
    } else {
      throw Exception('서버로부터 데이터를 읽어오는 데 실패했습니다.');
    }
  }

  Future<bool> openWindow(String userid, String sensorid) async {
    final response = await http.post(
      Uri.parse('$url/usersensor/window/open'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userid': userid, 'sensorid': sensorid}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];

      return result;
    } else {
      print("요청 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<bool> closeWindow(String userid, String sensorid) async {
    final response = await http.post(
      Uri.parse('$url/usersensor/window/close'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userid': userid, 'sensorid': sensorid}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];

      return result;
    } else {
      print("요청 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  void openWindowRequest() async {
    bool result = await openWindow(widget.usersensor.userid, widget.usersensor.sensorid);
    if (result) {
      _showSuccessDialog("창문 열기", "창문 열기 요청에 성공했습니다.");
    } else {
      _showSuccessDialog("창문 열기 실패", "창문 열기 요청에 실패했습니다.");
    }
  }

  void closeWindowRequest() async {
    bool result = await closeWindow(widget.usersensor.userid, widget.usersensor.sensorid);
    if (result) {
      _showSuccessDialog("창문 닫기", "창문 닫기 요청에 성공했습니다.");
    } else {
      _showSuccessDialog("창문 닫기 실패", "창문 닫기 요청에 실패했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대시보드 조회'),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildGridItem2(doorState, doorOpenImage, doorCloseImage, "문 열림", "문 닫힘"),
                  _buildGridItem2(startState, startOffImage, startOnImage, "시동 꺼짐", "시동 켜짐"),
                  _buildGridItem1(speedImage, speedState.toString() + 'km/h'),
                  _buildGridItem2(personState, personFalseImage, personTrueImage, "사람 없음", "사람 있음"),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                    child: ElevatedButton(
                      onPressed: () => openWindowRequest(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueStyle3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '창문 열기',
                          style: TextStyle(
                            color: whiteStyle2,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                    child: ElevatedButton(
                      onPressed: () => closeWindowRequest(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueStyle3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '창문 닫기',
                          style: TextStyle(
                            color: whiteStyle2,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem1(String imagePath, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(16),
        color: whiteStyle2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 80,
            height: 80,
          ),
          SizedBox(height: 20),
          Text(label, style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildGridItem2(bool State, String imagePath1, String imagePath2, String trueText, String falseText) {
    String selectedImagePath = State ? imagePath2 : imagePath1;
    String labelText = State ? falseText : trueText;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(16),
        color: whiteStyle2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            selectedImagePath,
            width: 80,
            height: 80,
          ),
          SizedBox(height: 20),
          Text(labelText, style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogback,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 32,
              )
          ),
          content: Text(
            content,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(dialogback),
                backgroundColor: MaterialStateProperty.all<Color>(dialogyes),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}