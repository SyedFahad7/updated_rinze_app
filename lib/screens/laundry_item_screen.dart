import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rinze/components/loading_animation.dart';
import 'package:rinze/model/selected_product.dart';
import 'package:rinze/providers/service_provider.dart';
import 'package:rinze/utils/string_utils.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../main.dart';
import 'home_navigation_screen.dart';

class LaundryItemScreen extends StatefulWidget {
  const LaundryItemScreen({
    super.key,
    required this.imagePath,
    required this.itemName,
    required this.productId,
    required this.category,
  });

  final String imagePath;
  final String itemName;
  final String productId;
  final String category;

  @override
  LaundryItemScreenState createState() => LaundryItemScreenState();
}

class LaundryItemScreenState extends State<LaundryItemScreen> {
  int pieces = 1;
  int pricePerPiece = 19;
  String url = '';
  late Map<String, dynamic> products;
  late List<dynamic> services;
  bool isLoading = true;

  int totalServiceCost = 0;
  int totalServicesSelected = 0;
  late int responseStatusCode = 200;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    url =
        '${dotenv.env['API_URL']}/product/ServicesByProductId/${widget.productId}';
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
            products = data;
            services = products['data']['services'];
            isLoading = false;
          });
        } else {
          if (kDebugMode) {
            print('Error: ${response.statusCode} - ${response.reasonPhrase}');
          }
          setState(() {
            responseStatusCode = response.statusCode;
            isLoading = false;
          });
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

    totalServicesSelected =
        Provider.of<SGlobalState>(context).basketProducts.length;
    totalServiceCost =
        Provider.of<SGlobalState>(context).calculateBillDetails();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: responseStatusCode == 404
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'We aren\'t currently providing any service for this product!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.fadeRed,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize22,
                        fontWeight: AppFonts.fontWeightExtraBold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Please select a different product.',
                      style: TextStyle(
                        color: AppColors.darkGrey.withValues(alpha: 0.3),
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: 142.0,
                      height: 44.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // selectedIndex = 3;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeBottomNavigation(
                                selectedIndex: 0,
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
                                color: AppColors.black.withValues(alpha: 0.06),
                                width: 1.0,
                              )),
                          padding: const EdgeInsets.all(12.0),
                        ),
                        child: const Text(
                          'Go to Home',
                          style: TextStyle(
                            color: AppColors.darkerBlue,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: AppColors.backWhite,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
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
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize14,
                                    fontWeight: AppFonts.fontWeightRegular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 380.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                  image: NetworkImage(widget.imagePath),
                                  fit: BoxFit.fitWidth),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.itemName,
                            style: const TextStyle(
                              fontSize: AppFonts.fontSize18,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 24.0,
                        right: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Service",
                            style: TextStyle(
                              fontSize: AppFonts.fontSize14,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Service Options
                          ListView.builder(
                            itemCount: services.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final service = services[index];
                              // final serviceTitle = service['serviceTitle'];
                              final serviceTitle = service['serviceTitle'];

                              final pricePerPiece = service['laundryPerPiece']
                                  ['items'][0]['pricePerPiece'];
                              return LaundryItemRow(
                                serviceName: formatStringToMultiline(
                                    capitalize(serviceTitle)),
                                servicePrice: pricePerPiece,
                                id: widget.productId,
                                itemName: widget.itemName,
                                itemImagePath: widget.imagePath,
                                category: widget.category,
                                serviceId: service['_id'],
                                pricePerPiece: pricePerPiece,
                                initialQuantity: 0,
                                onQuantityChanged: (newQuantity) {
                                  // Handle the updated quantity
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // TODO: Fix problem in dynamic change
                    if (totalServicesSelected != 0)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: AppColors.black.withValues(alpha: 0.06),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  totalServicesSelected < 10
                                      ? '0$totalServicesSelected Services'
                                      : '$totalServicesSelected Services',
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize12,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                const Text('|'),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  '₹ $totalServiceCost',
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize12,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              //width: 100.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  // selectedIndex = 3;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeBottomNavigation(
                                              selectedIndex: 3),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  backgroundColor: AppColors.darkerBlue,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Go to Basket',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontFamily:
                                            AppFonts.fontFamilyPlusJakartaSans,
                                        fontSize: AppFonts.fontSize12,
                                        fontWeight: AppFonts.fontWeightSemiBold,
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/icons/arrow_right.svg',
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}

class LaundryItemRow extends StatefulWidget {
  const LaundryItemRow({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.initialQuantity,
    required this.onQuantityChanged,
    required this.serviceId,
    required this.id,
    required this.category,
    required this.itemName,
    required this.itemImagePath,
    required this.pricePerPiece,
  });

  final String serviceName;
  final String serviceId;
  final String category;
  final String itemName;
  final String id;
  final String itemImagePath;
  final num pricePerPiece;
  final int servicePrice;
  final int initialQuantity;
  final ValueChanged<int>
      onQuantityChanged; // Callback to notify parent of changes

  @override
  State<LaundryItemRow> createState() => _LaundryItemRowState();
}

class _LaundryItemRowState extends State<LaundryItemRow> {
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity; // Initialize the quantity
  }

  void addServicesToBasket() {
    final globalState = Provider.of<SGlobalState>(context, listen: false);

    // New item details
    final newItem = {
      'itemId': widget.id,
      'itemName': widget.itemName,
      'image_url': widget.itemImagePath,
      'quantity': quantity,
      'pricePerPiece': widget.pricePerPiece,
    };

    // Check if a product with the same serviceId exists
    final existingProductIndex = globalState.basketProducts
        .indexWhere((product) => product.serviceId == widget.serviceId);

    if (existingProductIndex != -1) {
      // ServiceId exists, retrieve the product
      final existingProduct = globalState.basketProducts[existingProductIndex];

      // Check if the category exists within laundryPerPiece
      final categoryMapIndex = existingProduct.laundryPerPiece.indexWhere(
        (element) => element.containsKey(widget.category),
      );

      if (categoryMapIndex != -1) {
        // Category exists, retrieve the item list
        final itemList = existingProduct.laundryPerPiece[categoryMapIndex]
            [widget.category] as List;

        // Check if the itemId exists in this category
        final existingItemIndex =
            itemList.indexWhere((item) => item['itemId'] == widget.id);

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
          widget.category: [newItem],
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
      // ServiceId does not exist, create a new product entry
      final newProduct = SelectedProduct(
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        laundryPerPiece: [
          {
            widget.category: [newItem]
          }
        ],
        laundryByKg: [], // Assuming laundryByKg is empty initially
      );

      globalState.addBasketProduct(newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkProductById([], widget.id, widget.category);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.black.withValues(alpha: 0.06),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.serviceName,
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize16,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '₹${widget.servicePrice} / piece',
                    style: const TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              quantity == 0
                  ? SizedBox(
                      width: 95.0,
                      height: 36.0,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            quantity = 1; // Set quantity to 1
                          });
                          widget.onQuantityChanged(quantity);
                          addServicesToBasket();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.halfWhite,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          side: BorderSide(
                            width: 2.0,
                            color: AppColors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: const Text(
                          'ADD',
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 0) {
                              setState(() {
                                quantity--; // Decrease quantity
                              });
                              widget
                                  .onQuantityChanged(quantity); // Notify parent
                              addServicesToBasket();
                            }
                          },
                        ),
                        Text(
                          quantity.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++; // Increase quantity
                            });
                            widget.onQuantityChanged(quantity); // Notify parent
                            addServicesToBasket();
                          },
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  void checkProductById(
      List<Map<String, dynamic>> products, String productId, String category) {
    final basketProducts = Provider.of<SGlobalState>(context).basketProducts;

// Loop through each product in the global state
    for (var product in basketProducts) {
      // Check if the serviceId matches
      if (product.serviceId == widget.serviceId) {
        // Loop through each category map in laundryPerPiece
        for (var categoryMap in product.laundryPerPiece) {
          // Check if the category map contains the desired category
          if (categoryMap.containsKey(category)) {
            // Loop through the items in the category
            for (var item in categoryMap[category]) {
              // Check if the itemId matches the desired product ID
              if (item['itemId'] == widget.id) {
                // Update _quantity with the matched product's quantity
                setState(() {
                  quantity = item['quantity'] ?? 0;
                });
                return; // Exit once the item is found
              }
            }
            return; // Exit once the category is processed
          }
        }
      }
    }

    for (var product in products) {
      if (product['id'] == productId) {
        setState(() {
          quantity = product['quantity'] ??
              0; // Set quantity to the matched product's quantity
        });
        return; // Exit the function once a match is found
      }
    }
    // Optionally, reset quantity if no match is found
    setState(() {
      quantity = 0;
    });
  }
}
