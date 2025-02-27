import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rinze/components/service_item_row_kg.dart';
import 'package:rinze/providers/service_provider.dart';
import 'package:rinze/utils/string_utils.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vibration/vibration.dart';
import '../../../components/service_item_row.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';

class LaundryTab extends StatefulWidget {
  const LaundryTab({
    super.key,
    required this.products,
    required this.category,
    required this.laundryPerPiece,
    required this.onUpdateTotal,
    required this.laundryByKg,
    required this.globalProducts,
    required this.serviceName,
    required this.serviceId,
  });
  final List<Map<String, dynamic>> globalProducts;
  final Map<String, List<Map<String, dynamic>>> laundryPerPiece;
  final Map<String, dynamic> laundryByKg;
  final List<Map<String, dynamic>> products;
  final String category;
  final String serviceName;
  final String serviceId;
  final Function(int pieces, num price) onUpdateTotal;

  @override
  State<LaundryTab> createState() => _LaundryTabState();
}

class _LaundryTabState extends State<LaundryTab> {
  bool isSwitched = false;
  double selectedWeight = 0.0;
  int lastVibrationWeight = 0;
  bool isWeightLimitReached = false;

  late String updatedKg;

  // State to store the weight of each product
  Map<String, double> productWeights = {
    'shirt': 0.3, // Example weight in kg
    'Jean': 0.5, // Example weight in kg
    // Add more products and their weights here
  };

  // State to track the quantity of each product
  Map<String, int> productQuantities = {};

  @override
  void initState() {
    super.initState();
    _updateLaundryPerPiece();
    _initializeWeightsFromBasket();
  }

  void _updateLaundryPerPiece() {
    for (var categoryMap in widget.globalProducts) {
      var productsList = categoryMap[widget.category];
      if (productsList != null && productsList is List<Map<String, dynamic>>) {
        widget.laundryPerPiece[widget.category] =
            List<Map<String, dynamic>>.from(productsList);
      }
    }
  }

  void _initializeWeightsFromBasket() {
    final globalState = Provider.of<SGlobalState>(context, listen: false);

    final existingProductIndex = globalState.basketProducts.indexWhere(
      (product) => product.serviceId == widget.serviceId,
    );

    if (existingProductIndex != -1) {
      final existingProduct = globalState.basketProducts[existingProductIndex];

      final categoryIndex = existingProduct.laundryByKg.indexWhere(
        (element) => element.containsKey(widget.category),
      );

      if (categoryIndex != -1) {
        final categoryMap = existingProduct.laundryByKg[categoryIndex];

        final updatedKgValue = categoryMap[widget.category]['updatedKg'];

        if (updatedKgValue is String) {
          selectedWeight = double.tryParse(updatedKgValue) ?? 0.0;
        } else if (updatedKgValue is num) {
          selectedWeight = updatedKgValue.toDouble();
        } else {
          selectedWeight = 0.0;
        }

        print('Final Selected Weight: $selectedWeight kg');
      } else {
        print('Category not found for serviceId: ${widget.serviceId}');
      }
    } else {
      print('No product found with serviceId: ${widget.serviceId}');
    }
  }

  void _updateWeight(double weight) {
    if (weight > 30) {
      setState(() {
        isWeightLimitReached = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot exceed 30 kg limit!'),
        ),
      );
      return;
    }

    setState(() {
      selectedWeight = weight;
      isWeightLimitReached = false;
      int roundedWeight = selectedWeight.toInt();
      if (roundedWeight % 5 == 0 && roundedWeight != lastVibrationWeight) {
        Vibration.vibrate(duration: 100);
        lastVibrationWeight = roundedWeight;
      }
    });
  }

