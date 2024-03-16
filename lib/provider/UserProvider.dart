import 'package:flutter/material.dart';

import '../models/User.dart';

class UserProvider extends ChangeNotifier {
  late User _user;

  User get user => _user;

  setUser(User user) {
    _user = user;
    notifyListeners();
  }
}