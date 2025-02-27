import 'package:flutter/material.dart';
import 'package:rinze/model/selected_product.dart';

class SGlobalState with ChangeNotifier {
  final List<List<SelectedProduct>> _selectedServices = [];
  List<SelectedProduct> _selectedProducts = [];
  final List<SelectedProduct> _basketProducts = [];
  int totalServiceCost = 0;
  int totalPricePerPiece = 0;
  int totalPricePerKg = 0;

  List<SelectedProduct> get selectedProducts => _selectedProducts;
  List<List<SelectedProduct>> get selectedServices => _selectedServices;
  List<SelectedProduct> get basketProducts => _basketProducts;

  void addSelectedProduct(SelectedProduct selectedProduct) {
    _selectedProducts.add(selectedProduct);
    notifyListeners();
  }

  void setSelectedProducts(List<SelectedProduct> products) {
    _selectedProducts = products;
    _selectedServices.add(_selectedProducts);
    notifyListeners();
  }

  void clearSelectedProducts() {
    _selectedProducts.clear();
    notifyListeners();
  }

  // Optionally, add a method to remove a specific selected product by serviceId
  void removeSelectedProduct(String serviceId) {
    _selectedProducts.removeWhere((product) => product.serviceId == serviceId);
    notifyListeners();
  }

// Methods for basket products
  void addBasketProduct(SelectedProduct product) {
    _basketProducts.add(product);

    final basketProductsJson = _basketProducts
        .map((product) => {
              'serviceId': product.serviceId,
              'serviceName': product.serviceName,
              'laundryPerPiece': product.laundryPerPiece,
              'laundryByKg': product.laundryByKg,
            })
        .toList();

    notifyListeners();
  }

  void removeBasketProduct(String serviceId) {
    _basketProducts.removeWhere((product) => product.serviceId == serviceId);
    notifyListeners();
  }

  void clearBasketProducts() {
    _basketProducts.clear();
    notifyListeners();
  }

  int calculateBillDetails() {
    totalPricePerPiece = 0;
    totalPricePerKg = 0;

    for (var service in basketProducts) {
      // Iterate through laundryPerPiece if any
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
          // final updatedKg = int.parse(categoryDetails['updatedKg'].toString());
          final updatedKg =
              double.parse(categoryDetails['updatedKg'].toString()).toInt();

          // Filter pricingTier based on updatedKg
          final pricingTier = (categoryDetails['pricingTier'] as List)
              .where((tier) => updatedKg <= tier['maxWeight'])
              .toList();

          if (pricingTier.isNotEmpty) {
            // Use the first tier
            final tierPrice = pricingTier.first['price'];
            totalPricePerKg = (updatedKg * tierPrice) as int;
          }
        });
      }
    }

    return totalServiceCost = totalPricePerKg + totalPricePerPiece;
  }
}
