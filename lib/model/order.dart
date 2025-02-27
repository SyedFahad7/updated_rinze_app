import 'customer.dart';

class Order {
  final String orderId;
  final Customer customer;
  // final OrderDetail orders;
  final String status;
  // final Payment payment;
  final DateTime orderDate;

  Order({
    required this.orderId,
    required this.customer,
    // required this.orders,
    required this.status,
    // required this.payment,
    required this.orderDate,
  });

  void completeOrder() {
    bool isCompleted = true;
  }
}

// class OrderDetail {
//   final ServiceModel service;
//   final OrderType order;
//   final String status;
//
//   OrderDetail({});
// }
