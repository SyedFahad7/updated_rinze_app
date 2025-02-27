import 'order.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String imagePath;
  List<Order> currentOrders;
  List<Order> previousOrders;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.imagePath,
    List<Order>? currentOrders,
    List<Order>? previousOrders,
  })  : currentOrders = currentOrders ?? [],
        previousOrders = previousOrders ?? [];

  void addToCurrentOrders(Order order) {
    currentOrders.add(order);
  }

  void moveToPreviousOrders(Order order) {
    currentOrders.remove(order);
    previousOrders.add(order);
  }

  List<Order> viewCurrentOrders() => currentOrders;
  List<Order> viewPreviousOrders() => previousOrders;
}
