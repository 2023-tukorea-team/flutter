import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';

import '../models/User.dart';
import '../models/Usersensor.dart';
import '../theme/Colors.dart';
import 'BottomBar.dart';

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
  List<Usersensor> _usersensorData = [];

  @override
  void initState() {
    super.initState();
    getRecheckSensor(widget.user.id);
  }

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

  Future<bool> getRecheckSensor(String userid) async {
    final response = await http.post(
      Uri.parse('$url/usersensor/recheck/get'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': userid}),
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> usersensorJsonList = json.decode(responseBody);
      List<Usersensor> newData = usersensorJsonList.map((json) => Usersensor.fromJson(json)).toList();
      setState(() {
        _usersensorData = newData;
      });
      return true;
    } else {
      print("데이터를 가져 오는 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<bool> addRecheckSensor(String userid, String sensorid) async {
    final response = await http.post(
      Uri.parse('$url/usersensor/recheck/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': userid, 'sensorid' : sensorid}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      return result;
    } else {
      print("연결하는 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  void _reconnect(String userid, String sensorid) async {
    bool isReconnect = await addRecheckSensor(userid, sensorid);
    if (isReconnect) {
      _showSuccessDialog("연결 성공", "연결에 성공했습니다");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('연결에 실패했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
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
      appBar: AppBar(
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
                        fillColor: whiteStyle2,
                        hintText: '맥주소를 입력하세요',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        prefixStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(fontSize: 18),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-f0-9:]')),
                        LengthLimitingTextInputFormatter(17),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          String mac = _macAddressController.text.trim();
                          _isMacForm = validateMacAddress(mac);
                        });
                      },
                    )
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
                      backgroundColor: blueStyle3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                        '인증번호 전송',
                        style: TextStyle(
                            color: whiteStyle2,
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
                          fillColor: whiteStyle2,
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
                                        foregroundColor: MaterialStateProperty.all<Color>(whiteStyle2),
                                        backgroundColor: MaterialStateProperty.all<Color>(blueStyle5),
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
                        backgroundColor: blueStyle3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                          '인증번호 입력',
                          style: TextStyle(
                              color: whiteStyle2,
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
              SizedBox(height: 40.0),
              Text(
                " 이전에 연결했던 기기",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 4.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _usersensorData.length,
                itemBuilder: (context, index) {
                  final usersensor = _usersensorData[index];
                  return GestureDetector(
                    onTap: () {
                      _reconnect(usersensor.userid, usersensor.sensorid);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.symmetric(vertical: 4.0),
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
                                      usersensor.sensorid,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
                  MaterialPageRoute(builder: (context) => (BottomBar(user: widget.user))),
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