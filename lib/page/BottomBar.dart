import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:team2/page/SignupPage.dart';

import '../models/User.dart';
import '../theme/Colors.dart';
import 'MainPage.dart';
import 'UserPage.dart';

class BottomBar extends StatefulWidget {
  final User user;
  BottomBar({required this.user});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MainPage(user: widget.user),
      UserPage(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteStyle1,
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size:32),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet, size: 32),
            label: '마이 페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: blueStyle3,
        selectedLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),
    );
  }
}