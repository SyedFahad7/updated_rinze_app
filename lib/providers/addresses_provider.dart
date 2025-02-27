import 'package:flutter/material.dart';

class AddressesGlobalState extends ChangeNotifier {
  final List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic> _defaultAddress = {};

  List<Map<String, dynamic>> get addresses => _addresses;
  Map<String, dynamic> get defaultAddress => _defaultAddress;

  void addAddress(Map<String, dynamic> address) {
    // Check if address is already in the list before adding
    _addresses.clear();
    _addresses.add(address);
    _defaultAddress = address;
    notifyListeners();
  }

  void setDefaultAddress(Map<String, dynamic> address) {
    addAddress(address);
    notifyListeners();
  }

  void clearAddresses() {
    _addresses.clear();
    _defaultAddress = {};
    notifyListeners();
  }
}
