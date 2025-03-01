import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rinze/components/basket_item_row_kg.dart';
import 'package:rinze/components/coupon_card.dart';
import 'package:rinze/model/selected_product.dart';
import 'package:rinze/providers/addresses_provider.dart';
import 'package:rinze/screens/coupons_screen.dart';
import 'package:rinze/screens/payment_confirmation_screen.dart';
import 'package:rinze/screens/profile/delivery_addresses_screen.dart';
import 'package:http/http.dart' as http;
import '../../components/basket_item_row.dart';
import '../../components/bill_details_card.dart';
import '../../components/cancellation_policy_card.dart';
import '../../components/delivery_address_card.dart';
import '../../components/delivery_type_card.dart';
import '../../components/offers_card.dart';
import '../../components/payment_method_card.dart';
import '../../components/pickup_type_card.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../main.dart';
import '../../providers/coupons_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/string_utils.dart';
import 'package:rinze/components/schedule_pickup_bottom_sheet.dart';
import '../home_navigation_screen.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  static const id = '/basket';

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String? _selectedPickupType;
  String? _selectedDeliveryType;
  String? _selectedPaymentMethod;
  int totalPricePerPiece = 0;
  int totalPricePerKg = 0;
  int basePickupCharge = 0;
  int baseDeliveryCharge = 0;
  int pickupAndDeliveryCost = 100;
  double gstCost = 0;
  int discount = 0;
  String url = '${dotenv.env['API_URL']}/orders/create';
  String couponUrl = '${dotenv.env['API_URL']}/coupons/active';
  List<dynamic> activeOrdersData = [];
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<dynamic>? couponsData;
  final Razorpay _razorpay = Razorpay();
  double totalCost = 0.0;
  Map<String, dynamic> notes = {};
  String transactionId = '';
  bool _isLoading = false;
  bool _isModalOpen = false;

  final Map<String, int> pickupCharges = {
    'Instant': 39,
    'Schedule': 0,
  };

  final Map<String, int> deliveryCharges = {
    'Standard': 0,
    'Fast': 60,
    'Self': 0,
    'Instant-Self': 70,
  };

  void calculateTotalPickupAndDeliveryCost() {
    int totalCost =
        pickupAndDeliveryCost + basePickupCharge + baseDeliveryCharge;
    pickupAndDeliveryCost = totalCost;
  }

  Future<void> postRazorpaySuccessData(
    String? signature,
    String? orderId,
    String? paymentId,
  ) async {
    try {
      String paymentUrl = '${dotenv.env['API_URL']}/payments/save';
      String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

      Map<String, String?> razorpayDetails = {
        'razorpay_signature': signature,
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
      };

      if (storedToken != null) {
        final response = await http.post(
          Uri.parse(paymentUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $storedToken',
          },
          body: json.encode(razorpayDetails),
        );

        if (response.statusCode == 200) {
          // Parse the JSON data
          final data = json.decode(response.body);

          setState(() {
            transactionId = data['transaction']['_id'];
          });
          createOrder();
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

  Future<void> payOnDelivery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String paymentUrl = '${dotenv.env['API_URL']}/payments/draft';
      String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

      notes = {
        'totalServiceCost': totalPricePerPiece + totalPricePerKg,
        'gst': gstCost,
        'discount': discount,
        'pickupDeliveryCost': pickupAndDeliveryCost,
        'totalCost': totalCost,
      };

      Map<String, dynamic> details = {
        'amount': totalCost,
        'notes': notes,
      };

      if (storedToken != null) {
        final response = await http.post(
          Uri.parse(paymentUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $storedToken',
          },
          body: json.encode(details),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            transactionId = data['transaction']['_id'];
          });
          createOrder();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchActiveCoupons() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');
    try {
      final response = await http.get(
        Uri.parse(couponUrl),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        couponsData = decodedResponse;
        return decodedResponse;
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onSlotSelected(String? slot) {
    setState(() {
      _selectedSlot = slot;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onPickupTypeSelected(String selectedPickupType) {
    setState(() {
      _selectedPickupType = selectedPickupType;
    });
  }

  void _onDeliveryTypeSelected(String selectedDeliveryType) {
    setState(() {
      _selectedDeliveryType = selectedDeliveryType;
    });
  }

  void _onPaymentMethodSelected(String selectedPaymentMethod) {
    setState(() {
      _selectedPaymentMethod = selectedPaymentMethod;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateBillDetails();
    fetchActiveCoupons();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> payOnline() async {
    setState(() {
      _isLoading = true;
    });

    if (_selectedPaymentMethod == 'online') {
      try {
        String razorpayUrl = '${dotenv.env['API_URL']}/razorpay/create';
        String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

        if (kDebugMode) {
          print(totalCost);
        }

        notes = {
          'totalServiceCost': totalPricePerPiece + totalPricePerKg,
          'gst': gstCost,
          'discount': discount,
          'pickupDeliveryCost': pickupAndDeliveryCost,
          'totalCost': totalCost,
        };

        Map<String, dynamic> cartTotal = {
          'cartTotal': totalCost,
          'notes': notes,
        };

        if (kDebugMode) {
          print(cartTotal);
        }

        if (storedToken != null) {
          final response = await http.post(
            Uri.parse(razorpayUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $storedToken',
            },
            body: json.encode(cartTotal),
          );

          if (response.statusCode == 201) {
            final data = json.decode(response.body);
            if (kDebugMode) {
              print('Button not clicked,,,,,,,,,,,,,,');
            }
            openCheckout(data);

            if (kDebugMode) {
              print('Payment done successfully: $data');
            }
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    if (kDebugMode) {
      print(
          'Payment Successful,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,');
      print(response.orderId);
      print(response.data);
      print(response.paymentId);
      print(response.signature);
    }

    postRazorpaySuccessData(
      response.signature,
      response.orderId,
      response.paymentId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    if (kDebugMode) {
      print(
          'Payment Failure,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,');
      print(response.code);
      print(response.error);
      print(response.message);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  void openCheckout(Map<String, dynamic> data) async {
    var options = {
      'key': dotenv.env['RAZORPAY_KEY_ID'],
      'amount': data['razorpayOrder']['amount'],
      'order_id': data['razorpayOrder']['id'],
      'name': 'Rinze Laundry',
      'description': 'Cool boy',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
    };

    if (kDebugMode) {
      print(dotenv.env);
    }

    try {
      if (kDebugMode) {
        print('hello,,,,,,,,,,,,,,,,,');
      }
      _razorpay.open(options);
      if (kDebugMode) {
        print('bye,,,,,,,,,,,,,,,,,,,,,,,,,');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

// Define the updateCartItem function to update global state
  void updateCartItem({
    required String itemId,
    required String itemName,
    required String imageUrl,
    required int quantity,
    required double pricePerPiece,
    required String serviceId,
    required String category,
  }) {
    final newItem = {
      'itemId': itemId,
      'itemName': itemName,
      'image_url': imageUrl,
      'quantity': quantity,
      'pricePerPiece': pricePerPiece,
    };

    final globalState = Provider.of<SGlobalState>(context, listen: false);
    // Check if a product with the same serviceId exists
    final existingProductIndex = globalState.basketProducts
        .indexWhere((product) => product.serviceId == serviceId);

    if (existingProductIndex != -1) {
      // ServiceId exists, retrieve the product
      final existingProduct = globalState.basketProducts[existingProductIndex];

      // Check if the category exists within laundryPerPiece
      final categoryMapIndex = existingProduct.laundryPerPiece.indexWhere(
        (element) => element.containsKey(category),
      );

      if (categoryMapIndex != -1) {
        // Category exists, retrieve the item list
        final itemList =
            existingProduct.laundryPerPiece[categoryMapIndex][category] as List;

        // Check if the itemId exists in this category
        final existingItemIndex =
            itemList.indexWhere((item) => item['itemId'] == itemId);

        if (existingItemIndex != -1) {
          if (quantity == 0) {
            // Remove the item if quantity is 0
            itemList.removeAt(existingItemIndex);

            // Check if the item list is empty after removal
            if (itemList.isEmpty) {
              // Remove the category if no items are left
              existingProduct.laundryPerPiece.removeAt(categoryMapIndex);
            }
          } else {
            // Item exists, update quantity
            itemList[existingItemIndex]['quantity'] = quantity;
          }
        } else if (quantity != 0) {
          // Item does not exist, add new item if quantity is not 0
          itemList.add(newItem);
        }
      } else if (quantity != 0) {
        // Category does not exist, add new category with the item
        existingProduct.laundryPerPiece.add({
          category: [newItem],
        });
      }

      // Check if laundryPerPiece is empty
      if (existingProduct.laundryPerPiece.isEmpty) {
        // Check if both laundryPerPiece and laundryByKg are empty
        if (existingProduct.laundryByKg.isEmpty) {
          // Remove the service if both are empty
          globalState.basketProducts.removeAt(existingProductIndex);
        }
      }
    } else {
      if (quantity != 0) {
        // ServiceId does not exist, create a new product entry
        final newProduct = SelectedProduct(
          serviceId: serviceId,
          serviceName: itemName,
          laundryPerPiece: [
            {
              category: [newItem]
            }
          ],
          laundryByKg: [], // Assuming laundryByKg is empty initially
        );

        globalState.addBasketProduct(newProduct);
      }
    }

    calculateBillDetails();
  }

  void createOrder() {
    final basketProducts =
        Provider.of<SGlobalState>(context, listen: false).basketProducts;
    final defaultAddress =
        Provider.of<AddressesGlobalState>(context, listen: false)
            .defaultAddress;
    final selectedCoupon =
        Provider.of<CouponsGlobalState>(context, listen: false).selectedCoupon;

    List<Map<String, dynamic>> orders = [];

    for (var product in basketProducts) {
      // Parse service-specific data
      String serviceId = product.serviceId;

      // Prepare laundryByPiece products
      List<Map<String, dynamic>> laundryByPieceProducts = [];
      for (var category in product.laundryPerPiece) {
        category.forEach((categoryName, items) {
          for (var item in items) {
            laundryByPieceProducts.add({
              "id": item['itemId'],
              "quantity": item['quantity'],
              "status": "pending"
            });
          }
        });
      }

      Map<String, dynamic> laundryByKG = {};

      for (var category in product.laundryByKg) {
        // Iterate over each category
        (category).forEach((categoryName, categoryDetails) {
          // Check if updatedKg is already an integer or if it needs parsing
          final updatedKg = categoryDetails['updatedKg'] is int
              ? categoryDetails['updatedKg'] as int
              : double.tryParse(categoryDetails['updatedKg'].toString())
                      ?.toInt() ??
                  0;
          print('updatedKg value: ${categoryDetails['updatedKg']}');

          final filteredPricingTier =
              (categoryDetails['pricingTier'] as List<dynamic>).where((tier) {
            final maxWeight = int.parse(
                tier['maxWeight'].toString()); // Ensure maxWeight is an int
            return updatedKg <=
                maxWeight; // Keep tiers with maxWeight >= updatedKg
          }).toList();

          // Keep only the relevant pricingTier
          if (filteredPricingTier.isNotEmpty) {
            categoryDetails['pricingTier'] = [filteredPricingTier.first];
          }

          // Build the laundryByKG object
          laundryByKG[categoryName] = {
            "products": (categoryDetails['items'] as List<dynamic>).map((item) {
              return {
                "id": item['itemId'].toString(),
                "quantity": item['quantity'],
                "status": "pending",
              };
            }).toList(),
            // Correctly access the first pricingTier and its _id
            "pricingTier": {
              "id": categoryDetails['pricingTier'][0]
                  ['_id'], // Get the first tier and its _id
              "details": categoryDetails['pricingTier']
                  [0], // Include the full tier details
            },
            "updatedKg": updatedKg, // Include updatedKg
          };
        });
      }

      // Construct order
      orders.add({
        "service": serviceId,
        "order": {
          "laundryByPiece": {
            "products": laundryByPieceProducts,
          },
          "laundryByKG": {
            ...laundryByKG,
          }
        },
        "status": "pending"
      });
    }

    if (kDebugMode) {
      print('Orders,,,,,,,,,,,,,');
      print(orders);
    }

    String deliveryDate;
    if (_selectedDeliveryType == 'Standard') {
      deliveryDate =
          DateTime.now().add(const Duration(hours: 96)).toIso8601String();
    } else if (_selectedDeliveryType == 'Fast') {
      deliveryDate =
          DateTime.now().add(const Duration(hours: 24)).toIso8601String();
    } else if (_selectedDeliveryType == 'Self') {
      deliveryDate =
          DateTime.now().add(const Duration(hours: 48)).toIso8601String();
    } else {
      deliveryDate =
          DateTime.now().add(const Duration(hours: 24)).toIso8601String();
    }

    Map<String, dynamic> orderState = {
      "orders": orders,
      "status": "confirmed",
      'notes': notes,
      if (_selectedPaymentMethod == 'PoD') 'paymentMode': "PoD",
      "pickup": {
        "pickupType": _selectedPickupType,
        "pickupDate": _selectedPickupType == 'Schedule'
            ? _selectedDate?.toIso8601String()
            : DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        "pickupTime": _selectedPickupType == 'Schedule' ? _selectedSlot : ' ',
      },
      "cartTotal": (totalPricePerPiece + totalPricePerKg - discount) +
          pickupAndDeliveryCost +
          gstCost,
      "address_id": defaultAddress['id'],
      "coupon_id": selectedCoupon.isNotEmpty ? selectedCoupon['_id'] : ' ',
      "transaction_id": transactionId,
      "delivery": {
        "deliveryType": _selectedDeliveryType,
        "deliveryDate": deliveryDate,
        "deliveryTime": '',
        "deliveryInstructions": "Leave at the doorstep"
      }
    };
    if (kDebugMode) {
      print(
          'Order state,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,');
      print(orderState);
    }

    postData(orderState);
  }

  void calculateBillDetails() {
    totalPricePerPiece = 0;
    totalPricePerKg = 0;
    final basketProducts =
        Provider.of<SGlobalState>(context, listen: false).basketProducts;

    for (var service in basketProducts) {
      for (var category in service.laundryPerPiece) {
        category.forEach((categoryName, items) {
          for (var item in items) {
            totalPricePerPiece +=
                (item['quantity'] * item['pricePerPiece']) as int;
          }
        });
      }

      for (var category in service.laundryByKg) {
        category.forEach((categoryName, categoryDetails) {
          try {
            // Debugging: Print the value of updatedKg
            print('updatedKg value: ${categoryDetails['updatedKg']}');

            // Ensure updatedKg is not null or empty
            if (categoryDetails['updatedKg'] != null &&
                categoryDetails['updatedKg'].toString().isNotEmpty) {
              // Use tryParse to avoid FormatException
              final updatedKg =
                  double.tryParse(categoryDetails['updatedKg'].toString()) ??
                      0.0; // Default to 0.0 if parsing fails

              final pricingTier = (categoryDetails['pricingTier'] as List)
                  .where((tier) => updatedKg <= tier['maxWeight'])
                  .toList();

              if (pricingTier.isNotEmpty) {
                final tierPrice = pricingTier.first['price'];
                totalPricePerKg += (updatedKg * tierPrice).toInt();
              }
            } else {
              if (kDebugMode) {
                print('updatedKg is null or empty for category: $categoryName');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing updatedKg for category: $categoryName - $e');
            }
          }
        });
      }
    }
  }

  Future<void> postData(Map<String, dynamic> orderState) async {
    final basketProducts =
        Provider.of<SGlobalState>(context, listen: false).basketProducts;
    final couponGlobalState =
        Provider.of<CouponsGlobalState>(context, listen: false);

    try {
      String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

      if (storedToken != null) {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $storedToken',
          },
          body: json.encode(orderState), // Include the body in POST request
        );

        if (response.statusCode == 201) {
          // Parse the JSON data
          final data = json.decode(response.body);
          if (kDebugMode) {
            print('Created order successfully: $data');
          }

          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.theme,
              child: const PaymentConfirmationScreen(),
            ),
          );

          setState(() {
            basketProducts.clear();
            couponGlobalState.removeSelectedCoupon();
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
    final basketProducts = Provider.of<SGlobalState>(context).basketProducts;
    final defaultAddress =
        Provider.of<AddressesGlobalState>(context).defaultAddress;
    final couponGlobalState = Provider.of<CouponsGlobalState>(context);

    gstCost =
        (totalPricePerPiece + totalPricePerKg + pickupAndDeliveryCost) * 0.18;

    int calculatedDiscount() {
      if (couponGlobalState.selectedCoupon.isNotEmpty) {
        if ((totalPricePerPiece + totalPricePerKg) >=
            couponGlobalState
                .selectedCoupon['discount_minimum_purchase_amount']) {
          if (couponGlobalState.selectedCoupon['discount_type'] == 'fixed') {
            return couponGlobalState.selectedCoupon['discount_value'];
          } else {
            return ((totalPricePerPiece + totalPricePerKg) *
                    (couponGlobalState.selectedCoupon['discount_value'] / 100))
                .round();
          }
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    }

    discount = calculatedDiscount();
    totalCost = (totalPricePerPiece + totalPricePerKg - discount) +
        pickupAndDeliveryCost +
        gstCost;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: basketProducts.isEmpty
            ? SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/grey_basket.svg'),
                    const SizedBox(height: 12.0),
                    const Text(
                      'No Orders yet',
                      style: TextStyle(
                        color: AppColors.darkerBlue,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize24,
                        fontWeight: AppFonts.fontWeightExtraBold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Let’s get your laundry started!',
                      style: TextStyle(
                        color: AppColors.darkGrey.withOpacity(0.3),
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // selectedIndex = 3;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeBottomNavigation(
                              selectedIndex: 1,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.halfWhite,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: AppColors.black.withOpacity(0.06),
                              width: 1.0,
                            )),
                        padding: const EdgeInsets.all(12.0),
                      ),
                      child: const Text(
                        'Place an Order',
                        style: TextStyle(
                          color: AppColors.darkerBlue,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Blue Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      width: double.infinity,
                      height: 150.0,
                      decoration: const BoxDecoration(
                        gradient: AppColors.customBlueGradient,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basket',
                            style: TextStyle(
                              color: AppColors.hintWhite,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize26,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Last step before clean clothes',
                            style: TextStyle(
                              color: AppColors.hintWhite,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightRegular,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // White Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      width: double.infinity,
                      color: AppColors.halfWhite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ...basketProducts.map((selectedProduct) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display the service name
                                if (selectedProduct.laundryPerPiece.isNotEmpty)
                                  Text(
                                    capitalize(selectedProduct.serviceName ??
                                        'Unknown Service'), // Fallback if serviceName is null
                                    style: TextStyle(
                                      color: AppColors.black.withOpacity(0.6),
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                      fontSize: AppFonts.fontSize14,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                    ),
                                  ),
                                const SizedBox(height: 8.0),

                                // Loop through laundryPerPiece to display categories and products
                                for (var laundryMap
                                    in selectedProduct.laundryPerPiece) ...[
                                  ...laundryMap.entries.map((entry) {
                                    final category = entry.key;
                                    final products =
                                        entry.value as List<dynamic>;
                                    int pricePerPieceQuantity = 0;

                                    for (var product in products) {
                                      pricePerPieceQuantity +=
                                          (product['quantity'] *
                                              product['pricePerPiece']) as int;
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display each product in the category
                                        ...products.map((product) {
                                          return BasketItemRow(
                                            counter: product['quantity'] ?? 0,
                                            onPressIncrement: () {
                                              setState(() {
                                                product['quantity']++;
                                              });

                                              updateCartItem(
                                                itemId: product['itemId'],
                                                itemName:
                                                    formatStringToMultiline(
                                                        product['itemName']),
                                                imageUrl:
                                                    product['image_url'] ?? '',
                                                quantity: product['quantity'],
                                                pricePerPiece:
                                                    (product['pricePerPiece']
                                                            as num)
                                                        .toDouble(),
                                                serviceId:
                                                    selectedProduct.serviceId,
                                                category: category,
                                              );
                                            },
                                            onPressDecrement: () {
                                              setState(() {
                                                if (product['quantity'] > 0) {
                                                  product['quantity']--;
                                                }
                                              });

                                              updateCartItem(
                                                itemId: product['itemId'],
                                                itemName: product['itemName'],
                                                imageUrl:
                                                    product['image_url'] ?? '',
                                                quantity: product['quantity'],
                                                pricePerPiece:
                                                    (product['pricePerPiece']
                                                            as num)
                                                        .toDouble(),
                                                serviceId:
                                                    selectedProduct.serviceId,
                                                category: category,
                                              );
                                            },
                                            itemName: capitalize(
                                              product['itemName'] ??
                                                  '', // Fallback to empty string if null
                                            ),
                                            itemImagePath:
                                                product['image_url'] ?? '',
                                            pricePerItem:
                                                product['pricePerPiece']
                                                    .toString(),
                                            category:
                                                category, // Fallback to empty string if null
                                          );
                                        }),
                                      ],
                                    );
                                  }),
                                ],

                                // Display the service name
                                if (selectedProduct.laundryByKg.isNotEmpty)
                                  Text(
                                    capitalize(
                                        '${selectedProduct.serviceName} By KG' ??
                                            'Unknown Service'),
                                    // Fallback if serviceName is null
                                    style: TextStyle(
                                      color: AppColors.black.withOpacity(0.6),
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                      fontSize: AppFonts.fontSize14,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                    ),
                                  ),
                                for (var laundryMap
                                    in selectedProduct.laundryByKg) ...[
                                  ...laundryMap.entries.map((entry) {
                                    final category = entry.key;
                                    final categoryData =
                                        entry.value as Map<String, dynamic>;
                                    final products =
                                        categoryData['items'] as List<dynamic>;
                                    int totalQuantityPerCategory = 0;

                                    for (var product in products) {
                                      totalQuantityPerCategory +=
                                          product['quantity'] as int;
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        BasketItemRowPerKG(
                                          category: category,
                                          totalWeightPerCategory:
                                              '${categoryData['updatedKg']} KG',
                                          totalPiecesPerCategory:
                                              totalQuantityPerCategory,
                                          firstItemName:
                                              products.first['itemName'],
                                          firstItemQuantity:
                                              products.first['quantity'],
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ],
                            );
                          }),
                          const SizedBox(height: 48.0),
                          // Pickup Type Section
                          Text(
                            'Pickup Type',
                            style: TextStyle(
                              color: AppColors.black.withOpacity(0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          PickupTypeCard(
                            charges: '+₹39',
                            headerText: 'Same Day Pickup',
                            mainText: 'In 30 mins',
                            mainTextColor: AppColors.hintBlack,
                            value: _selectedPickupType == 'Instant',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                basePickupCharge = 39;
                                print(basePickupCharge);
                                calculateTotalPickupAndDeliveryCost();
                                print(pickupAndDeliveryCost);
                                _onPickupTypeSelected('Instant');
                              }
                            },
                          ),
                          const SizedBox(height: 12.0),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                constraints: const BoxConstraints(
                                  maxHeight: 700.0,
                                ),
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0)),
                                ),
                                builder: (BuildContext context) {
                                  basePickupCharge = 0;
                                  calculateTotalPickupAndDeliveryCost();
                                  return SchedulePickupBottomSheet(
                                    initialDate:
                                        _selectedDate ?? DateTime.now(),
                                    initialSlot: _selectedSlot,
                                    onDateSelected: _onDateSelected,
                                    onSlotSelected: _onSlotSelected,
                                  );
                                },
                              );
                            },
                            child: PickupTypeCard(
                              charges: 'No Extra Charge',
                              headerText: 'Schedule Pickup',
                              mainText: _selectedDate != null
                                  ? '${_formatDate(_selectedDate!)} ${_selectedSlot ?? ''}'
                                  : 'Select Date & Time',
                              mainTextColor: AppColors.darkerBlue,
                              value: _selectedPickupType == 'Schedule',
                              onChanged: (bool? value) {
                                if (value != null && value) {
                                  basePickupCharge = 0;
                                  calculateTotalPickupAndDeliveryCost();
                                  _onPickupTypeSelected('Schedule');

                                  // Open the modal bottom sheet
                                  _isModalOpen = true;
                                  showModalBottomSheet(
                                    context: context,
                                    constraints: const BoxConstraints(
                                      maxHeight: 700.0,
                                    ),
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0)),
                                    ),
                                    builder: (BuildContext context) {
                                      return SchedulePickupBottomSheet(
                                        initialDate:
                                            _selectedDate ?? DateTime.now(),
                                        initialSlot: _selectedSlot,
                                        onDateSelected: _onDateSelected,
                                        onSlotSelected: _onSlotSelected,
                                      );
                                    },
                                  ).then((_) {
                                    // When the modal is closed
                                    _isModalOpen = false;

                                    // If no date or slot is selected, uncheck the checkbox
                                    if (_selectedDate == null ||
                                        _selectedSlot == null) {
                                      setState(() {
                                        _selectedPickupType = null;
                                      });
                                    }
                                  });
                                } else {
                                  // Uncheck the checkbox if it's toggled off
                                  setState(() {
                                    _selectedPickupType = null;
                                    _selectedDate = null;
                                    _selectedSlot = null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 48.0),

                          // Delivery Type Section
                          Text(
                            'Delivery Type',
                            style: TextStyle(
                              color: AppColors.black.withOpacity(0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          DeliveryTypeCard(
                            headerText: 'No Extra Charge',
                            mainText: 'Standard Delivery',
                            subText: 'Delivery in 3-4 Days',
                            value: _selectedDeliveryType == 'Standard',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                baseDeliveryCharge = 0;
                                print(baseDeliveryCharge);
                                calculateTotalPickupAndDeliveryCost();
                                print(pickupAndDeliveryCost);
                                _onDeliveryTypeSelected('Standard');
                              }
                            },
                          ),
                          const SizedBox(height: 12.0),
                          DeliveryTypeCard(
                            headerText: '+₹60',
                            mainText: 'Fast Delivery',
                            subText: 'Same Day Delivery',
                            value: _selectedDeliveryType == 'Fast',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                baseDeliveryCharge = 60;
                                print(baseDeliveryCharge);
                                calculateTotalPickupAndDeliveryCost();
                                print(pickupAndDeliveryCost);
                                _onDeliveryTypeSelected('Fast');
                              }
                            },
                          ),
                          const SizedBox(height: 12.0),
                          DeliveryTypeCard(
                            headerText: 'You will be notified when ready',
                            mainText: 'Self Pickup From Store',
                            subText: '1-2 Days',
                            value: _selectedDeliveryType == 'Self',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                baseDeliveryCharge = 0;
                                print(baseDeliveryCharge);
                                calculateTotalPickupAndDeliveryCost();
                                print(pickupAndDeliveryCost);
                                _onDeliveryTypeSelected('Self');
                              }
                            },
                          ),
                          const SizedBox(height: 12.0),
                          DeliveryTypeCard(
                            headerText: '+₹70',
                            mainText: 'Instant Self Pickup',
                            subText: 'Same Day Pickup From Store',
                            value: _selectedDeliveryType == 'Instant-Self',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                baseDeliveryCharge = 70;
                                print(baseDeliveryCharge);
                                calculateTotalPickupAndDeliveryCost();
                                print(pickupAndDeliveryCost);
                                _onDeliveryTypeSelected('Instant-Self');
                              }
                            },
                          ),

                          const SizedBox(height: 48.0),

                          // Delivery Address Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivery Address',
                                style: TextStyle(
                                  color: AppColors.black.withOpacity(0.6),
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize14,
                                  fontWeight: AppFonts.fontWeightSemiBold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DeliveryAddressesScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: AppColors.darkerBlue,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize12,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),

                          defaultAddress.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    border: Border.all(
                                      color: AppColors.black.withOpacity(0.06),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No addresses saved!',
                                        style: TextStyle(
                                          color: AppColors.hintBlack,
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize14,
                                          fontWeight: AppFonts.fontWeightMedium,
                                        ),
                                      ),
                                      Text(
                                        'Please add an address to deliver.',
                                        style: TextStyle(
                                          color: AppColors.hintBlack,
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize14,
                                          fontWeight: AppFonts.fontWeightMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DeliveryAddressCard(
                                  addressTpe: capitalize(
                                          defaultAddress['addressType']!) ??
                                      'Unknown', // Fix key mismatch
                                  address: capitalize(
                                      defaultAddress['formatted_address']),
                                ),

                          const SizedBox(height: 48.0),

                          // Offers & Discounts Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Offers and Discounts',
                                style: TextStyle(
                                  color: AppColors.black.withOpacity(0.6),
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize14,
                                  fontWeight: AppFonts.fontWeightSemiBold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CouponsScreen(
                                        couponsData: couponsData,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: AppColors.darkerBlue,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize12,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12.0),

                          couponGlobalState.selectedCoupon.isEmpty
                              ? const OffersCard(
                                  headerText: 'No Coupon Applied',
                                  mainText:
                                      'Click on View All to see available coupons',
                                  subText: 'Apply coupons to get discount!',
                                )
                              : CouponCard(
                                  headerText: 'Coupon Applied',
                                  mainText: couponGlobalState
                                      .selectedCoupon['discount_code'],
                                  subText: couponGlobalState.selectedCoupon[
                                              'discount_type'] ==
                                          'fixed'
                                      ? 'Get up to ₹${couponGlobalState.selectedCoupon['discount_value']} off on orders above ₹${couponGlobalState.selectedCoupon['discount_minimum_purchase_amount']}.'
                                      : 'Get up to ${couponGlobalState.selectedCoupon['discount_value']}% off on orders above ₹${couponGlobalState.selectedCoupon['discount_minimum_purchase_amount']}.',
                                ),
                          const SizedBox(height: 12.0),

                          if (couponGlobalState.selectedCoupon.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/icons/trash.svg'),
                                const SizedBox(width: 2.0),
                                GestureDetector(
                                  onTap: () {
                                    couponGlobalState.removeSelectedCoupon();
                                    setState(() {
                                      discount = 0;
                                    });
                                  },
                                  child: Text(
                                    'Remove Coupon',
                                    style: TextStyle(
                                      color: AppColors.black.withOpacity(0.6),
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                      fontSize: AppFonts.fontSize12,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 36.0),

                          // Payment Section
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              color: AppColors.black.withOpacity(0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          PaymentMethodCard(
                            text: 'Pay Online',
                            value: _selectedPaymentMethod == 'online',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                _onPaymentMethodSelected('online');
                              }
                            },
                          ),
                          const SizedBox(height: 12.0),
                          PaymentMethodCard(
                            text: 'Pay On Delivery',
                            value: _selectedPaymentMethod == 'PoD',
                            onChanged: (bool? value) {
                              if (value != null && value) {
                                _onPaymentMethodSelected('PoD');
                              }
                            },
                          ),

                          const SizedBox(height: 48.0),

                          // Bill Details Section
                          Text(
                            'Bill Details',
                            style: TextStyle(
                              color: AppColors.black.withOpacity(0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          BillDetailsCard(
                            serviceCost:
                                '₹${totalPricePerPiece + totalPricePerKg}',
                            discount: discount,
                            pickupAndDeliveryCost: '₹$pickupAndDeliveryCost',
                            gstCost: gstCost / 2,
                            totalCost:
                                '₹${(totalPricePerPiece + totalPricePerKg - discount) + pickupAndDeliveryCost + gstCost}',
                          ),

                          const SizedBox(height: 48.0),

                          // Bill Details Section
                          Text(
                            'Cancellation Policy',
                            style: TextStyle(
                              color: AppColors.black.withOpacity(0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          const CancellationPolicyCard(),
                          const SizedBox(height: 24.0),

                          if (_selectedPaymentMethod != null)
                            SizedBox(
                              width: double.infinity,
                              height: 70.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (defaultAddress['addressType'] == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select an address!',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightMedium,
                                          ),
                                        ),
                                        backgroundColor: AppColors.fadeRed,
                                      ),
                                    );
                                  } else if (_selectedPickupType == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a pickup type!',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightMedium,
                                          ),
                                        ),
                                        backgroundColor: AppColors.fadeRed,
                                      ),
                                    );
                                  } else if (_selectedDeliveryType == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a delivery type!',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightMedium,
                                          ),
                                        ),
                                        backgroundColor: AppColors.fadeRed,
                                      ),
                                    );
                                  } else if (_selectedPaymentMethod == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a payment type!',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightMedium,
                                          ),
                                        ),
                                        backgroundColor: AppColors.fadeRed,
                                      ),
                                    );
                                  } else {
                                    if (_selectedPaymentMethod == 'online') {
                                      payOnline();
                                    } else {
                                      payOnDelivery();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkerBlue,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  _selectedPaymentMethod == 'online'
                                      ? 'Tap to Pay'
                                      : 'Place an Order',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize16,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                ),
                              ),
                            ),
                          if (_isLoading)
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)}';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
