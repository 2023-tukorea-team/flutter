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

class LogPage extends StatefulWidget {
  final Sensorlog sensorlog;

  LogPage({required this.sensorlog});

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteStyle1,
      appBar: AppBar(
        backgroundColor: whiteStyle1,
        title: Text('로그 기록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.blueGrey, width: 1),
            ),
            color: blueStyle4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    ' - 로그 전송 시간 : ${formatDateTime(widget.sensorlog.logtime)}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  title: Text(
                    ' - ${widget.sensorlog.start == 0 ? '시동 꺼짐' : '시동 켜짐'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  title: Text(
                    ' - ${widget.sensorlog.door == 0 ? '문 닫힘' : '문 열림'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  title: Text(
                    ' - ${widget.sensorlog.person == 0 ? '인체 감지 없음' : '인체 감지 됨'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  title: Text(
                    ' - 속도 : ${widget.sensorlog.speed}km/h',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ListTile(
                  title: Text(
                    ' - 특이사항 : ${widget.sensorlog.warning == 0 ? '없음' : '인체 감지 알림 전송'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}