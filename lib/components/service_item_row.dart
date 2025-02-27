import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rinze/model/selected_product.dart';
import 'package:rinze/providers/service_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class ServiceItemRow extends StatefulWidget {
  const ServiceItemRow(
      {super.key,
      required this.serviceName,
      required this.serviceId,
      required this.id,
      required this.itemName,
      required this.itemImagePath,
      required this.pricePerPiece,
      required this.onQuantityChanged,
      required this.laundryPerPiece,
      required this.category,
      required this.globalProducts});
  final List<Map<String, dynamic>> globalProducts;
  final Map<String, List<Map<String, dynamic>>> laundryPerPiece;
  final String serviceName;
  final String serviceId;
  final String category;
  final String itemName;
  final String id;
  final String itemImagePath;
  final num pricePerPiece; // Changed to `num` for flexibility
  final ValueChanged<int> onQuantityChanged; // Now only takes quantity

  @override
  State<ServiceItemRow> createState() => _ServiceItemRowState();
}

class _ServiceItemRowState extends State<ServiceItemRow> {
  int _quantity = 0;

  void printDetails1() {
    final globalState = Provider.of<SGlobalState>(context, listen: false);

    // New item details
    final newItem = {
      'itemId': widget.id,
      'itemName': widget.itemName,
      'image_url': widget.itemImagePath,
      'quantity': _quantity,
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
          // Item exists, update quantity
          itemList[existingItemIndex]['quantity'] = _quantity;
        } else {
          // Item does not exist, add new item
          itemList.add(newItem);
        }
      } else {
        // Category does not exist, add new category with the item
        existingProduct.laundryPerPiece.add({
          widget.category: [newItem],
        });
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

  void printDetails() {
    final globalState = Provider.of<SGlobalState>(context, listen: false);

    // New item details
    final newItem = {
      'itemId': widget.id,
      'itemName': widget.itemName,
      'image_url': widget.itemImagePath,
      'quantity': _quantity,
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
          if (_quantity == 0) {
            // Remove the item if _quantity is 0
            itemList.removeAt(existingItemIndex);

            // Check if the item list is empty after removal
            if (itemList.isEmpty) {
              // Remove the category if no items are left
              existingProduct.laundryPerPiece.removeAt(categoryMapIndex);
            }
          } else {
            // Item exists, update quantity
            itemList[existingItemIndex]['quantity'] = _quantity;
          }
        } else if (_quantity != 0) {
          // Item does not exist, add new item if _quantity is not 0
          itemList.add(newItem);
        }
      } else if (_quantity != 0) {
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
    checkProductById(widget.laundryPerPiece[widget.category] ?? [], widget.id,
        widget.category);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: const TextStyle(
                    color: AppColors.hintBlack,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize18,
                    fontWeight: AppFonts.fontWeightSemiBold,
                  ),
                ),
                Text(
                  '₹${widget.pricePerPiece} / piece',
                  style: const TextStyle(
                    color: AppColors.hintBlack,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize14,
                    fontWeight: AppFonts.fontWeightMedium,
                  ),
                ),
              ],
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
                      setState(() {
                        _quantity--; // Increment the quantity
                        widget.onQuantityChanged(_quantity);
                      });
                      printDetails();
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
                    onPressed: () {
                      setState(() {
                        _quantity++; // Increment the quantity
                        widget.onQuantityChanged(_quantity);
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
                  _quantity = item['quantity'] ?? 0;
                });
                return; // Exit once the item is found
              }
            }
            return; // Exit once the category is processed
          }
        }
      }
    }

    for (var categoryMap in widget.globalProducts) {
      // Check if the categoryMap contains the desired category key
      if (categoryMap.containsKey(category)) {
        for (var product in categoryMap[category]) {
          if (product['id'] == productId) {
            setState(() {
              _quantity = product['quantity'] ??
                  0; // Set _quantity to the matched product's quantity
            });
            return; // Exit the function once a match is found
          }
        }
        return;
      }
    }

    for (var product in products) {
      if (product['id'] == productId) {
        setState(() {
          _quantity = product['quantity'] ??
              0; // Set _quantity to the matched product's quantity
        });
        return; // Exit the function once a match is found
      }
    }
    // Optionally, reset _quantity if no match is found
    setState(() {
      _quantity = 0;
    });
  }
}
