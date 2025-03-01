import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rinze/components/marketing_screen.dart';
import 'package:rinze/components/services_section_item.dart';
import 'package:rinze/providers/service_provider.dart';
import 'package:rinze/screens/home_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rinze/components/loading_animation.dart';
import 'package:rinze/components/pr_modals/wedding_modal_screen.dart';
import 'package:rinze/providers/addresses_provider.dart';
import 'package:rinze/screens/laundry_item_screen.dart';
import 'package:rinze/screens/laundry_tips_screen.dart';
import 'package:rinze/screens/main/basket_screen.dart';
import 'package:rinze/screens/profile/delivery_addresses_screen.dart';
import 'package:rinze/screens/profile/notification_history_screen.dart';
import 'package:rinze/screens/profile/help_support_screen.dart';
import 'package:rinze/screens/profile/user_profile_screen.dart';
import 'package:rinze/providers/customer_provider.dart';

import '../../components/action_container.dart';
import '../../components/pr_modals/free_delivery_modal.dart';
import '../../components/pr_modals/wardrobe_modal_screen.dart';
import '../../components/home_category_section.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../model/service.dart';
import '../../utils/string_utils.dart';
import '../service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const id = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String productUrl = '${dotenv.env['API_URL']}/product/getAll';
  final String userUrl = '${dotenv.env['API_URL']}/user/currentUser';
  final String addressUrl =
      '${dotenv.env['API_URL']}/user/customer/addresses/get';
  List<Map<String, dynamic>> addressesList = [];
  Map<String, dynamic> defaultAddress = {};
  List<dynamic> data = [];
  bool isLoading = true;
  final String servicesUrl = '${dotenv.env['API_URL']}/service/getAll';
  List<ServiceModel> services = [];

  final List<String> _placeholders = [
    'Search',
    'Search "Washing"',
    'Search "Ironing"',
    'Search "Dry Cleaning"',
    'Search "Deep Cleaning"',
    'Search "Washing & Ironing"',
  ];
  int _currentIndex = 0;
  late Timer _timer = Timer(Duration.zero, () {});

  late AnimationController _animationController;
  late Animation<double> _animation;

  late Timer _placeholderTimer;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  final TextEditingController _searchController = TextEditingController();
  List<ServiceModel> _filteredServices = [];

  PageController _pageController = PageController(viewportFraction: 1);
  int _currentPage = 0;
  late Timer _carouselTimer;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  bool _showMarketingMessage = true;

  ScrollController _scrollController = ScrollController();
  double _leftPadding = 16.0;

  Future<void> fetchUserData() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

    if (storedToken != null) {
      final response = await http.get(
        Uri.parse(userUrl),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final profileDetails = decodedResponse['user'];
        print('olllldldl;nbgnfbngnbijsgijnb');
        print(profileDetails['dob']);
        // Store the user data in the provider
        if (mounted) {
          final customerProvider =
              Provider.of<CustomerGlobalState>(context, listen: false);
          customerProvider.setUserData(profileDetails);

          setState(() {
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
  void initState() {
    super.initState();
    fetchServicesData();
    fetchUserData();
    fetchProductData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showMarketingMessage = true;
      });
      print("Marketing message triggered: $_showMarketingMessage");
    });

    _pageController = PageController(viewportFraction: 1);

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scrollController.addListener(() {
      if (_scrollController.offset > 0) {
        setState(() {
          _leftPadding = 0.0;
        });
      } else {
        setState(() {
          _leftPadding = 16.0;
        });
      }
    });

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _revealAnimation = Tween<double>(begin: -150, end: 0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeInOut),
    );

    // Trigger reveal animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealController
          .forward()
          .then((_) => Future.delayed(const Duration(seconds: 6), () {
                _revealController.reverse();
              }));
    });

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    // Start the carousel timer after UI build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCarouselTimer();
    });
    // Start the placeholder text timer
    _placeholderTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _placeholders.length;
      });
    });
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredServices = [];
      });
    } else {
      setState(() {
        _filteredServices = services.where((service) {
          return service.serviceName.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> fetchAddressData() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

    if (storedToken != null) {
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

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _animationController.dispose();
    _carouselTimer.cancel();
    _focusNode.dispose();
    _pageController.dispose();
    _revealController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _placeholderTimer.cancel(); // Dispose of the placeholder timer
    super.dispose();
  }

  Future<void> fetchProductData() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

    if (storedToken != null) {
      final response = await http.get(
        Uri.parse(productUrl),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            data = jsonDecode(response.body)['data'];
            fetchAddressData();
            isLoading = false;
          });
        }

        // Show the Free Delivery Modal randomly (1 out of 3 times)
        if (Random().nextInt(3) == 0) {
          _showRandomModal();
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

  void _showRandomModal() async {
    final prefs = await SharedPreferences.getInstance();
    int appOpenCount = prefs.getInt('appOpenCount') ?? 0;

    appOpenCount++;
    await prefs.setInt('appOpenCount', appOpenCount);

    if (appOpenCount % 3 == 0) {
      final List<Widget> modals = [
        const WeddingModalScreen(),
        const FreeDeliveryModal(),
        const WardrobeModalScreen(),
      ];

      final randomModal = modals[Random().nextInt(modals.length)];

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => randomModal,
          transitionAnimationController: AnimationController(
            duration: const Duration(milliseconds: 500),
            vsync: this,
          ),
        );
      }
    }
  }

  Future<void> fetchServicesData() async {
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');

    if (storedToken != null) {
      final response = await http.get(
        Uri.parse(servicesUrl),
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
    final basketProducts = Provider.of<SGlobalState>(context).basketProducts;
    double screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const LoadingAnimation();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          if (_showMarketingMessage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100, // Adjust the height as needed
                color:
                    Colors.transparent, // Ensure it doesn't block other widgets
                child: MarketingMessage(
                  message: "Get 20% off on your first order! 🎉",
                  displayDuration: const Duration(seconds: 50),
                  onDismiss: () {
                    setState(() {
                      _showMarketingMessage = false;
                    });
                  },
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 640.0, // Adjust the height as needed
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.lighterBlue, AppColors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Winter flakes with animation
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: -60,
                top: 32 + _animation.value,
                child: Transform(
                  transform: Matrix4.identity()..setEntry(2, 3, 0.001),
                  alignment: FractionalOffset.center,
                  child: Image.asset(
                    'assets/images/cloud.png',
                    width: 200,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                right: -10,
                top: 15,
                child: Image.asset(
                  'assets/images/sun.png',
                  // width: 100,
                  opacity: const AlwaysStoppedAnimation(0.7),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                right: -30,
                top: 72 + _animation.value,
                child: Image.asset(
                  'assets/images/cloud_2.png',
                  width: 200,
                ),
              );
            },
          ),
          //MAIN Screen
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Profile Row
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/map_pin.svg',
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(width: 4.0),
                                Consumer<AddressesGlobalState>(builder:
                                    (context, addressesGlobalState, child) {
                                  return Text(
                                    defaultAddress.isNotEmpty
                                        ? truncateText(
                                            capitalize(
                                                '${addressesGlobalState.defaultAddress['formatted_address']}'),
                                            15,
                                          )
                                        : 'Add an Address',
                                    style: const TextStyle(
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                      fontSize: AppFonts.fontSize16,
                                      fontWeight: AppFonts.fontWeightRegular,
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8.0),
                                SvgPicture.asset(
                                  'assets/icons/arrow_down.svg',
                                  width: 16.0,
                                  height: 16.0,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UserProfileScreen(),
                                ),
                              );
                            },
                            child: Consumer<CustomerGlobalState>(
                              builder: (context, customerProvider, child) {
                                final userData = customerProvider.userData;
                                final profileImageUrl = userData[
                                        'profileImg'] ??
                                    'https://cdn-icons-png.flaticon.com/128/1077/1077063.png';
                                return CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                  radius: 18.0,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar Row
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 24.0,
                        bottom: 12.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 45.0,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 2.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.lightWhite,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: AppColors.black
                                                  .withValues(alpha: 0.06),
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/icons/search.svg'),
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        focusNode: _focusNode,
                                                        cursorHeight: 20.0,
                                                        cursorColor:
                                                            AppColors.darkBlue,
                                                        cursorWidth: 2.0,
                                                        controller:
                                                            _searchController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8.0,
                                                            vertical:
                                                                14.0, // Center vertical padding
                                                          ),
                                                        ),
                                                        style: const TextStyle(
                                                          fontFamily: AppFonts
                                                              .fontFamilyPlusJakartaSans,
                                                          fontSize: AppFonts
                                                              .fontSize14,
                                                          fontWeight: AppFonts
                                                              .fontWeightLight,
                                                        ),
                                                      ),
                                                    ),
                                                    if (!_isFocused &&
                                                        _searchController
                                                            .text.isEmpty)
                                                      Positioned.fill(
                                                        child: IgnorePointer(
                                                          child:
                                                              AnimatedSwitcher(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            transitionBuilder: (Widget
                                                                    child,
                                                                Animation<
                                                                        double>
                                                                    animation) {
                                                              return FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child:
                                                                    SlideTransition(
                                                                  position: Tween<
                                                                      Offset>(
                                                                    begin:
                                                                        const Offset(
                                                                            0,
                                                                            0.6),
                                                                    end:
                                                                        const Offset(
                                                                            0,
                                                                            0),
                                                                  ).animate(
                                                                      animation),
                                                                  child: child,
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              _placeholders[
                                                                  _currentIndex],
                                                              key: ValueKey<
                                                                      int>(
                                                                  _currentIndex),
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily: AppFonts
                                                                    .fontFamilyPlusJakartaSans,
                                                                fontSize: AppFonts
                                                                    .fontSize14,
                                                                fontWeight: AppFonts
                                                                    .fontWeightLight,
                                                              ),
                                                            ),
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
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              Container(
                                width: 45.0,
                                height: 45.0,
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: AppColors.lightWhite,
                                  border: Border.all(
                                    color:
                                        AppColors.black.withValues(alpha: 0.06),
                                    width: 2.0,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationHistoryScreen(),
                                      ),
                                    );
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/bell.svg',
                                    width: 20.0,
                                    height: 20.0,
                                  ),
                                  iconSize: 24.0,
                                ),
                              ),
                            ],
                          ),
                          if (_filteredServices.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.lightWhite.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                children: _filteredServices.map((service) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        leading:
                                            Image.network(service.imagePath),
                                        title: Text(service.serviceName),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ServiceDetailScreen(
                                                serviceName: capitalize(
                                                    service.serviceName),
                                                imagePath: service.imagePath,
                                                index:
                                                    services.indexOf(service),
                                                serviceId: service.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const Divider(), // Divider between services
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    // Carousel of Banners
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.2,
                            ),
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return const HomeBottomNavigation(
                                          selectedIndex: 1,
                                        );
                                      },
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image.asset(
                                        'assets/images/rinze_main_banner.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return const HomeBottomNavigation(
                                          selectedIndex: 3,
                                        );
                                      },
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SvgPicture.asset(
                                      'assets/images/schedule_banner.svg',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: SvgPicture.asset(
                                    'assets/images/goldpass_banner.svg',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: 3,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 10.0,
                              dotWidth: 10.0,
                              activeDotColor: AppColors.darkBlue,
                              dotColor: AppColors.iconGrey,
                              expansionFactor: 3,
                              spacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Action Containers Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Help and support container
                          ActionContainer(
                            icon: SvgPicture.asset('assets/icons/headset.svg'),
                            title: 'Help & Support',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HelpSupportScreen(),
                                ),
                              );
                            },
                            padding: const EdgeInsets.only(left: 24.0),
                          ),
                          const SizedBox(width: 8.0),

                          // Schedule a pickup container
                          ActionContainer(
                            icon: SvgPicture.asset('assets/icons/schedule.svg'),
                            title: 'Schedule a Pickup',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BasketScreen(),
                                ),
                              );
                            },
                            padding: const EdgeInsets.all(0.0),
                          ),
                          const SizedBox(width: 8.0),

                          // Laundry Tips Container
                          ActionContainer(
                            icon: SvgPicture.asset(
                              'assets/icons/services.svg',
                              colorFilter: const ColorFilter.mode(
                                AppColors.darkBlue,
                                BlendMode.srcIn,
                              ),
                            ),
                            title: 'Laundry Tips',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LaundryTipsScreen(),
                                ),
                              );
                            },
                            padding: const EdgeInsets.only(right: 24.0),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Services Section with Shimmer Effect
                    SizedBox(
                      height: 150.0,
                      child: Padding(
                        padding: EdgeInsets.only(left: _leftPadding),
                        child: isLoading
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: 5,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 120.0,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: services.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ServiceSectionItem(
                                    imagePath: services[index].imagePath,
                                    title: formatStringToMultiline(capitalize(
                                        services[index].serviceName)),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ServiceDetailScreen(
                                            serviceName: capitalize(
                                                services[index].serviceName),
                                            imagePath:
                                                services[index].imagePath,
                                            index: index,
                                            serviceId: services[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 12.0),

                    // Products Section with Shimmer Effect
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 150.0,
                                            height: 20.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 8.0),
                                          Container(
                                            width: double.infinity,
                                            height: 100.0,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final categoryData = data[index];

                                  if (categoryData['title'] == 'traditional') {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: SvgPicture.asset(
                                            'assets/images/traditional_holding.svg',
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 16.0),
                                          decoration: const BoxDecoration(
                                            gradient:
                                                AppColors.traditionalGradient,
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: HomeCategorySection(
                                              category: capitalize(
                                                  '${categoryData['title']}\'s categories'),
                                              sections: List<SectionItem>.from(
                                                categoryData['products']
                                                    .map<SectionItem>(
                                                        (product) {
                                                  return SectionItem(
                                                    imagePath:
                                                        product['image_url'],
                                                    title: capitalize(product[
                                                        'product_name']),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              LaundryItemScreen(
                                                            category:
                                                                categoryData[
                                                                    'title'],
                                                            imagePath: product[
                                                                'image_url'],
                                                            itemName: capitalize(
                                                                product[
                                                                    'product_name']),
                                                            productId:
                                                                product['_id'],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    isTraditional: true,
                                                    isKids: false,
                                                  );
                                                }),
                                              ),
                                              isTraditional: true,
                                              isKids: false,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (categoryData['title'] == 'kids') {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 16.0),
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12.0,
                                                  horizontal: 24.0,
                                                ),
                                                width: double.infinity,
                                                child: Image.asset(
                                                  'assets/images/kids_banner_2.png',
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16),
                                                child: HomeCategorySection(
                                                  category: capitalize(
                                                      '${categoryData['title']} categories'), // Keep it in small letters
                                                  sections:
                                                      List<SectionItem>.from(
                                                    categoryData['products']
                                                        .map<SectionItem>(
                                                            (product) {
                                                      return SectionItem(
                                                        imagePath: product[
                                                            'image_url'],
                                                        title: capitalize(
                                                            product[
                                                                'product_name']),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LaundryItemScreen(
                                                                category:
                                                                    categoryData[
                                                                        'title'],
                                                                imagePath: product[
                                                                    'image_url'],
                                                                itemName:
                                                                    capitalize(
                                                                        product[
                                                                            'product_name']),
                                                                productId:
                                                                    product[
                                                                        '_id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        isTraditional: false,
                                                        isKids: true,
                                                      );
                                                    }),
                                                  ),
                                                  isTraditional: false,
                                                  isKids: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: HomeCategorySection(
                                        category: capitalize(
                                            '${categoryData['title']}\'s categories'),
                                        sections: List<SectionItem>.from(
                                          categoryData['products']
                                              .map<SectionItem>((product) {
                                            return SectionItem(
                                              imagePath: product['image_url'],
                                              title: capitalize(
                                                  product['product_name']),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LaundryItemScreen(
                                                      category:
                                                          categoryData['title'],
                                                      imagePath:
                                                          product['image_url'],
                                                      itemName: capitalize(
                                                          product[
                                                              'product_name']),
                                                      productId: product['_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              isTraditional: false,
                                              isKids: false,
                                            );
                                          }),
                                        ),
                                        isTraditional: false,
                                        isKids: false,
                                      ),
                                    );
                                  }
                                },
                              ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Laundry? \nWe\'ve got it \ncovered!',
                              style: TextStyle(
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize32,
                                fontWeight: AppFonts.fontWeightExtraBold,
                                color:
                                    AppColors.darkGrey.withValues(alpha: 0.3),
                                height: 1.3,
                              ),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: SvgPicture.asset(
                                    'assets/images/blue_heart.svg',
                                    width: 30.0,
                                    height: 30.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 3,
                      color: AppColors.lightGrey,
                      indent: 24.0,
                      endIndent: 24.0,
                    ),
                    const SizedBox(height: 10.0),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Image.asset(
                            'assets/images/buildings.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/splash_screen_rinze_r_letter.svg',
                                        width: 50.0,
                                        height: 50.0,
                                      ),
                                      const SizedBox(width: 2.0),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 24.0),
                                        child: Text(
                                          "inze",
                                          style: TextStyle(
                                            fontSize: AppFonts.fontSize32,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontWeight:
                                                AppFonts.fontWeightExtraBold,
                                            color: AppColors.shadeBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    "Made for India 🇮🇳",
                                    style: TextStyle(
                                      fontSize: AppFonts.fontSize14,
                                      fontFamily:
                                          AppFonts.fontFamilyPlusJakartaSans,
                                      fontWeight: AppFonts.fontWeightSemiBold,
                                      color: AppColors.shadeBlue,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Crafted at",
                                      style: TextStyle(
                                        fontSize: AppFonts.fontSize16,
                                        fontFamily:
                                            AppFonts.fontFamilyPlusJakartaSans,
                                        fontWeight: AppFonts.fontWeightSemiBold,
                                        color: AppColors.shadeBlue,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/xunoia.png',
                                          width: 16.0,
                                          height: 16.0,
                                        ),
                                        const SizedBox(width: 4.0),
                                        const Text(
                                          "XUNOIA",
                                          style: TextStyle(
                                            fontSize: AppFonts.fontSize16,
                                            fontFamily: AppFonts
                                                .fontFamilyPlusJakartaSans,
                                            fontWeight:
                                                AppFonts.fontWeightExtraBold,
                                            color: AppColors.shadeBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (basketProducts.isNotEmpty) const SizedBox(height: 50.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
