import 'dart:async';
import 'dart:convert';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:team2/theme/Colors.dart';

import '../models/User.dart';
import '../config/ApiConfig.dart';
import '../models/Usersensor.dart';

class ChartPage extends StatefulWidget {
  final Usersensor usersensor;
  final User user;

  ChartPage({required this.usersensor, required this.user});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String url = ApiConfig.baseUrl;
  List<_ChartData> leftData = [];
  List<_ChartData> rightData = [];
  String leftString = '';
  String rightString = '';
  Timer? timer;
  bool showFirstData = true;
  double leftMax = 10;
  double rightMax = 10;

  Future<bool> getSensorData(String id) async {
    final response = await http.post(
      Uri.parse('$url/sensor/chart/get'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      leftString = jsonData['leftdata'];
      rightString = jsonData['rightdata'];
      setState(() {
        leftData = _generateChartData(leftString);
        rightData = _generateChartData(rightString);
      });
      return true;
    } else {
      print("서버로부터 데이터를 가져오는 중 오류가 발생했습니다. (${response.statusCode})");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getSensorData(widget.usersensor.sensorid);
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      getSensorData(widget.usersensor.sensorid);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<_ChartData> _generateChartData(String dataString) {
    List<String> dataList = dataString.replaceAll(RegExp(r'[\[\] ]'), '').split(',');
    List<_ChartData> data = [];
    for (int i = 0; i < dataList.length; i++) {
      data.add(_ChartData(i + 1, double.parse(dataList[i])));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('실시간 그래프'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: blackStyle1, width: 1),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        //color: greyStyle1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "왼쪽 센서 그래프",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: blueStyle5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SfCartesianChart(
                        plotAreaBackgroundColor: whiteStyle3,
                        primaryXAxis: NumericAxis(
                          isVisible: false,
                          minimum: -2,
                          maximum: 103,
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          labelFormat: '',
                          minimum: -0.5,
                        ),
                        series: <LineSeries<_ChartData, int>>[
                          LineSeries<_ChartData, int>(
                            dataSource: leftData,
                            xValueMapper: (_ChartData data, _) => data.x,
                            yValueMapper: (_ChartData data, _) => data.y,
                            color: blackStyle1,
                            animationDuration: 0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: blackStyle1, width: 1),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        //color: greyStyle1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "오른쪽 센서 그래프",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: blueStyle5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SfCartesianChart(
                        plotAreaBackgroundColor: whiteStyle3,
                        primaryXAxis: NumericAxis(
                          isVisible: false,
                          minimum: -2,
                          maximum: 103,
                        ),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          labelFormat: '',
                          minimum: -0.5,
                        ),
                        series: <LineSeries<_ChartData, int>>[
                          LineSeries<_ChartData, int>(
                            dataSource: rightData,
                            xValueMapper: (_ChartData data, _) => data.x,
                            yValueMapper: (_ChartData data, _) => data.y,
                            color: blackStyle1,
                            animationDuration: 0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final int x;
  final double y;
}