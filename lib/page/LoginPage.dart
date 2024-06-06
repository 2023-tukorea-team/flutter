import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team2/provider/UserProvider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:team2/theme/Colors.dart';

import '../config/ApiConfig.dart';
import '../models/User.dart';
import 'BottomBar.dart';
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
            android: AndroidNotificationDetails(
              'high_importance_channel', 'high_importance_nofitication',
              importance: Importance.max,
            ),
          ),
        );
      }
    });
    super.initState();
  }

  Future<bool> requestNotificationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: blueStyle1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                  '권한 설정 필요',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  )
              ),
              content: Text(
                '알림에 대한 권한 설정을 설정해주세요',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        blueStyle4),
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
      User user = await fetchUserData(id);
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      _goToMainPage(user);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: blueStyle1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(
                '로그인 실패',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                )
            ),
            content: Text(
              '아이디 또는 비밀번호가 올바르지 않습니다.',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black),
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

  void _goToMainPage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomBar(user: user)),
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
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 3/4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              blueStyle5,
              blueStyle6,
            ],
            stops: [0.2, 0.8],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 100.0),
                Center(
                  child: Text(
                    'My Car',
                    style: TextStyle(
                      color: whiteStyle2,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 100.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteStyle1,
                      hintText: '아이디를 입력하세요',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: blackStyle1,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40,
                      ),
                      prefixStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: whiteStyle1,
                      hintText: '비밀번호를 입력하세요',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: blackStyle1,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40,
                      ),
                      prefixStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: TextStyle(fontSize: 18),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 40.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueStyle5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        color: whiteStyle2,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _goToSignUpPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueStyle5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        color: whiteStyle2,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}