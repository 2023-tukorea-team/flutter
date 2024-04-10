import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'AddSensorPage.dart';
import '../config/ApiConfig.dart';
import 'DetailPage.dart';
import '../models/Usersensor.dart';
import 'LoginPage.dart';

class MainPage extends StatefulWidget {
  final String userid;
  MainPage({required this.userid});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Usersensor> _usersensorData = [];
  String url = ApiConfig.baseUrl;
  DateTime? lastBackPressedTime;

  @override
  void initState() {
    super.initState();
    fetchUsersensorData();
  }

  Future<void> fetchUsersensorData() async {
    final response = await http.post(
      Uri.parse('$url/usersensor/list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': widget.userid}),
    );
    if (response.statusCode == 200) {
      List<dynamic> usersensorJsonList = json.decode(response.body);
      List<Usersensor> newData = usersensorJsonList.map((json) => Usersensor.fromJson(json)).toList();
      setState(() {
        _usersensorData = newData;
      });
    } else {
      throw Exception('서버로부터 데이터를 읽어오는 데 실패했습니다.');
    }
  }

  Future<bool> logout(String id) async {
    final response = await http.post(
      Uri.parse('$url/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
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
      print("로그아웃 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastBackPressedTime == null || now.difference(lastBackPressedTime!) > Duration(seconds: 3)) {
          lastBackPressedTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('한 번 더 누르면 종료됩니다.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('연결된 기기'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _goToAddSensorPage(widget.userid);
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  fetchUsersensorData();
                });
              },
            )
          ],
        ),
        body: _buildUserSensorList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            bool islogout = await logout(widget.userid);
            print(islogout);
            if (islogout) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("로그아웃 성공"),
                    content: Text("로그아웃에 성공했습니다"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                                (Route<dynamic> route) => false,
                          );
                        },
                        child: Text("확인"),
                      ),
                    ],
                  );
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('로그아웃에 실패했습니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Icon(Icons.logout),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      )
    );
  }

  Widget _buildUserSensorList() {
    if (_usersensorData.isEmpty) {
      return Center(child: Text("등록된 기기가 없습니다!."));
    } else {
      return ListView.builder(
        itemCount: _usersensorData.length,
        itemBuilder: (context, index) {
          var usersensor = _usersensorData[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailPage(usersensor: usersensor)),
              );
            },
            child: Card(
              color: usersensor.state == 1 ? Color(0xFFFFCDD2) : null,
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          usersensor.state == 1 ? Icons.warning : Icons.panorama_fish_eye,
                          color: usersensor.state == 1 ? Colors.red : Colors.blueGrey,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '기기명 : ${usersensor.sensorid}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '마지막 접속 시간: ${usersensor.codetime}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _goToAddSensorPage(String userid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSensorPage(userid: userid)),
    );
  }
}
