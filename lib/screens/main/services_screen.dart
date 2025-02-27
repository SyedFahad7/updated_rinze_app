import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rinze/components/loading_animation.dart';
import 'package:rinze/screens/service_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:rinze/utils/string_utils.dart';

import '../../components/service_card.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../model/service.dart';
import '../../providers/service_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  static const id = '/services';

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String url = '${dotenv.env['API_URL']}/service/getAll';
  List<ServiceModel> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
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
        final List<dynamic> serviceData = jsonDecode(response.body)['services'];
        List<ServiceModel> fetchedServices = serviceData.map((service) {
          return ServiceModel(
            serviceName: service['serviceTitle'],
            imagePath: service['image_url'],
            pricePerKg: service['pricePerKg'] ?? 0.0,
            id: service['_id'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            services = fetchedServices;
            isLoading = false;
          });
        }
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } else {
      if (kDebugMode) {
        print('Token not found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalServicesSelected =
        Provider.of<SGlobalState>(context).basketProducts.length;
    if (isLoading) {
      return const LoadingAnimation();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      'Services',
                      style: TextStyle(
                        color: AppColors.hintWhite,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize26,
                        fontWeight: AppFonts.fontWeightSemiBold,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'What are you looking for?',
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
              Container(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 16.0,
                ),
                width: double.infinity,
                color: AppColors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Services',
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize18,
                        fontWeight: AppFonts.fontWeightMedium,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20.0,
                        crossAxisSpacing: 2.0,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(
                          serviceName: formatStringToMultiline(
                            capitalize(services[index].serviceName),
                          ),
                          imagePath: services[index].imagePath,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailScreen(
                                  serviceName:
                                      capitalize(services[index].serviceName),
                                  imagePath: services[index].imagePath,
                                  index: index,
                                  serviceId: services[index].id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (totalServicesSelected != 0) const SizedBox(height: 80.0),
            ],
          ),
        ),
      ),
    );
  }
}
