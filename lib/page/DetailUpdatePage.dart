import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';

import '../models/Sensorlog.dart';
import '../models/Usersensor.dart';

class DetailUpdatePage extends StatefulWidget {
  final Usersensor? usersensor;

  DetailUpdatePage(this.usersensor);

  @override
  _DetailUpdatePageState createState() => _DetailUpdatePageState();
}

class _DetailUpdatePageState extends State<DetailUpdatePage> {
  void _handleModify() {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Update Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleModify,
              child: Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }
}