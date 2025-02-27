import 'package:flutter/material.dart';

class CustomerGlobalState with ChangeNotifier {
  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get userData => _userData;

  void setUserData(Map<String, dynamic> userData) {
    _userData = userData;
    notifyListeners();
  }
}
