import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';

import '../models/User.dart';
import '../theme/Colors.dart';
import 'BottomBar.dart';
import 'MainPage.dart';

class AddSensorPage extends StatefulWidget {
  final User user;
  AddSensorPage({required this.user});

  @override
  _AddSensorPageState createState() => _AddSensorPageState();
}

class _AddSensorPageState extends State<AddSensorPage> {
  final TextEditingController _macAddressController = TextEditingController();
  final TextEditingController _verificationController = TextEditingController();
  int _remainingTime = 180; // 3분 = 180초
  bool _isMacForm = false;
  Timer? _timer;
  String url = ApiConfig.baseUrl;
  String? sensorid = '';
  bool _isCheckMacAddress = false; // 인증번호 입력 창 보이게 하기


  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  Future<bool> _checkMacAddress(String userid, String sensorid) async {
    final response = await http.post(
      Uri.parse('$url/sensor/select'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': userid, 'sensorid': sensorid}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("맥 주소 확인 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<int> _checkMacAddressCode(String userid, String sensorid,
      String maccode) async {
    final response = await http.post(
      Uri.parse('$url/sensor/checkcode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userid': userid, 'sensorid': sensorid, 'code': maccode}),
    );

    if (response.statusCode == 200) {
      int returnNumber;
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool code = jsonData['code'];
      bool time = jsonData['time'];
      bool result = jsonData['result'];
      String description = jsonData['description'];

      print(code);
      print(time);

      if (result) {
        returnNumber = 1; // 정상적인 성공
      } else {
        if (!time) {
          returnNumber = 2; // 시간 만료
        } else {
          if (!code) { // 시간은 맞으나 코드 틀림
            returnNumber = 3;
          } else { // 이럴리가 없는데??
            returnNumber = 4;
          }
        }
      }
      return returnNumber;
    } else {
      print("맥 주소 연결 인증 중 오류가 발생했습니다 (${response.statusCode})");
      return 0;
    }
  }

  void _goToMainPage(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BottomBar(user: user)),
    );
  }

  bool validateMacAddress(String mac) {
    RegExp regex = RegExp(
      r'^([0-9a-f]{2}[:-]){5}([0-9a-f]{2})$',
    );
    return regex.hasMatch(mac);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteStyle1,
      appBar: AppBar(
        backgroundColor: whiteStyle1,
        title: Text('기기 연결'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _macAddressController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: greyStyle1,
                        hintText: '맥주소를 입력하세요',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        prefixStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(fontSize: 18),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-f0-9:]')),
                        // 영어와 숫자만 허용
                        LengthLimitingTextInputFormatter(17),
                        // 최대 길이 설정
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        // 공백 입력 방지
                      ],
                      onChanged: (value) {
                        // 입력값이 변경될 때마다 제약조건을 확인하여 상태 업데이트
                        setState(() {
                          String mac = _macAddressController.text.trim();
                          _isMacForm = validateMacAddress(mac);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: _isMacForm
                        ? () async {
                      sensorid = _macAddressController.text.trim();
                      bool isAvailable = await _checkMacAddress(
                          widget.user.id, sensorid!);
                      setState(() {
                        _isCheckMacAddress = isAvailable;
                        _startTimer();
                        _remainingTime = 180;
                      });
                      if (!_isCheckMacAddress) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('등록되지 않은 기기입니다'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueStyle4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                        '인증번호 전송',
                        style: TextStyle(
                            color: blackStyle1,
                            fontWeight: FontWeight.w400,
                            fontSize: 18
                        )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Flexible(
                    child: _isMacForm // true면 사용 가능한 양식, false면 사용 불가능한 양식
                        ? Text(
                      '양식에 맞는 맥주소입니다',
                      style: TextStyle(color: Colors.green),
                    )
                        : Text(
                      '다음과 같은 형식으로 입력해주세요\n예) d8:3a:dd:20:b2:d5',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              if (_isCheckMacAddress) ...[
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _verificationController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: greyStyle1,
                          hintText: '인증번호를 입력하세요',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none
                          ),
                          prefixStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        style: TextStyle(fontSize: 18),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      onPressed: () async {
                        String code = _verificationController.text.trim();
                        print('${widget.user.id}, ${sensorid}, ${code}');
                        int codeNumber = await _checkMacAddressCode(widget
                            .user.id, sensorid!, code);
                        print(codeNumber);
                        switch (codeNumber) {
                          case 1: // 성공 메세지 반환 + 메인 페이지로 이동
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: blueStyle1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  title: Text(
                                      '성공',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 32,
                                      )
                                  ),
                                  content: Text(
                                    '기기 연결에 성공했습니다',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                  actions: <Widget> [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _goToMainPage(widget.user);
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
                            break;
                          case 2: // 시간 만료
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('인증 시간이 만료되었습니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            break;
                          case 3: // 시간은 맞으나 코드 틀림
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('인증 코드가 일치하지 않습니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            break;
                          case 4: // 이럴리가 없는데
                            break;
                          case 0: // 서버 연결 오류
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('서버와의 통신 과정에서 오류가 발생했습니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            break;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueStyle4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                          '인증번호 입력',
                          style: TextStyle(
                              color: blackStyle1,
                              fontWeight: FontWeight.w400,
                              fontSize: 18
                          )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _remainingTime > 0
                          ? '남은 시간: ${_remainingTime ~/ 60}:${_remainingTime % 60 < 10 ? '0' : ''}${_remainingTime % 60}'
                          : '시간이 만료되었습니다',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: _remainingTime > 0 ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _cancelTimer();

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_remainingTime < 1) {
          _cancelTimer();
        } else {
          _remainingTime -= 1;
        }
      });
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}