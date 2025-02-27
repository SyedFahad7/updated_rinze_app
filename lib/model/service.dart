import 'laundry_item.dart';

class ServiceModel {
  final String id;
  final String serviceName;
  final String imagePath;
  final double pricePerKg;
  final List<LaundryItemWithPrice> laundryItemsWithPrice;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.imagePath,
    required this.pricePerKg,
    List<LaundryItemWithPrice>? laundryItemsWithPrice,
  }) : laundryItemsWithPrice = laundryItemsWithPrice ?? [];

  void addLaundryItem(
    LaundryItem laundryItem,
    double pricePerPiece,
    bool perKg,
  ) {
    laundryItemsWithPrice.add(
      LaundryItemWithPrice(
        laundryItem: laundryItem,
        pricePerPiece: pricePerPiece,
        perKg: perKg,
      ),
    );
  }
}

class LaundryItemWithPrice {
  final LaundryItem laundryItem;
  final double pricePerPiece;
  final bool perKg;

  LaundryItemWithPrice({
    required this.laundryItem,
    required this.pricePerPiece,
    required this.perKg,
  });
}
