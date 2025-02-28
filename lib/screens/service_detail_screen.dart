import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rinze/components/loading_animation.dart';
import 'package:rinze/model/selected_product.dart';
import 'package:rinze/providers/service_provider.dart';
import 'package:rinze/screens/home_navigation_screen.dart';

import '../components/tabs/laundry_tab.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../utils/string_utils.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
    required this.serviceName,
    required this.imagePath,
    required this.index,
    required this.serviceId,
  });

  final String serviceName;
  final String imagePath;
  final int index;
  final String serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late String url;
  Map<String, List<Map<String, dynamic>>> laundryItems = {};
  Map<String, dynamic> laundryByKg = {};

  bool isLoading = true;
  num totalPieces = 0;
  num totalPrice = 0;
  Map<String, dynamic> selectedProducts = {
    'serviceId': '',
    'laundryPerPiece': [],
    'laundryByKg': []
  };

  Map<String, List<Map<String, dynamic>>> laundryPerPiece = {};
  List<Map<String, dynamic>> globalProducts = [];

  @override
  void initState() {
    super.initState();
    selectedProducts['serviceId'] = widget.serviceId;
    url = '${dotenv.env['API_URL']}/service/get/${widget.serviceId}';
    fetchData();
  }

  Future<void> fetchData() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

    final globalState = Provider.of<SGlobalState>(context, listen: false);
    if (globalState.selectedProducts.isNotEmpty) {
      globalProducts = globalState.selectedProducts
          .where((product) => product.serviceId == widget.serviceId)
          .expand((product) => product.laundryPerPiece)
          .toList();
    } else {
      globalProducts = [];
    }

    if (storedToken != null) {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final data = jsonDecode(response.body)['service'];
          final laundryPerPiece = data['laundryPerPiece'];
          final laundryByKG = data['laundryByKG'];

          if (laundryPerPiece != null) {
            laundryPerPiece.forEach((category, value) {
              final products = value['products'] as List<dynamic>;
              laundryItems[category] = products.map((item) {
                return {
                  'id': item['_id'],
                  'product_name': item['product_name'],
                  'pricePerPiece': item['pricePerPiece'],
                  'image_url': item['image_url'],
                };
              }).toList();
            });
          }

          laundryByKg = laundryByKG;

          _tabController = TabController(
            length: laundryItems.keys.length,
            vsync: this,
          );
          isLoading = false;
        });
      }
    }
  }

  void updateTotal(int pieces, num price) {
    setState(() {
      totalPieces += pieces;
      totalPrice += price;
    });
  }

  void addToBasket() {
    if (laundryPerPiece.isNotEmpty) {
      selectedProducts["laundryPerPiece"] ??= [];

      laundryPerPiece.forEach((category, products) {
        var existingCategory = selectedProducts["laundryPerPiece"].firstWhere(
          (entry) {
            return entry is Map<String, List<Map<String, dynamic>>> &&
                entry.keys.contains(category);
          },
          orElse: () => null,
        );

        if (existingCategory != null) {
          for (var newProduct in products) {
            var existingProduct = existingCategory[category].firstWhere(
              (product) => product["id"] == newProduct["id"],
              orElse: () => <String, dynamic>{},
            );

            if (existingProduct != null) {
              existingProduct["quantity"] += newProduct["quantity"];
            } else {
              existingCategory[category].add(newProduct);
            }
          }
        } else {
          selectedProducts["laundryPerPiece"].add({category: products});
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Items added to basket successfully!',
            style: TextStyle(
              color: AppColors.white,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
            ),
          ),
          backgroundColor: AppColors.green,
        ),
      );

      final globalState = Provider.of<SGlobalState>(context, listen: false);
      List<SelectedProduct> currentSelectedProducts =
          List.from(globalState.selectedProducts);

      currentSelectedProducts.add(
        SelectedProduct(
          serviceId: widget.serviceId,
          serviceName: widget.serviceName,
          laundryPerPiece: List<Map<String, dynamic>>.from(
              selectedProducts["laundryPerPiece"]),
          laundryByKg: List<Map<String, dynamic>>.from(
              selectedProducts["laundryByKg"] ?? []),
        ),
      );

      globalState.setSelectedProducts(currentSelectedProducts);

      if (globalState.selectedProducts.isNotEmpty &&
          globalState.selectedProducts.first.serviceId == widget.serviceId) {
      } else {
        if (kDebugMode) {
          print("No matching serviceId found.");
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basketProducts = Provider.of<SGlobalState>(context).basketProducts;

    if (isLoading) {
      return const LoadingAnimation();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Container(
                        color: AppColors.halfWhite,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/arrow_left.svg',
                                        ),
                                        const Text(
                                          'Back',
                                          style: TextStyle(
                                            color: AppColors.black,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightRegular,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  formatStringToMultiline(widget.serviceName),
                                  style: const TextStyle(
                                    color: AppColors.darkBlue,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize28,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                            Image.network(
                              widget.imagePath,
                              scale: 0.6,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 2.0,
                        right: 24.0,
                        left: 24.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 50,
                              color: AppColors.baseBlack.withOpacity(0.35),
                              child: TabBar(
                                isScrollable: true,
                                padding: const EdgeInsets.all(4.0),
                                dividerColor: AppColors.transparent,
                                unselectedLabelColor: AppColors.white,
                                unselectedLabelStyle: const TextStyle(
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize14,
                                  fontWeight: AppFonts.fontWeightSemiBold,
                                ),
                                labelColor: AppColors.darkBlue,
                                labelStyle: const TextStyle(
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize14,
                                  fontWeight: AppFonts.fontWeightSemiBold,
                                ),
                                indicator: const BoxDecoration(
                                  color: AppColors.baseWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorColor: Colors.transparent,
                                controller: _tabController,
                                tabs: [
                                  for (var category in laundryItems.keys)
                                    Tab(
                                      text: capitalize(category.trim()),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      height: MediaQuery.of(context).size.height - 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          for (var category in laundryItems.keys)
                            LaundryTab(
                              serviceName: widget.serviceName,
                              serviceId: widget.serviceId,
                              laundryPerPiece: laundryPerPiece,
                              laundryByKg: laundryByKg,
                              category: category,
                              products: laundryItems[category] ?? [],
                              globalProducts: globalProducts,
                              onUpdateTotal: updateTotal,
                            ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            if (basketProducts.isNotEmpty)
              Positioned(
                bottom: 16.0,
                left: 24.0,
                right: 24.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeBottomNavigation(selectedIndex: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    backgroundColor: AppColors.darkBlue,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'View Basket',
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
