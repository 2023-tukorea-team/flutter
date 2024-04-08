import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team2/provider/UserProvider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/ApiConfig.dart';
import '../models/User.dart';
import 'MainPage.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String url = ApiConfig.baseUrl;
  String? _token;
  bool _isIdAvailable = false;

  @override
  void initState() {
    super.initState();
    _retrieveFirebaseToken();
    requestNotificationPermission(context);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('high_importance_channel', 'high_importance_nofitication', importance: Importance.max,
            ),
          ),
        );
      }
    });
    super.initState();
  }

  Future<bool> requestNotificationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.notification.request();
    if(!status.isGranted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("권한 설정을 확인해주세요."),
              actions: [
                TextButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text('설정하기')),
              ],
            );
          });
      return false;
    }
    return true;
  }

  Future<void> _retrieveFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _token = token;
    });
  }

  Future<bool> _LoginAvailability(String id, String pw, String token) async {
    final response = await http.post(
      Uri.parse('$url/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'pw': pw, 'token': token}),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool check = jsonData['check'];
      bool emailcheck = jsonData['emailcheck'];
      bool phonecheck = jsonData['phonecheck'];
      bool token = jsonData['token'];
      String description = jsonData['description'];
      return check;
    } else {
      print("로그인 도중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<User> fetchUserData(String id) async {
    final response = await http.post(
      Uri.parse('$url/login/userinfo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('서버에서 유저 정보를 가져오는 데 실패했습니다.');
    }
  }

  Future<void> _login() async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();
    print("${id} ${password} ${_token}");
    _isIdAvailable = await _LoginAvailability(id, password, _token!);

    // 로그인 로직
    if (_isIdAvailable) {
      // 유저 정보 받아와서 provider에 저장
      User user = await fetchUserData(id);
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      // 메인페이지로 이동
      _goToMainPage(id);

    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그인 실패'),
            content: Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  void _goToMainPage(String userid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage(userid: userid)),
    );
  }

  void _goToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '아이디',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: _goToSignUpPage,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}