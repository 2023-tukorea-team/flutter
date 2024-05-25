import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/page/DetailUpdatePage.dart';

import '../config/ApiConfig.dart';
import '../models/User.dart';
import '../theme/Colors.dart';
import 'BottomBar.dart';
import 'LoginPage.dart';
import 'MainPage.dart';

class ChangePwPage extends StatefulWidget {
  final User user;

  ChangePwPage({required this.user});

  @override
  _ChangePwPageState createState() => _ChangePwPageState();
}

class _ChangePwPageState extends State<ChangePwPage> {
  final TextEditingController _ChangePwController = TextEditingController();
  String url = ApiConfig.baseUrl;

  void _changePw() {
    String updatedText = _ChangePwController.text;
    if (updatedText.length >= 6) {
      _ChangePwCheck(widget.user.id, updatedText).then((updateSuccess) {
        if (updateSuccess) {
          showDialog(
            context: context, builder: (BuildContext) {
            return AlertDialog(
              backgroundColor: blueStyle1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                  '비밀번호 변경 성공',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  )
              ),
              content: Text(
                '비밀번호가 성공적으로 변경되었습니다',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _goToMainPage(widget.user.id);
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    backgroundColor: MaterialStateProperty.all<Color>(blueStyle4),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            );
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('6글자 이상 입력해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
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
                filled: true,
                fillColor: greyStyle1,
                hintText: '변경할 비밀번호를 입력하세요',
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
              obscureText: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(12),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              '6~12 글자로 입력해주세요',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _changePw,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueStyle3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '비밀번호 변경',
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

  void _goToMainPage(String userid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomBar(user: widget.user)),
    );
  }


}
