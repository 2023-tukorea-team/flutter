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
import '../theme/Colors.dart';
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
      backgroundColor: whiteStyle1,
      appBar: AppBar(
        backgroundColor: whiteStyle1,
        title: Text('내 정보'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.blueGrey, width: 1),
              ),
              color: blueStyle4,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        ' - 아이디 : ${widget.user.id}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        ' - 이름 : ${widget.user.name}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        ' - 이메일 : ${widget.user.email}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        ' - 전화번호 : ${widget.user.phone}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: WillPopScope(
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
                  return false;
                }
                SystemNavigator.pop();
                return true;
              },
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text('비밀번호 변경'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePwPage(user: widget.user),
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
                    onTap: _showConfirmationDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
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
    print("withdraw2");
    bool iswithdraw = await withdraw(widget.user.id);
    if (iswithdraw) {
      _showSuccessDialog("회원 탈퇴 성공", "그동안 앱을 이용해 주셔서 감사합니다");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원탈퇴에 실패했습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: blueStyle1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
              '회원 탈퇴',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 32,
              )
          ),
          content: Text(
            '정말로 회원 탈퇴하겠습니까?',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _withdraw();
                print("withdraw1");
                Navigator.of(context).pop();
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
                '네',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              child: Text(
                '아니요',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: blueStyle1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 32,
              )
          ),
          content: Text(
            content,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
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
      },
    );
  }
}