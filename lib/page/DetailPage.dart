import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:team2/config/ApiConfig.dart';

import '../models/Sensorlog.dart';
import '../models/User.dart';
import '../models/Usersensor.dart';
import '../theme/Colors.dart';
import 'BottomBar.dart';
import 'DetailUpdatePage.dart';
import 'LogPage.dart';

class DetailPage extends StatefulWidget {
  final Usersensor usersensor;
  final User user;

  DetailPage({required this.usersensor, required this.user});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String url = ApiConfig.baseUrl;
  late Future<List<Sensorlog>> _sensorlogFuture;

  @override
  void initState() {
    super.initState();
    _sensorlogFuture = fetchSensorlogData();
    readMessage();
  }

  Future<List<Sensorlog>> fetchSensorlogData() async {
    final response = await http.post(
      Uri.parse('$url/sensor/logrequest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': widget.usersensor?.sensorid}),
    );
    if (response.statusCode == 200) {
      List<dynamic> sensorlogJsonList = json.decode(response.body);
      return sensorlogJsonList.map((json) => Sensorlog.fromJson(json)).toList();
    } else {
      throw Exception('서버로부터 데이터를 읽어오는 데 실패했습니다.');
    }
  }

  Future<bool> readMessage() async {
    final response = await http.post(
      Uri.parse('$url/usersensor/readstate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': widget.usersensor?.userid, 'sensorid': widget.usersensor?.sensorid}),
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
      print("알림 상태 변환 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
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

  void refreshData() {
    setState(() {
      _sensorlogFuture = fetchSensorlogData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: whiteStyle1,
        appBar: AppBar(
          backgroundColor: whiteStyle1,
          title: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Text(
                    widget.usersensor!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteData(widget.usersensor!.userid, widget.usersensor!.sensorid).then((deleteSuccess) {
                    if (deleteSuccess) {
                      _goToMainPage(widget.user);
                    }
                  });
                }
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  refreshData();
                },
              ),
            ],
          ),
          bottom: TabBar(
            indicator: BoxDecoration(),
            labelColor: blueStyle3,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: '알림 기록'),
              Tab(text: '로그 기록'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlertLogTab(),
            _buildSensorLogTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertLogTab() {
    return FutureBuilder<List<Sensorlog>>(
      future: _sensorlogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final filteredLogs = snapshot.data!.where((log) => log.warning != 0).toList();
          if (filteredLogs.isEmpty) {
            return _buildNoLogsCard();
          }
          return ListView.builder(
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final sensorlog = filteredLogs[index];
              return Card(
                color: blueStyle4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blueGrey, width: 1),
                ),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      '${formatDateTime(sensorlog.logtime)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                  onTap: () {
                    _goToLogPage(sensorlog);
                  },
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSensorLogTab() {
    return FutureBuilder<List<Sensorlog>>(
      future: _sensorlogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return _buildNoLogsCard();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final sensorlog = snapshot.data![index];
              return Card(
                color: blueStyle4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blueGrey, width: 1),
                ),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      '${formatDateTime(sensorlog.logtime)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,),
                    ),
                  ),
                  onTap: () {
                    _goToLogPage(sensorlog);
                  },
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // 시동, 1
  Widget _buildSensorStatus(String name, int value) {
    return Text(
      name,
      style: TextStyle(
        color: value == 1 ? Colors.red : Colors.black45,
        fontWeight: value == 1 ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSensorStatusWarning(String name, int value) {
    return Text(
      '$name: $value',
      style: TextStyle(
        color: value != 0 ? Colors.red : Colors.black45,
        fontWeight: value == 1 ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildNoLogsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '저장된 기록이 없습니다',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }

  void _goToMainPage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomBar(user: user)),
    );
  }

  void _goToLogPage(Sensorlog sensorlog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogPage(sensorlog: sensorlog)),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}