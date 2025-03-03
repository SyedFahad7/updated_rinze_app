import 'package:flutter/material.dart';

class OrderStatusProvider with ChangeNotifier {
  List<dynamic> _orderStatuses = [];
  String _currentStatus = '';

  List<dynamic> get orderStatuses => _orderStatuses;
  String get currentStatus => _currentStatus;

  void setOrderStatuses(List<dynamic> orderStatuses) {
    _orderStatuses = orderStatuses;
    notifyListeners();
  }

  void setCurrentStatus(String currentStatus) {
    _currentStatus = currentStatus;
    notifyListeners();
  }
}
