import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:team2/config/ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'package:team2/theme/Colors.dart';

import '../models/Sensorlog.dart';
import '../models/User.dart';
import '../models/Usersensor.dart';
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

  @override
  void initState() {
    super.initState();
    fetchSensorlogData();
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
        throw Exception('데이터가 비어 있습니다.');
      }
    } else {
      throw Exception('서버로부터 데이터를 읽어오는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usersensor.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: blueStyle4,
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRow("문 열림 여부", doorState, "열림", "닫힘"),
                  _buildRow("시동 켜짐 여부", startState, "켜짐", "꺼짐"),
                  _buildRow("인체 감지 여부", personState, "감지", "없음"),
                  _buildRowInt("속도", speedState),
                ],
              ),
            ),
            SizedBox(height: 12.0),
            ListTile(
              title: Text('현재 위치 조회'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage(usersensor: widget.usersensor, user: widget.user)),
                );
              },
            ),
            ListTile(
              title: Text('로그 기록 조회'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPage(usersensor: widget.usersensor, user: widget.user)),
                );
              },
            ),
            ListTile(
              title: Text('기기 이름 변경'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailUpdatePage(widget.usersensor, widget.user)),
                );
              },
            ),
            ListTile(
              title: Text('그래프 조회'),
            ),
          ],
        ),
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
              color: blueStyle3,
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
              color: blueStyle3,
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
}