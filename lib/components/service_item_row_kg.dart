import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rinze/model/selected_product.dart';
import 'package:rinze/providers/service_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class ServiceItemRowKg extends StatefulWidget {
  const ServiceItemRowKg(
      {super.key,
      required this.updatedKg,
      required this.serviceName,
      required this.serviceId,
      required this.id,
      required this.itemName,
      required this.itemImagePath,
      required this.pricePerPiece,
      required this.onQuantityChanged,
      required this.laundryByKg,
      required this.category,
      required this.globalProducts,
      required this.isWeightLimitReached});
  final List<Map<String, dynamic>> globalProducts;
  final Map<String, dynamic> laundryByKg;
  final String serviceName;
  final String updatedKg;
  final String serviceId;
  final String category;
  final String itemName;
  final String id;
  final String itemImagePath;
  final num pricePerPiece; // Changed to `num` for flexibility
  final ValueChanged<int> onQuantityChanged; // Now only takes quantity
  final bool isWeightLimitReached;

  @override
  State<ServiceItemRowKg> createState() => _ServiceItemRowKgState();
}

class _ServiceItemRowKgState extends State<ServiceItemRowKg> {
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
  }

  void printDetails() {
    final globalState = Provider.of<SGlobalState>(context, listen: false);

    // Define the new item details
    final newItem = {
      'itemId': widget.id,
      'itemName': widget.itemName,
      'image_url': widget.itemImagePath,
      'quantity': _quantity,
      'pricePerPiece': widget.pricePerPiece,
    };

    // Check if a product with the same `serviceId` exists
    final existingProductIndex = globalState.basketProducts.indexWhere(
      (product) => product.serviceId == widget.serviceId,
    );

    if (existingProductIndex != -1) {
      // ServiceId exists, retrieve the product
      final existingProduct = globalState.basketProducts[existingProductIndex];

      // Check if the category exists within `laundryByKg`
      final categoryIndex = existingProduct.laundryByKg.indexWhere(
        (element) => element.containsKey(widget.category),
      );

      if (categoryIndex != -1) {
        // Category exists, retrieve its map
        final categoryMap = existingProduct.laundryByKg[categoryIndex];
        final categoryItems = categoryMap[widget.category]['items'] as List;

        // Check if the item already exists within this category
        final itemIndex =
            categoryItems.indexWhere((item) => item['itemId'] == widget.id);

        if (itemIndex != -1) {
          if (_quantity == 0) {
            // Remove the item if quantity is 0
            categoryItems.removeAt(itemIndex);
          } else {
            // Item exists, update its quantity
            categoryItems[itemIndex]['quantity'] = _quantity;
          }
        } else if (_quantity > 0) {
          // Item does not exist, add the new item
          categoryItems.add(newItem);
        }

        // Check if the category is empty after item removal
        if (categoryItems.isEmpty) {
          existingProduct.laundryByKg.removeAt(categoryIndex);
        } else {
          // Update `updatedKg` if necessary
          categoryMap[widget.category]['updatedKg'] = widget.updatedKg;
        }
      } else if (_quantity > 0) {
        // Category does not exist, add the category with the new item
        existingProduct.laundryByKg.add({
          widget.category: {
            'pricingTier': widget.laundryByKg[widget.category]['pricingTier'],
            'updatedKg': widget.updatedKg,
            'items': [newItem],
          },
        });
      }

      // Check if both laundryByKg and laundryPerPiece are empty
      if (existingProduct.laundryByKg.isEmpty &&
          existingProduct.laundryPerPiece.isEmpty) {
        globalState.basketProducts.removeAt(existingProductIndex);
      }
    } else if (_quantity > 0) {
      // ServiceId does not exist, create a new product entry
      final newProduct = SelectedProduct(
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        laundryByKg: [
          {
            widget.category: {
              'pricingTier': widget.laundryByKg[widget.category]['pricingTier'],
              'updatedKg': widget.updatedKg,
              'items': [newItem],
            }
          }
        ],
        laundryPerPiece: [], // Assuming no per-piece laundry data initially
      );

      globalState.addBasketProduct(newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkProductById(widget.laundryByKg[widget.category]['items'] ?? [],
        widget.id, widget.category);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Item image
            Image.network(
              widget.itemImagePath,
              width: 64.0,
            ),
            const SizedBox(width: 8.0),
            // Item details (column)
            Text(
              widget.itemName,
              style: const TextStyle(
                color: AppColors.hintBlack,
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize18,
                fontWeight: AppFonts.fontWeightSemiBold,
              ),
            ),
          ],
        ),
        _quantity == 0
            ? SizedBox(
                width: 95.0,
                height: 36.0,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _quantity = 1; // Set quantity to 1
                      widget.onQuantityChanged(_quantity); // Pass only quantity
                    });
                    printDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.halfWhite,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    side: BorderSide(
                      width: 2.0,
                      color: AppColors.black.withOpacity(0.06),
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
                      if (_quantity > 0) {
                        setState(() {
                          _quantity--; // Decrement the quantity
                          widget.onQuantityChanged(
                              -1); // Pass -1 to decrease weight
                        });
                        printDetails();
                      }
                    },
                  ),
                  Text(
                    _quantity.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: widget.isWeightLimitReached
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot exceed 30 kg limit!'),
                              ),
                            );
                          }
                        : () {
                            setState(() {
                              _quantity++; // Increment the quantity
                              widget.onQuantityChanged(
                                  1); // Pass 1 to increase weight
                            });
                            printDetails();
                          },
                  ),
                ],
              ),
      ],
    );
  }

  void checkProductById(
      List<dynamic> products, String productId, String category) {
    final basketProducts =
        Provider.of<SGlobalState>(context, listen: false).basketProducts;

    // Loop through each product in the global state
    for (var product in basketProducts) {
      if (product.serviceId == widget.serviceId) {
        // Loop through the category maps in laundryByKg
        for (var categoryMap in product.laundryByKg) {
          if (categoryMap.containsKey(category)) {
            final categoryItems =
                categoryMap[category]['items'] as List<dynamic>;
            for (var item in categoryItems) {
              if (item['itemId'] == productId) {
                setState(() {
                  _quantity = item['quantity'] ?? 0;
                });
                return; // Exit as the item is found
              }
            }
          }
        }
      }
    }

    // If not found in the global state, check widget.globalProducts
    for (var categoryMap in widget.globalProducts) {
      if (categoryMap.containsKey(category)) {
        final categoryProducts = categoryMap[category] as List<dynamic>;
        for (var product in categoryProducts) {
          if (product['id'] == productId) {
            setState(() {
              _quantity = product['quantity'] ?? 0;
            });
            return; // Exit as the item is found
          }
        }
      }
    }

    // If still not found, check the passed products list
    for (var product in products) {
      if (product['id'] == productId) {
        setState(() {
          _quantity = product['quantity'] ?? 0;
        });
        return; // Exit as the item is found
      }
    }

    // If no match is found in any list, reset _quantity
    setState(() {
      _quantity = 0;
    });
  }
}
