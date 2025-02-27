import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rinze/components/history_order_card.dart';
import 'package:rinze/components/loading_animation.dart';
import 'package:rinze/constants/app_colors.dart';
import 'package:rinze/constants/app_fonts.dart';
import 'package:rinze/screens/main/services_screen.dart';

import '../../../../main.dart';
import '../../../../utils/string_utils.dart';

class HistoryTabScreen extends StatefulWidget {
  const HistoryTabScreen({super.key});

  @override
  State<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends State<HistoryTabScreen> {
  String url = '${dotenv.env['API_URL']}/orders/getAll/history';
  late List<dynamic> historyOrdersData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

      if (storedToken != null) {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $storedToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // Parse the JSON data
          final data = json.decode(response.body);

          setState(() {
            historyOrdersData = data['historyOrders'];
            isLoading = false;
          });
        } else {
          if (kDebugMode) {
            print('Error: ${response.statusCode} - ${response.reasonPhrase}');
          }
        }
      } else {
        if (kDebugMode) {
          print('Error: Token is null. User is not authenticated.');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred while fetching data: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingAnimation();
    }

    if (historyOrdersData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_cart.png',
              width: 170,
              height: 170,
            ),
            const SizedBox(height: 20),
            const Text(
              'You have no order history',
              style: TextStyle(
                fontSize: AppFonts.fontSize16,
                fontWeight: AppFonts.fontWeightMedium,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ServicesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.baseWhite, // Button color
                minimumSize: const Size(150, 50), // Width and height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Border radius
                ),
              ),
              child: const Text(
                'Place an Order',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 24.0,
        right: 24.0,
      ),
      child: ListView.builder(
        itemCount: historyOrdersData.length,
        itemBuilder: (context, outerIndex) {
          Map<String, dynamic> orderData =
              historyOrdersData.reversed.toList()[outerIndex];
          String pickupDate =
              orderData['pickup']['pickupDate'] ?? 'To be assigned';
          String deliveryDate =
              orderData['delivery']['deliveryDate'] ?? 'To be assigned';
          String orderId = orderData['_id'];
          List<dynamic> orders = orderData['orders'];
          String status = orderData['status'];
          List<dynamic> orderStatuses = orderData['orderStatusHistory'];
          int serviceCount = orders.length;
          int totalItems = 0;

          List statuses = [
            'confirmed',
            'readyForPickup',
            'orderPickedUp',
            'reachedCollectionCentre',
            'readyForDelivery',
            'outForDelivery',
            'delivered',
          ];

          final serviceStatuses = orderStatuses
              .where((status) => [
                    'inWashing',
                    'inIroning',
                    'inDryCleaning',
                    'inDeepCleaning',
                  ].contains(status['status']))
              .map((status) => status['status'])
              .toList();

          final allStatuses = [
            ...statuses.sublist(0, 4),
            ...serviceStatuses,
            ...statuses.sublist(4),
          ];

          final currentStatusIndex = allStatuses.indexOf(status);
          double progress = 0;

          if (status == 'cancelled') {
            progress = 1.0;
          } else {
            progress = (currentStatusIndex + 1) / allStatuses.length;
          }
          // Iterate through orders to calculate total quantity
          for (var order in orders) {
            var laundryByPiece = order['order']['laundryByPiece'];
            if (laundryByPiece != null && laundryByPiece['products'] != null) {
              for (var product in laundryByPiece['products']) {
                totalItems += (product['quantity'] ?? 0)
                    as int; // Add quantity of each product
              }
            }
          }

          for (var order in orders) {
            final laundryByKG = order['order']['laundryByKG'];
            if (laundryByKG != null && laundryByKG is Map) {
              for (var details in laundryByKG.values) {
                if (details is Map && details.containsKey('products')) {
                  final products = details['products'] as List<dynamic>;
                  for (var product in products) {
                    totalItems += product['quantity'] as int;
                  }
                }
              }
            }
          }

          // Decide what to display
          String displayText;
          if (serviceCount == 1) {
            displayText = orders.first['service']['serviceTitle'];
          } else {
            displayText = "$serviceCount services";
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HistoryOrderCard(
                serviceTitle: capitalize(displayText),
                totalItems: totalItems,
                deliveryDate: deliveryDate,
                orderId: orderId,
                pickupDate: pickupDate,
                progress: progress,
                status: status, // Pass the computed total items
              ),
            ],
          );
        },
      ),
    );
  }
}
