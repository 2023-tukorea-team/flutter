import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/User.dart';
import '../theme/Colors.dart';
import 'AddSensorPage.dart';
import '../config/ApiConfig.dart';
import 'DetailListPage.dart';
import '../models/Usersensor.dart';

class MainPage extends StatefulWidget {
  final User user;
  MainPage({required this.user});

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
      body: jsonEncode({'userid': widget.user.id}),
    );
    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> usersensorJsonList = json.decode(responseBody);
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
        backgroundColor: whiteStyle1,
        appBar: AppBar(
          backgroundColor: whiteStyle1,
          title: Text('내 기기'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _goToAddSensorPage(widget.user);
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
      )
    );
  }

  Widget _buildUserSensorList() {
    if (_usersensorData.isEmpty) {
      return Center(
        child: Text(
          "기기를 등록해주세요",
          style: TextStyle(
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _usersensorData.length,
        itemBuilder: (context, index) {
          var usersensor = _usersensorData[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailListPage(usersensor: usersensor, user: widget.user)),
              );
            },
            child: Card(
              color: blueStyle4,
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blueGrey, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text(
                              '${usersensor.name}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: blackStyle1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text(
                              '연결한 시간: ${formatDateTime(usersensor.codetime)}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      usersensor.state == 1 ? Icons.warning : null,
                      color: usersensor.state == 1 ? Colors.red : null,
                      size: 32,
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

  void _goToAddSensorPage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSensorPage(user: user)),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}
