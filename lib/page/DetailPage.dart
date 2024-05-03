import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';

import '../models/Sensorlog.dart';
import '../models/Usersensor.dart';
import 'DetailUpdatePage.dart';
import 'MainPage.dart';

class DetailPage extends StatefulWidget {
  final Usersensor? usersensor;

  DetailPage({this.usersensor});

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
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailUpdatePage(widget.usersensor)),
                    );
                  },
                  child: Text(widget.usersensor!.name),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteData(widget.usersensor!.userid, widget.usersensor!.sensorid).then((deleteSuccess) {
                    if (deleteSuccess) {
                      _goToMainPage(widget.usersensor!.userid);
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
                child: ListTile(
                  title: Text('${sensorlog.logtime}'),
                  subtitle: Row(
                    children: [
                      _buildSensorStatus('시동 ', sensorlog.start),
                      _buildSensorStatus('문잠금 ', sensorlog.door),
                      _buildSensorStatus('사람 ', sensorlog.person),
                      Text('속도:${sensorlog.speed} '),
                      _buildSensorStatusWarning('경고 ', sensorlog.warning),
                    ],
                  ),
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
                child: ListTile(
                  title: Text('${sensorlog.logtime}'),
                  subtitle: Row(
                    children: [
                      _buildSensorStatus('시동 ', sensorlog.start),
                      _buildSensorStatus('문잠금 ', sensorlog.door),
                      _buildSensorStatus('사람 ', sensorlog.person),
                      Text('속도:${sensorlog.speed} '),
                      _buildSensorStatusWarning('경고 ', sensorlog.warning),
                    ],
                  ),
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
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  void _goToMainPage(String userid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage(userid: userid)),
    );
  }
}