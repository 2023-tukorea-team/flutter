import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:team2/config/ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'package:team2/theme/Colors.dart';

import '../models/Sensorlog.dart';
import '../models/User.dart';
import '../models/Usersensor.dart';
import 'BottomBar.dart';
import 'ChartPage.dart';
import 'DetailPage.dart';
import 'DetailUpdatePage.dart';
import 'MapPage.dart';


class DetailListPage extends StatefulWidget {
  final Usersensor usersensor;
  final User user;

  DetailListPage({required this.usersensor, required this.user});

  @override
  _DetailListPageState createState() => _DetailListPageState();
}

class _DetailListPageState extends State<DetailListPage> {
  String url = ApiConfig.baseUrl;
  DateTime? lastBackPressedTime;
  bool doorState = false;
  bool startState = false;
  bool personState = false;
  int speedState = 0;
  Timer? _timer;

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

  Future<bool> deleteData(String userid, String sensorid) async {
    final response = await http.post(
      Uri.parse('$url/usersensor/delete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': userid, 'sensorid': sensorid}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];
      print(result);
      print(description);
      return result;
    } else {
      print("삭제 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usersensor.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                " 최근 내차 정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: whiteStyle2,
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRow("문 닫힘 여부", doorState, "닫힘", "열림"),
                    _buildRow("시동 켜짐 여부", startState, "켜짐", "꺼짐"),
                    _buildRow("인체 감지 여부", personState, "감지", "없음"),
                    _buildRowInt("속도", speedState),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              Text(
                " 조회",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 4.0),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey, width: 1.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_on),
                      tileColor: whiteStyle2,
                      title: Text('현재 위치 조회'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage(usersensor: widget.usersensor, user: widget.user)),
                        );
                      },
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Icon(Icons.history),
                      tileColor: whiteStyle2,
                      title: Text('로그 기록 조회'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailPage(usersensor: widget.usersensor, user: widget.user)),
                        );
                      },
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Icon(Icons.timeline),
                      tileColor: whiteStyle2,
                      title: Text('그래프 조회'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChartPage(usersensor: widget.usersensor, user: widget.user)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              Text(
                " 기기 관리",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 4.0),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey, width: 1.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit),
                      tileColor: whiteStyle2,
                      title: Text('기기 이름 변경'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailUpdatePage(widget.usersensor, widget.user)),
                        );
                      },
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('기기 삭제'),
                      onTap: () {
                        deleteData(widget.usersensor.userid, widget.usersensor.sensorid).then((deleteSuccess) {
                          if (deleteSuccess) {
                            _goToMainPage(widget.user);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Divider(
        color: whiteStyle3,
        thickness: 1,
        height: 0,
      ),
    );
  }

  Widget _buildRow(String leftText, bool isOpen, String s1, String s2) {
    Color textColor = isOpen ? Colors.red : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whiteStyle1,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(minWidth: 80),
            child: Text(
              isOpen ? s1 : s2,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowInt(String leftText, int s1) {
    Color textColor = s1 > 0 ? Colors.red : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whiteStyle1,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(minWidth: 80),
            child: Text(
              speedState.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _goToMainPage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomBar(user: user)),
    );
  }
}