  void _onQuantityChanged(String productName, int quantity, item) {
    // double productWeight = productWeights[productName.toLowerCase()] ?? 0.0;
    int currentQuantity = productQuantities[productName] ?? 0;
    int newQuantity = currentQuantity + quantity;
    double productWeight = (item as num?)?.toDouble() ?? 0.0;
    if (newQuantity < 0) {
      newQuantity = 0;
    }
    print('item');
    print(item);
    productQuantities[productName] = newQuantity;
    double newWeight = selectedWeight + (productWeight * quantity);

    if (newWeight < 0) {
      newWeight = 0;
    }

    // Ensure weight does not exceed 30 kg
    if (newWeight > 30) {
      setState(() {
        isWeightLimitReached = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot exceed 30 kg limit!'),
        ),
      );
      return;
    }

    _updateWeight(newWeight);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSwitched ? 'Select Weight' : 'Select Clothes',
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize18,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              if ((widget.category == 'men' ||
                      widget.category == 'women' ||
                      widget.category == 'kids') &&
                  widget.laundryByKg[widget.category]['items'].length > 0)
                Row(
                  children: [
                    const Text(
                      'Per KG',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightRegular,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    CupertinoSwitch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                        });
                      },
                      activeTrackColor: AppColors.darkBlue,
                      thumbColor: AppColors.white,
                    ),
                  ],
                ),
            ],
          ),
          if (isSwitched)
            Padding(
              padding: const EdgeInsets.only(right: 60.0),
              child: Text(
                'Take a guess, our driver will verify at pickup',
                style: TextStyle(
                  color: AppColors.black.withOpacity(0.5),
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize12,
                  fontWeight: AppFonts.fontWeightRegular,
                ),
              ),
            ),
          const SizedBox(height: 24.0),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              key: ValueKey(isSwitched),
              children: [
                if (isSwitched) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: DottedTrackPainter(maxWeight: 30),
                      ),
                      SleekCircularSlider(
                        appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                            progressBarWidth: 35,
                            trackWidth: 45,
                            handlerSize: 15,
                          ),
                          customColors: CustomSliderColors(
                            trackColor: AppColors.lightGrey.withOpacity(0.7),
                            progressBarColors: [
                              AppColors.radialDarkPurple,
                              AppColors.radialMidPurple,
                              AppColors.radialGreyBlue,
                              AppColors.radialGreyPurple,
                              AppColors.radialLightGreyPurple,
                              AppColors.radialSoftGrey,
                              AppColors.radialLightGrey,
                            ],
                            dotColor: AppColors.white,
                            shadowColor: AppColors.black.withOpacity(0.3),
                            shadowMaxOpacity: 0.25,
                          ),
                          infoProperties: InfoProperties(
                            mainLabelStyle: const TextStyle(
                              color: AppColors.darkBlue,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize24,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                            modifier: (double value) {
                              final kgValue = value.toStringAsFixed(1);
                              updatedKg = kgValue;
                              return '$kgValue KGs';
                            },
                          ),
                          size: 200,
                          startAngle: 0,
                          angleRange: 360,
                        ),
                        min: 0,
                        max: 30,
                        initialValue: selectedWeight,
                        onChange: null, // Disable user interaction
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    height: 600,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          widget.laundryByKg[widget.category]['items'].length,
                      itemBuilder: (context, index) {
                        final item =
                            widget.laundryByKg[widget.category]['items'][index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ServiceItemRowKg(
                            updatedKg: updatedKg,
                            id: item['item']['_id'],
                            itemName: capitalize(item['item']['product_name']),
                            itemImagePath: item['item']['image_url'],
                            pricePerPiece: 6,
                            laundryByKg: widget.laundryByKg,
                            category: widget.category,
                            globalProducts: widget.globalProducts,
                            serviceName: widget.serviceName,
                            serviceId: widget.serviceId,
                            onQuantityChanged: (quantity) {
                              _onQuantityChanged(item['item']['product_name'],
                                  quantity, item['approx_weight']);
                            },
                            isWeightLimitReached: isWeightLimitReached,
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        final item = widget.products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ServiceItemRow(
                            id: item['id'],
                            itemName: formatStringToMultiline(
                                capitalize(item['product_name'])),
                            itemImagePath: item['image_url'],
                            pricePerPiece: item['pricePerPiece'],
                            laundryPerPiece: widget.laundryPerPiece,
                            category: widget.category,
                            globalProducts: widget.globalProducts,
                            serviceName: widget.serviceName,
                            serviceId: widget.serviceId,
                            onQuantityChanged: (quantity) {
                              _onQuantityChanged(
                                  item['product_name'], quantity, null);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DottedTrackPainter extends CustomPainter {
  final double maxWeight;
  final double dotRadius;
  final int interval;

  DottedTrackPainter({
    required this.maxWeight,
    this.dotRadius = 4.0,
    this.interval = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 20;
    final totalIntervals = (maxWeight / interval).floor();
    for (int i = 1; i <= totalIntervals; i++) {
      final angle = (2 * pi * i * interval) / maxWeight;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
