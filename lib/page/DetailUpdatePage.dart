import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';

import '../models/User.dart';
import '../models/Usersensor.dart';
import '../theme/Colors.dart';
import 'BottomBar.dart';
import 'MainPage.dart';

class DetailUpdatePage extends StatefulWidget {
  final Usersensor usersensor;
  final User user;

  DetailUpdatePage(this.usersensor, this.user);

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
          _goToMainPage(widget.user);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('3글자 이상 입력해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
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
        centerTitle: true,
        title : Text(
          '기기 이름 변경',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: whiteStyle2,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _updateNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: whiteStyle2,
                hintText: widget.usersensor.sensorid,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none
                ),
                prefixStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: TextStyle(fontSize: 18),
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              '3~20 글자로 입력해주세요',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _updateDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueStyle3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '수정하기',
                style: TextStyle(
                    color: blackStyle1,
                    fontWeight: FontWeight.w600,
                    fontSize: 20
                ),
              ),
            ),
          ],
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
}