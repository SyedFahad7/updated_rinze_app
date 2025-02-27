import 'package:rinze/model/service.dart';

class LaundryItem {
  final String name;
  final ServiceModel selectedService;
  final String imagePath;
  int quantity;

  LaundryItem({
    required this.name,
    required this.selectedService,
    required this.imagePath,
    this.quantity = 1,
  });
}
