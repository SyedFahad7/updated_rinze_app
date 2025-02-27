import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rinze/constants/app_colors.dart';
import 'package:rinze/providers/addresses_provider.dart';
import 'package:http/http.dart' as http;
import 'package:rinze/services/location_service.dart';

import '../../constants/app_fonts.dart';
import '../../utils/string_utils.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() =>
      _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  final String addressUrl =
      '${dotenv.env['API_URL']}/user/customer/addresses/get';
  final String addressPostUrl =
      '${dotenv.env['API_URL']}/user/customer/address';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> addressesList = [];
  Map<String, dynamic> defaultAddress = {};
  final LocationService _locationService = LocationService();
  bool isLoading = true;

  TextEditingController typeController = TextEditingController();
  TextEditingController houseNumberController = TextEditingController();
  TextEditingController routeController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController editTypeController = TextEditingController();
  TextEditingController editHouseNumberController = TextEditingController();
  TextEditingController editRouteController = TextEditingController();
  TextEditingController editAreaController = TextEditingController();
  String? houseNumberError;
  String? areaError;
  String? typeError;

  void validateFields(Map<String, dynamic> addressFormat) {
    setState(() {
      houseNumberError =
          houseNumberController.text.isEmpty ? 'House No. is required' : null;
      areaError = areaController.text.isEmpty ? 'Area is required' : null;
      typeError = typeController.text.isEmpty ? 'Type is required' : null;
    });

    if (houseNumberError == null && areaError == null && typeError == null) {
      sendData(addressFormat);
      clearAddressTextFields();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAddressData();
    _loadDefaultAddress();
    print('Fetch location 11111111111,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,');
    // _fetchLocation();
  }

  void _loadDefaultAddress() {
    setState(() {
      defaultAddress = Provider.of<AddressesGlobalState>(context, listen: false)
          .defaultAddress;
    });
  }

  Future<void> _fetchLocation() async {
    setState(() {
      isLoading = true;
      typeController.text = '';
      houseNumberController.text = '';
      areaController.text = '';
      routeController.text = '';
      cityController.text = '';
      stateController.text = '';
      pinCodeController.text = '';
    });
    print('Fetch location,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, liv');

    final locationData = await _locationService.getLocationAndAddress();
    print('Fetch successful,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,');

    print(locationData);
    if (locationData != null) {
      String city = locationData['locality'] ?? ' ';
      String state = locationData['administrative_area_level_2'] ?? ' ';
      String postalCode = locationData['postal_code'] ?? ' ';

      setState(() {
        cityController.text = city;
        stateController.text = state;
        pinCodeController.text = postalCode;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> Address(Map<String, dynamic> address) async {
    print(address);
    setState(() {
      isLoading = true;
    });

    setState(() {
      print('Hi,,,,,,,');
      cityController.text = address['locality'];
      stateController.text = address['administrative_area_level_1'];
      pinCodeController.text = address['postal_code'];
      print(address);
      print('Type: ${address['addressType']}');
      editTypeController.text = address['addressType'] != null
          ? capitalize(address['addressType'])
          : ' ';
      print('House number: ${address['flat_house_building_name']}');

      editHouseNumberController.text =
          address['flat_house_building_name'] != null
              ? capitalize(address['flat_house_building_name'])
              : ' ';
      print('Street number: ${address['street_number']}');
      editAreaController.text = address['street_number'] != null
          ? capitalize(address['street_number'])
          : ' ';
      print('Route: ${address['route']}');
      editRouteController.text =
          address['route'] != null ? capitalize(address['route']) : ' ';
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchAddressData() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

    if (storedToken != null) {
      print(storedToken);
      final response = await http.get(
        Uri.parse(addressUrl),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final addresses = decodedResponse['addresses'];
        setState(() {
          addressesList = addresses.map<Map<String, dynamic>>((address) {
            print(address);
            return {
              'id': (address['_id'] ?? '').toString(),
              'addressType': (address['addressType'] ?? '').toString(),
              'formatted_address':
                  (address['addressComponents']['formatted_address'] ?? '')
                      .toString(),
              'street_number':
                  (address['addressComponents']['street_number'] ?? '')
                      .toString(),
              'route': (address['addressComponents']['route'] ?? '').toString(),
              'locality':
                  (address['addressComponents']['locality'] ?? '').toString(),
              'administrative_area_level_1': (address['addressComponents']
                          ['administrative_area_level_1'] ??
                      '')
                  .toString(),
              'country':
                  (address['addressComponents']['country'] ?? '').toString(),
              'postal_code': (address['addressComponents']['postal_code'] ?? '')
                  .toString(),
              'flat_house_building_name': (address['addressComponents']
                          ['flat_house_building_name'] ??
                      '')
                  .toString(),
            };
          }).toList();

          defaultAddress =
              Provider.of<AddressesGlobalState>(context, listen: false)
                  .defaultAddress;
          if (defaultAddress.isEmpty && addressesList.isNotEmpty) {
            defaultAddress = addressesList[0];
            Provider.of<AddressesGlobalState>(context, listen: false)
                .setDefaultAddress(defaultAddress);
          }

          isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('Error: ${response.body}');
        }
      }
    } else {
      if (kDebugMode) {
        print('Token not found');
      }
    }
  }

  void setDefaultAddress(Map<String, dynamic> address) {
    setState(() {
      // Update the defaultAddress
      defaultAddress = address;

      // Update global state if necessary
      Provider.of<AddressesGlobalState>(context, listen: false)
          .setDefaultAddress(address);
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultAddress = context.watch<AddressesGlobalState>().defaultAddress;
    setState(() {
      addressesList.removeWhere((item) => item['id'] == defaultAddress['id']);
      addressesList.insert(0, defaultAddress);
    });
    return Scaffold(
      backgroundColor: AppColors.baseWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: AppColors.lightWhite,
          surfaceTintColor: AppColors.lightWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 24.0, right: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/arrow_left.svg',
                      ),
                      const SizedBox(width: 2),
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
                const SizedBox(height: 16),
                const Text(
                  'Saved Addresses',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize28,
                    fontWeight: AppFonts.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _fetchLocation();
                  showBottomSheet();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '+ Add New Address',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightSemiBold,
                      ),
                    ),
                    Divider(
                      color: AppColors.darkBlue.withValues(alpha: 0.6),
                      thickness: 1.0,
                      height: 5.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (defaultAddress.isNotEmpty)
                        for (var address in addressesList)
                          GestureDetector(
                            onTap: () {
                              setDefaultAddress(address);
                              Address(address);
                              // showEditBottomSheet(address);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                color: AppColors.halfWhite,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                border: Border.all(
                                  color: address['id'] == defaultAddress['id']
                                      ? AppColors.retroLime
                                      // .withValues(alpha: 0.06)
                                      : AppColors.black.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                spacing: 8.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        capitalize('${address['addressType']}'),
                                        style: TextStyle(
                                          color: AppColors.black
                                              .withValues(alpha: 0.6),
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize10,
                                          fontWeight: AppFonts.fontWeightBold,
                                        ),
                                      ),
                                      address['id'] == defaultAddress['id']
                                          ? const Text(
                                              'Default',
                                              style: TextStyle(
                                                color: AppColors.retroLime,
                                                fontFamily: AppFonts
                                                    .fontFamilyPlusJakartaSans,
                                                fontSize: AppFonts.fontSize10,
                                                fontWeight:
                                                    AppFonts.fontWeightBold,
                                              ),
                                            )
                                          : const Text(
                                              ' ',
                                              style: TextStyle(
                                                color: AppColors.retroLime,
                                                fontFamily: AppFonts
                                                    .fontFamilyPlusJakartaSans,
                                                fontSize: AppFonts.fontSize10,
                                                fontWeight:
                                                    AppFonts.fontWeightBold,
                                              ),
                                            ),
                                    ],
                                  ),
                                  Text(
                                    capitalize(
                                        '${address['formatted_address']}'),
                                    style: const TextStyle(
                                      color: AppColors.hintBlack,
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                      fontSize: AppFonts.fontSize16,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                    ),
                                  ),
                                  // const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showEditBottomSheet(
                                              address); // Trigger edit action
                                        },
                                        child: const Text(
                                          'Edit Address',
                                          style: TextStyle(
                                            color: AppColors
                                                .darkBlue, // Use your app's primary color
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightRegular,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor:
                                                    AppColors.baseGrey,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Container(
                                                  width: 321,
                                                  height: 173,
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Delete Address',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .hintBlack,
                                                          fontSize: AppFonts
                                                              .fontSize20,
                                                          fontWeight: AppFonts
                                                              .fontWeightSemiBold,
                                                          fontFamily: AppFonts
                                                              .fontFamilyPlusJakartaSans,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Are you sure you want to delete this address? \nThis is an irreversible action!',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .hintBlack,
                                                          fontSize: AppFonts
                                                              .fontSize12,
                                                          fontWeight: AppFonts
                                                              .fontWeightRegular,
                                                          fontFamily: AppFonts
                                                              .fontFamilyPlusJakartaSans,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 42),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // TODO: Add delete address logic here
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .fadeRed,
                                                                fontSize: AppFonts
                                                                    .fontSize14,
                                                                fontWeight: AppFonts
                                                                    .fontWeightBold,
                                                                fontFamily: AppFonts
                                                                    .fontFamilyPlusJakartaSans,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 26),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .darkBlue,
                                                                fontSize: AppFonts
                                                                    .fontSize14,
                                                                fontWeight: AppFonts
                                                                    .fontWeightBold,
                                                                fontFamily: AppFonts
                                                                    .fontFamilyPlusJakartaSans,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ); // Trigger edit action
                                        },
                                        child: const Text(
                                          'Delete Address',
                                          style: TextStyle(
                                            color: AppColors
                                                .lightRed, // Use your app's primary color
                                            fontSize: AppFonts.fontSize14,
                                            fontWeight:
                                                AppFonts.fontWeightRegular,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(
              //   width: double.infinity,
              //   height: 70.0,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       _fetchLocation();
              //       showBottomSheet();
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.darkerBlue,
              //       elevation: 0.0,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //       ),
              //     ),
              //     child: const Text(
              //       'Add New',
              //       style: TextStyle(
              //         color: AppColors.white,
              //         fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              //         fontSize: AppFonts.fontSize16,
              //         fontWeight: AppFonts.fontWeightSemiBold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendData(Map<String, dynamic> address) async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');
    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(addressPostUrl),
        headers: {
          'Content-Type': 'application/json', // Specify JSON format
          'Authorization':
              'Bearer $storedToken', // Optional: If authentication is needed
        },
        body: jsonEncode(address), // Convert Map to JSON
      );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('Data sent successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send data. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
    }
  }

  void showEditBottomSheet(Map<String, dynamic> address) {
    Address(address);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        Map<String, dynamic> savedAddress = address;

        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: AppColors.baseWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/x.svg',
                      width: 24.0,
                      height: 24.0,
                      colorFilter: const ColorFilter.mode(
                        AppColors.iconGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Edit Address',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize24,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 24.0),

              // House number
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 2.0,
                children: [
                  Text(
                    'House No. / Building Name',
                    style: TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Colors.blue,
                  selectionHandleColor:
                      AppColors.hintBlack.withValues(alpha: 0.6),
                ),
                child: TextField(
                  controller: editHouseNumberController,
                  cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                  cursorRadius: const Radius.circular(10.0),
                  decoration: InputDecoration(
                    hintText: 'e.g., Flat 102, Green Heights Apartment',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlack.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                    errorText: houseNumberError,
                    fillColor: AppColors.lightWhite,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              // building name
              const SizedBox(height: 12.0),

              // area & street number
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 2.0,
                children: [
                  Text(
                    'Area & Street Number',
                    style: TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Colors.blue,
                  selectionHandleColor:
                      AppColors.hintBlack.withValues(alpha: 0.6),
                ),
                child: TextField(
                  controller: editAreaController,
                  cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                  cursorRadius: const Radius.circular(10.0),
                  decoration: InputDecoration(
                    hintText: 'e.g., Downtown, Baker Street',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlack.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                    errorText: areaError,
                    errorStyle: const TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize12,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    fillColor: AppColors.lightWhite,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 12.0),

              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Road Name / Route (optional)',
                    style: TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Colors.blue,
                  selectionHandleColor:
                      AppColors.hintBlack.withValues(alpha: 0.6),
                ),
                child: TextField(
                  controller: editRouteController,
                  cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                  cursorRadius: const Radius.circular(10.0),
                  decoration: InputDecoration(
                    hintText: 'e.g., Road No. 5, NH-44',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlack.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                    fillColor: AppColors.lightWhite,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),

              const SizedBox(height: 12.0),

              // city and state
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'City',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: cityController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'State',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: stateController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // pin code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'Pin Code',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: pinCodeController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'Type',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            controller: editTypeController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              hintText: 'e.g., home, work etc.',
                              hintStyle: TextStyle(
                                color:
                                    AppColors.hintBlack.withValues(alpha: 0.6),
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                              errorText: typeError,
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        clearAddressTextFields();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 16.0,
                        ),
                        backgroundColor: AppColors.transparent,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkBlue,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> addressFormat = {
                          'addressType': typeController.text.trim(),
                          // 'addressComponents': {
                          //   "formatted_address":
                          //       "${houseNumberController.text.trim()}, ${areaController.text.trim()}, ${routeController.text.trim()} ${cityController.text.trim()}, ${stateController.text.trim()}, ${pinCodeController.text.trim()}, ${locationData?['country']}",
                          //   "street_number": areaController.text.trim(),
                          //   "route": routeController.text.trim(),
                          //   "locality": cityController.text.trim(),
                          //   "administrative_area_level_1":
                          //       stateController.text.trim(),
                          //   "administrative_area_level_2":
                          //       cityController.text.trim(),
                          //   "postal_code": pinCodeController.text.trim(),
                          //   "place_id": "ChIJOwg_06VPwokRYv5342tmRRA",
                          //   "flat_house_building_name":
                          //       houseNumberController.text.trim(),
                          // },
                        };

                        print('Print 2222222222222222222222222222222222222222');
                        validateFields(addressFormat);
                        print(
                            'Print 55555555555555555555555555555555555555555');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 16.0,
                        ),
                        backgroundColor: AppColors.darkerBlue,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Edit',
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
            ],
          ),
        );
      },
    );
  }

  void clearAddressTextFields() {
    typeController.clear();
    houseNumberController.clear();
    routeController.clear();
    areaController.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();
  }

  void showBottomSheet() {
    _fetchLocation();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: AppColors.baseWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/x.svg',
                      width: 24.0,
                      height: 24.0,
                      colorFilter: const ColorFilter.mode(
                        AppColors.iconGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Add New Address',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize24,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: 24.0),

              // House number
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 2.0,
                children: [
                  Text(
                    'House No. / Building Name',
                    style: TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Colors.blue,
                  selectionHandleColor:
                      AppColors.hintBlack.withValues(alpha: 0.6),
                ),
                child: TextField(
                  controller: houseNumberController,
                  cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                  cursorRadius: const Radius.circular(10.0),
                  decoration: InputDecoration(
                    hintText: 'e.g., Flat 102, Green Heights Apartment',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlack.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                    errorText: houseNumberError,
                    fillColor: AppColors.lightWhite,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              // building name
              const SizedBox(height: 12.0),

              // area & street number
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 2.0,
                children: [
                  Text(
                    'Area & Street Number',
                    style: TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Colors.blue,
                  selectionHandleColor:
                      AppColors.hintBlack.withValues(alpha: 0.6),
                ),
                child: TextField(
                  controller: areaController,
                  cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                  cursorRadius: const Radius.circular(10.0),
                  decoration: InputDecoration(
                    hintText: 'e.g., Downtown, Baker Street',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlack.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                    errorText: areaError,
                    errorStyle: const TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize12,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    fillColor: AppColors.lightWhite,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 12.0),

              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Road Name / Route (optional)',
                    style: TextStyle(
                      color: AppColors.hintBlack,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextSelectionTheme(
                data: TextSelectionThemeData(
                  selectionColor: Colors.blue,
                  selectionHandleColor:
                      AppColors.hintBlack.withValues(alpha: 0.6),
                ),
                child: TextField(
                  controller: routeController,
                  cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                  cursorRadius: const Radius.circular(10.0),
                  decoration: InputDecoration(
                    hintText: 'e.g., Road No. 5, NH-44',
                    hintStyle: TextStyle(
                      color: AppColors.hintBlack.withValues(alpha: 0.6),
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                    fillColor: AppColors.lightWhite,
                    filled: true,
                    contentPadding: const EdgeInsets.all(16.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),

              const SizedBox(height: 12.0),

              // city and state
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'City',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: cityController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'State',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: stateController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // pin code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'Pin Code',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: pinCodeController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 2.0,
                        children: [
                          Text(
                            'Type',
                            style: TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.lightRed,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      SizedBox(
                        width: 150.0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            controller: typeController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              hintText: 'e.g., home, work etc.',
                              hintStyle: TextStyle(
                                color:
                                    AppColors.hintBlack.withValues(alpha: 0.6),
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                              errorText: typeError,
                              fillColor: AppColors.lightWhite,
                              filled: true,
                              contentPadding: const EdgeInsets.all(16.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color:
                                      AppColors.black.withValues(alpha: 0.06),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        clearAddressTextFields();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 16.0,
                        ),
                        backgroundColor: AppColors.transparent,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkBlue,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize16,
                          fontWeight: AppFonts.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        print('Print 111111111111111111111111111111111');
                        final locationData =
                            await _locationService.getLocationAndAddress();

                        Map<String, dynamic> addressFormat = {
                          'addressType': typeController.text.trim(),
                          'coordinates': {
                            'type': 'Point',
                            'coordinates': [
                              locationData?['longitude'],
                              locationData?['latitude'],
                            ],
                          },
                          'addressComponents': {
                            "formatted_address":
                                "${houseNumberController.text.trim()}, ${areaController.text.trim()}, ${routeController.text.trim()} ${cityController.text.trim()}, ${stateController.text.trim()}, ${pinCodeController.text.trim()}, ${locationData?['country']}",
                            "street_number": areaController.text.trim(),
                            "route": routeController.text.trim(),
                            "locality": cityController.text.trim(),
                            "administrative_area_level_1":
                                stateController.text.trim(),
                            "administrative_area_level_2":
                                cityController.text.trim(),
                            "country": locationData?['country'],
                            "postal_code": pinCodeController.text.trim(),
                            "place_id": "ChIJOwg_06VPwokRYv5342tmRRA",
                            "flat_house_building_name":
                                houseNumberController.text.trim(),
                          },
                        };

                        print('Print 2222222222222222222222222222222222222222');
                        validateFields(addressFormat);
                        print(
                            'Print 55555555555555555555555555555555555555555');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 16.0,
                        ),
                        backgroundColor: AppColors.darkerBlue,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Save',
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
            ],
          ),
        );
      },
    );
  }
}
