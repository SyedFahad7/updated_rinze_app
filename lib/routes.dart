import 'package:flutter/material.dart';
import 'package:rinze/screens/auth/login_screen.dart';
import 'package:rinze/screens/auth/signup_screen.dart';
import 'package:rinze/screens/home_navigation_screen.dart';
import 'package:rinze/screens/main/basket_screen.dart';
import 'package:rinze/screens/main/home_screen.dart';
import 'package:rinze/screens/main/orders_screen.dart';
import 'package:rinze/screens/main/services_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    SignupScreen.id: (context) => const SignupScreen(),
    LoginScreen.id: (context) => const LoginScreen(),
    HomeBottomNavigation.id: (context) => const HomeBottomNavigation(),
    HomeScreen.id: (context) => const HomeScreen(),
    BasketScreen.id: (context) => const BasketScreen(),
    OrdersScreen.id: (context) => const OrdersScreen(
          tabIndex: 0,
        ),
    ServicesScreen.id: (context) => const ServicesScreen(),
  };
}
