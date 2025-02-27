import 'dart:convert';

class SelectedProduct {
  final String serviceId;
  final String serviceName;
  final List<Map<String, dynamic>> laundryPerPiece;
  final List<Map<String, dynamic>> laundryByKg;

  SelectedProduct({
    required this.serviceId,
    required this.serviceName,
    required this.laundryPerPiece,
    required this.laundryByKg,
  });

  // toJson method to convert SelectedProduct to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'laundryPerPiece': laundryPerPiece,
      'laundryByKg': laundryByKg,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
