import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:team2/theme/Colors.dart';

import '../config/ApiConfig.dart';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String url = ApiConfig.baseUrl;
  bool _isIdCheck = false;          // 아이디가 중복확인이 되었는지
  bool _isIdAvailable = false;      // 아이디 중복 확인
  bool _isIdLength = false;         // 아이디 자리 수 (6~12자)
  bool _isPasswordLength = false;   // 비밀번호 자리 수
  bool _isPasswordCheck = false;    // 비밀번호 일치 여부
  bool _isEmailCheck = false;       // 아이디가 중복확인이 되었는지
  bool _isEmailForm = false;        // 이메일 양식
  bool _isEmailAvailable = false;   // 이메일 중복 확인
  bool _isPhoneCheck = false;       // 아이디가 중복확인이 되었는지
  bool _isPhoneForm = false;        // 전화번호 양식
  bool _isPhoneAvailable = false;   // 전화번호 중복 확인

  Future<bool> _checkIdAvailability(String id) async {
    final response = await http.post(
      Uri.parse('$url/signup/checkid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];
      return result;
    } else {
      print("아이디 중복 확인 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<bool> _checkEmailAvailability(String email) async {
    final response = await http.post(
      Uri.parse('$url/signup/checkemail'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];
      return result;
    } else {
      print("이메일 중복 확인 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<bool> _checkPhoneAvailability(String phone) async {
    final response = await http.post(
      Uri.parse('$url/signup/checkphone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];
      return result;
    } else {
      print("전화번호 중복 확인 중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  Future<bool> _signupAvailability(String id, String pw, String name,
      String email, String phone) async {
    final response = await http.post(
      Uri.parse('$url/signup/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'pw': pw, 'name': name, 'email': email, 'phone': phone}),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes));
      bool result = jsonData['result'];
      String description = jsonData['description'];
      return result;
    } else {
      print("회원가입 도중 오류가 발생했습니다 (${response.statusCode})");
      return false;
    }
  }

  bool _validateEmail(String email) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return regex.hasMatch(email);
  }

  bool _validatePhone(String phone) {
    RegExp regex = RegExp(r'^01[0-9]{8,9}$');
    return regex.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteStyle1,
      appBar: AppBar(
        backgroundColor: whiteStyle1,
        title: Text('회원가입'),
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
                      controller: _idController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: greyStyle1,
                        hintText: '아이디',
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
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        // 영어와 숫자만 허용
                        LengthLimitingTextInputFormatter(12),
                        // 최대 길이 설정
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        // 공백 입력 방지
                      ],
                      onChanged: (value) {
                        // 입력값이 변경될 때마다 제약조건을 확인하여 상태 업데이트
                        setState(() {
                          _isIdLength = value.length >= 6 && value.length <= 12;
                          _isIdCheck = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () async {
                      String id = _idController.text.trim();
                      bool isAvailable = await _checkIdAvailability(id);
                      setState(() {
                        _isIdAvailable = !isAvailable;
                        _isIdCheck = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueStyle4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '중복 확인',
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
                    child: _isIdLength // true면 사용 가능한 길이, false면 사용 불가능한 길이
                        ? (_isIdCheck // true면 중복 확인이 된 상태, false면 중복 확인이 다시 필요한 상태
                        ? (_isIdAvailable // true면 사용 가능한 아이디, false는 중복된 아이디
                        ? Text(
                      '사용 가능한 아이디입니다.',
                      style: TextStyle(color: Colors.green),
                    )
                        : Text(
                      '중복된 아이디입니다.',
                      style: TextStyle(color: Colors.red),
                    ))
                        : Text(
                      '아이디 중복 확인 버튼을 눌러주세요',
                      style: TextStyle(color: Colors.black),
                    ))
                        : Text(
                      '6~12자를 입력하세요.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: greyStyle1,
                  hintText: '비밀번호',
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
                  // 최대 길이 설정
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  // 영어와 숫자만 허용
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  // 공백 입력 방지
                ],
                onChanged: (value) {
                  // 입력값이 변경될 때마다 제약조건을 확인하여 상태 업데이트
                  setState(() {
                    _isPasswordLength = value.length >= 6 && value.length <= 12;
                    _isPasswordCheck = _passwordController.text ==
                        _passwordCheckController.text;
                  });
                },
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Flexible(
                    child: _isPasswordLength
                        ? Text(
                      '사용 가능한 비밀번호입니다.',
                      style: TextStyle(color: Colors.green),
                    )
                        : Text(
                      '6~12자를 입력하세요.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _passwordCheckController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: greyStyle1,
                  hintText: '비밀번호 확인',
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
                  // 최대 길이 설정
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  // 영어와 숫자만 허용
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  // 공백 입력 방지
                ],
                onChanged: (value) {
                  // 입력값이 변경될 때마다 제약조건을 확인하여 상태 업데이트
                  setState(() {
                    _isPasswordCheck = _passwordController.text ==
                        _passwordCheckController.text;
                  });
                },
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Flexible(
                    child: _isPasswordCheck
                        ? Text(
                      '비밀번호가 일치합니다.',
                      style: TextStyle(color: Colors.green),
                    )
                        : Text(
                      '비밀번호가 일치하지 않습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: greyStyle1,
                  hintText: '이름',
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
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: greyStyle1,
                        hintText: '이메일',
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
                      onChanged: (value) {
                        // 입력값이 변경될 때마다 제약조건을 확인하여 상태 업데이트
                        setState(() {
                          String email = _emailController.text.trim();
                          _isEmailForm = _validateEmail(email);
                          _isEmailCheck = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      bool isAvailable = await _checkEmailAvailability(email);
                      setState(() {
                        _isEmailAvailable = !isAvailable;
                        _isEmailCheck = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueStyle4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '중복 확인',
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
                    child: _isEmailForm // true면 사용 가능한 양식, false면 사용 불가능한 양식
                        ? (_isEmailCheck // true면 중복 확인이 된 상태, false면 중복 확인이 다시 필요한 상태
                        ? (_isEmailAvailable // true면 사용 가능한 이메일, false는 중복된 이메일
                        ? Text(
                      '사용 가능한 이메일입니다.',
                      style: TextStyle(color: Colors.green),
                    )
                        : Text(
                      '중복된 이메일입니다.',
                      style: TextStyle(color: Colors.red),
                    ))
                        : Text(
                      '이메일 중복 확인 버튼을 눌러주세요',
                      style: TextStyle(color: Colors.black),
                    ))
                        : Text(
                      '이메일 양식에 맞지 않습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: greyStyle1,
                        hintText: '전화번호',
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
                      onChanged: (value) {
                        // 입력값이 변경될 때마다 제약조건을 확인하여 상태 업데이트
                        setState(() {
                          String phone = _phoneController.text.trim();
                          _isPhoneForm = _validatePhone(phone);
                          _isPhoneCheck = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: () async {
                      String phone = _phoneController.text.trim();
                      bool isAvailable = await _checkPhoneAvailability(phone);
                      setState(() {
                        _isPhoneAvailable = !isAvailable;
                        _isPhoneCheck = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueStyle4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                        '중복 확인',
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
                    child: _isPhoneForm // true면 사용 가능한 양식, false면 사용 불가능한 양식
                        ? (_isPhoneCheck // true면 중복 확인이 된 상태, false면 중복 확인이 다시 필요한 상태
                        ? (_isPhoneAvailable // true면 사용 가능한 전화번호, false는 중복된 전화번호
                        ? Text(
                      '사용 가능한 전화번호입니다.',
                      style: TextStyle(color: Colors.green),
                    )
                        : Text(
                      '중복된 전화번호입니다.',
                      style: TextStyle(color: Colors.red),
                    ))
                        : Text(
                      '전화번호 중복 확인 버튼을 눌러주세요',
                      style: TextStyle(color: Colors.black),
                    ))
                        : Text(
                      '전화번호 양식에 맞지 않습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  String id = _idController.text.trim();
                  String pw = _passwordController.text.trim();
                  String name = _nameController.text.trim();
                  String email = _emailController.text.trim();
                  String phone = _phoneController.text.trim();
                  if (_isIdCheck && _isIdAvailable && _isIdLength && _isPasswordLength &&
                      _isPasswordCheck && _isEmailCheck && _isEmailForm && _isEmailAvailable &&
                      _isPhoneCheck && _isPhoneForm && _isPhoneAvailable) {
                    bool signupResult = await _signupAvailability(
                        id, pw, name, email, phone);

                    if (signupResult) {
                      _goToLoginPage();
                      _isIdCheck = false;
                      _isIdAvailable = false;
                      _isIdLength = false;
                      _isPasswordLength = false;
                      _isPasswordCheck = false;
                      _isEmailCheck = false;
                      _isEmailForm = false;
                      _isEmailAvailable = false;
                      _isPhoneCheck = false;
                      _isPhoneForm = false;
                      _isPhoneAvailable = false;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: blueStyle1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            title: Text(
                                '회원가입 성공',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                )
                            ),
                            content: Text(
                              '회원가입이 성공적으로 완료되었습니다',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('회원가입에 실패했습니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueStyle3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                    '회원가입',
                    style: TextStyle(
                    color: blackStyle1,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}