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

import '../models/User.dart';
import '../theme/Colors.dart';
import '../config/ApiConfig.dart';
import 'ChangePwPage.dart';
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
    return WillPopScope(
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
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("마이 페이지"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  " 내 정보",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 8.0),
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${widget.user.name}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  "${widget.user.email}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  formatPhoneNumber("${widget.user.phone}"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                Text(
                  " 계정 관리",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.vpn_key),
                        tileColor: whiteStyle2,
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
                      _buildDivider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        tileColor: whiteStyle2,
                        title: Text('로그아웃'),
                        onTap: _logout,
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: Icon(Icons.delete),
                        tileColor: whiteStyle2,
                        title: Text('회원 탈퇴'),
                        onTap: _showConfirmationDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Divider(
        color: whiteStyle3,
        thickness: 1,
        height: 0,
      ),
    );
  }

  String formatPhoneNumber(String phone) {
    String formatted = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (formatted.length == 11) {
      return '${formatted.substring(0, 3)}-${formatted.substring(3, 7)}-${formatted.substring(7)}';
    } else {
      return phone;
    }
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
          backgroundColor: dialogback,
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
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(dialogback),
                backgroundColor: MaterialStateProperty.all<Color>(dialogyes),
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
                foregroundColor: MaterialStateProperty.all<Color>(dialogback),
                backgroundColor: MaterialStateProperty.all<Color>(dialogno),
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
          backgroundColor: dialogback,
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
                foregroundColor: MaterialStateProperty.all<Color>(dialogback),
                backgroundColor: MaterialStateProperty.all<Color>(dialogyes),
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