import 'package:flutter/material.dart';

class CouponsGlobalState extends ChangeNotifier {
  Map<String, dynamic> _selectedCoupon = {};

  Map<String, dynamic> get selectedCoupon => _selectedCoupon;

  void setSelectedCoupon(Map<String, dynamic> coupon) {
    _selectedCoupon = coupon;
    notifyListeners();
  }

  void removeSelectedCoupon() {
    _selectedCoupon = {};
    notifyListeners();
  }
}
