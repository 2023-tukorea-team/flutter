import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Sensorlog.dart';
import '../theme/Colors.dart';

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
      appBar: AppBar(
        title: Text('로그 기록'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  _buildRowDate("로그 전송 시각", formatDateTime(widget.sensorlog.logtime)),
                  _buildRow("문 닫힘 여부", (widget.sensorlog.door == 1) ? true : false, "닫힘", "열림"),
                  _buildRow("시동 켜짐 여부", (widget.sensorlog.start == 1) ? true : false, "켜짐", "꺼짐"),
                  _buildRow("인체 감지 여부", (widget.sensorlog.person == 1) ? true : false, "감지", "없음"),
                  _buildRowInt("속도", widget.sensorlog.speed),
                  _buildRow("위험 감지 여부", (widget.sensorlog.warning == 1) ? true : false, "감지", "없음"),
                ],
              ),
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
              s1.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDate(String leftText, String s1) {
    Color textColor = Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Row 내에서 자식을 가운데 정렬
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whiteStyle1,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(minWidth: 80),
            child: Text(
              s1,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}