import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rinze/components/loading_animation.dart';
import 'package:rinze/components/tabs/orders_tabs/history/history_order_details_tab.dart';
import 'package:rinze/components/tabs/orders_tabs/history/history_order_tracking_tab.dart';
import 'package:rinze/utils/string_utils.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../main.dart';

// TODO: Add payment transaction id and details

class HistoryOrderDetailsScreen extends StatefulWidget {
  const HistoryOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  State<HistoryOrderDetailsScreen> createState() =>
      _HistoryOrderDetailsScreenState();
}

class SocketHandler {
  late IO.Socket socket;
  void disconnect() {
    socket.disconnect();
  }
}

class _HistoryOrderDetailsScreenState extends State<HistoryOrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String url;
  bool isLoading = true;
  late Map<String, dynamic> orderData;
  late List<dynamic> ordersList;
  late String paymentStatus;
  late Map<String, dynamic> pickupData;
  late Map<String, dynamic> deliveryData;
  late Map<String, dynamic> addressData;
  late String orderNumber;
  late String orderDate;
  late String status;
  late List<dynamic> orderStatuses;
  late IO.Socket socket;
  late final SocketHandler socketHandler;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    url = '${dotenv.env['API_URL']}/orders/${widget.orderId}';
    fetchData();
    // Connect to Socket.IO
    connectToSocket();
  }

  Future<void> connectToSocket() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');
    String? serverUrl = dotenv.env['TEST_API_URL'];

    // Create the socket connection
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket transport
          .setQuery({'token': storedToken}) // Optional query params
          .setExtraHeaders(
              {'Authorization': 'Bearer $storedToken'}) // Send token as header
          .enableAutoConnect() // Automatically connect
          .build(),
    );

    // Listen for connection events
    socket.onConnect((_) {
      socket.emit('register', storedToken); // Send the register event
    });

    // Listen for errors
    socket.on('error', (data) {
      if (kDebugMode) {
        print('Error: $data');
      }
    });

    // Handle disconnection
    socket.onDisconnect((_) {});

    // Listen for order status updates
    socket.on('orderStatusUpdated', (data) {
      if (data != null && data is Map) {
        // Safely handle orderStatusHistory
        List<dynamic>? history = data['orderStatusHistory'];

        if (history != null && history.isNotEmpty) {
          setState(() {
            orderStatuses = history;
            status = data['status'];
          });
        } else {
          if (kDebugMode) {
            print('No history available.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Invalid order status update data: $data');
        }
      }
    });

    // Handle other server events as needed
  }

  @override
  void dispose() {
    // Disconnect from the WebSocket server
    socket.disconnect();
    super.dispose();
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
          _parseOrderData(response.body);
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

  void _parseOrderData(String responseBody) {
    final data = json.decode(responseBody);
    setState(() {
      orderData = data['order'];
      ordersList = orderData['orders'];
      paymentStatus = orderData['paymentStatus'];
      pickupData = orderData['pickup'];
      deliveryData = orderData['delivery'];
      addressData = orderData['address_id'];
      orderDate = orderData['customer']['createdAt'];
      orderNumber = orderData['order_id'];
      status = orderData['status'];
      orderStatuses = orderData['orderStatusHistory'];
      isLoading = false;
    });
  }

  String _getDisplayText() {
    int serviceCount = ordersList.length;

    if (serviceCount == 1) {
      return ordersList.first['service']['serviceTitle'];
    } else {
      return "$serviceCount services";
    }
  }

  int _calculateTotalItems() {
    int totalItems = 0;

    for (var order in orderData['orders']) {
      var laundryByPiece = order['order']['laundryByPiece'];
      if (laundryByPiece != null && laundryByPiece['products'] != null) {
        var categories = laundryByPiece['products'] as Map<String, dynamic>;
        for (var category in categories.values) {
          if (category['products'] != null) {
            for (var product in category['products']) {
              totalItems += (product['quantity'] ?? 0) as int;
            }
          }
        }
      }
    }

    for (var order in orderData['orders']) {
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

    return totalItems;
  }

  String _formatDate(String date) {
    String isoDate = "2024-10-29T18:21:04.442Z";

    // Parse the ISO string to DateTime
    DateTime dateTime = DateTime.parse(isoDate);

    // Format the DateTime into the desired format
    String formattedDate = DateFormat('EEE, dd MMM').format(dateTime);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingAnimation();
    }

    String displayText = _getDisplayText();
    int totalItems = _calculateTotalItems();
    String formattedStatus = splitString(status);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/arrow_left.svg'),
                      const Text(
                        'Back',
                        style: TextStyle(
                          color: AppColors.black,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  capitalize('$displayText - $totalItems Items'),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightSemiBold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(orderDate),
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.6),
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightRegular,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: formattedStatus == 'cancelled'
                            ? AppColors.lightRed.withValues(alpha: 0.3)
                            : AppColors.retroLime.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(
                        capitalize(formattedStatus),
                        style: TextStyle(
                          color: formattedStatus == 'cancelled'
                              ? AppColors.fadeRed
                              : AppColors.green,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize12,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.halfWhite,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.06),
                      width: 2.0,
                    ),
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(4.0),
                    dividerColor: AppColors.transparent,
                    unselectedLabelColor:
                        AppColors.black.withValues(alpha: 0.5),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                    labelColor: AppColors.hintBlack,
                    labelStyle: const TextStyle(
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                    indicator: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      border: Border.all(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 2.0,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.transparent,
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        text: 'Order Details',
                      ),
                      Tab(
                        text: 'Order Tracking',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  height: 600.0,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Tab(
                        child: HistoryOrderDetailsTab(
                          ordersList: ordersList,
                          orderNumber: orderNumber,
                          totalItems: totalItems,
                          paymentStatus: paymentStatus,
                          pickupData: pickupData,
                          deliveryData: deliveryData,
                          addressData: addressData,
                          orderStatus: formattedStatus,
                        ),
                      ),
                      Tab(
                        child: HistoryOrderTrackingTab(
                          orderStatuses: orderStatuses,
                          currentStatus: status,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
