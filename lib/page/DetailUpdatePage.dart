import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';

import '../models/Usersensor.dart';
import 'MainPage.dart';

class DetailUpdatePage extends StatefulWidget {
  final Usersensor? usersensor;

  DetailUpdatePage(this.usersensor);

  @override
  _DetailUpdatePageState createState() => _DetailUpdatePageState();
}

class _DetailUpdatePageState extends State<DetailUpdatePage> {
  final TextEditingController _updateNameController = TextEditingController();
  String url = ApiConfig.baseUrl;

  void _updateDetails() {
    String updatedText = _updateNameController.text;
    if (updatedText.length >= 3) {
      _renameUserSensor(widget.usersensor!.userid, widget.usersensor!.sensorid, updatedText).then((updateSuccess) {
        if (updateSuccess) {
          _goToMainPage(widget.usersensor!.userid);
        }
      });
    } else {
      print("3글자 이상의 입력이 필요합니다.");
    }
  }

  Future<bool> _renameUserSensor(String userid, String sensorid, String name) async {
    final response = await http.post(
      Uri.parse('$url/usersensor/rename'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userid': userid, 'sensorid': sensorid, 'name': name}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];

      return result;
    } else {
      print("이름 변경 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usersensor!.sensorid),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _updateNameController,
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              maxLength: 20,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateDetails,
              child: Text('수정하기'),
            ),
          ],
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