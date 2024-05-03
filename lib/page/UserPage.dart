// 유저 페이지

// 이름
// 전화번호
// 이메일

// 개인 정보 수정
// 로그아웃
// 회원 탈퇴

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/page/ChangePwPage.dart';

import '../models/User.dart';
import 'AddSensorPage.dart';
import '../config/ApiConfig.dart';
import 'DetailPage.dart';
import '../models/Usersensor.dart';
import 'LoginPage.dart';

class UserPage extends StatefulWidget {
  final User user;
  UserPage({required this.user});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String url = ApiConfig.baseUrl;
  DateTime? lastBackPressedTime;

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

  Future<bool> withdraw(String id) async {
    final response = await http.post(
      Uri.parse('$url/user/withdraw'),
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
      print("회원 탈퇴 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      body: WillPopScope(
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
            return false; // 뒤로가기 버튼을 무시하고 스낵바 표시
          }
          SystemNavigator.pop();
          return true; // 2번째 뒤로가기 버튼을 누르면 앱 종료
        },
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('비밀번호 변경'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePwPage(userid: widget.user.id),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('로그아웃'),
              onTap: _logout,
            ),
            ListTile(
              title: Text('회원 탈퇴'),
              onTap: _withdraw,
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    bool islogout = await logout(widget.user.id);
    print(islogout);
    if (islogout) {
      _showSuccessDialog("로그아웃 성공", "로그아웃에 성공했습니다");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃에 실패했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _withdraw() async {
    bool iswithdraw = await withdraw(widget.user.id);
    print(iswithdraw);
    if (iswithdraw) {
      _showSuccessDialog("회원탈퇴 성공", "그동안 앱을 이용해주셔서 감사합니다");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원탈퇴에 실패했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }
}