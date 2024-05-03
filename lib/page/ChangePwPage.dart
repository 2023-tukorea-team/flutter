import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/page/DetailUpdatePage.dart';

import '../config/ApiConfig.dart';
import 'LoginPage.dart';
import 'MainPage.dart';

class ChangePwPage extends StatefulWidget {
  final String userid;

  ChangePwPage({required this.userid});

  @override
  _ChangePwPageState createState() => _ChangePwPageState();
}

class _ChangePwPageState extends State<ChangePwPage> {
  final TextEditingController _ChangePwController = TextEditingController();
  String url = ApiConfig.baseUrl;

  void _changePw() {
    String updatedText = _ChangePwController.text;
    if (updatedText.length >= 6) {
      _ChangePwCheck(widget.userid, updatedText).then((updateSuccess) {
        if (updateSuccess) {
          _goToMainPage(widget.userid);
        }
      });
    } else {
      print("6글자 이상의 입력이 필요합니다.");
    }
  }

  Future<bool> _ChangePwCheck(String id, String pw) async {
    final response = await http.post(
      Uri.parse('$url/user/repw'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'id': id, 'pw': pw}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];

      return result;
    } else {
      print("비밀번호 변경 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ChangePwController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(12),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              maxLength: 12,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePw,
              child: Text('비밀번호 변경'),
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