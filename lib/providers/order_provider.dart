import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  String _orderId = '';

  String get orderId => _orderId;

  void setOrderId(String orderId) {
    _orderId = orderId;
    notifyListeners();
  }
}