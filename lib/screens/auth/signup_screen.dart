import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    this.phoneNumber,
  });

  final String? phoneNumber;

  static const id = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  late var _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool isButtonActive = false;
  bool isTermsAccepted = false;
  bool isConsentGiven = false;

  static const String screen = 'signup';

  void _validateForm() {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();

    bool isValidName = name.isNotEmpty;
    bool isValidPhone =
        phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
    bool isValidEmail = email.contains('@');

    setState(() {
      isButtonActive = isValidName &&
          isValidPhone &&
          isValidEmail &&
          isTermsAccepted &&
          isConsentGiven;
    });

    // Dismiss the keyboard only when exactly 10 digits are entered for phone number
    if (_phoneController.text.length == 10 &&
        FocusScope.of(context).focusedChild == _phoneController) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');

    // Attach listeners for form validation
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> sendOtp(String mobileNumber) async {
    final url = '${dotenv.env['API_URL']}/auth/otp/mobile/send';

    // Show loading dialog
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.darkBlue),
        );
      },
      barrierDismissible: false, // Prevent closing dialog by tapping outside
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
        }),
      );
      final responseBody = jsonDecode(response.body);
      // Close the loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // OTP sent successfully
        if (kDebugMode) {
          print('OTP sent successfully');
        }

        // Navigate to OTPScreen
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 500),
            child: OTPScreen(
              phoneNumber: _phoneController.text,
              email: _emailController.text,
              fullName: _nameController.text,
              screen: screen,
            ),
          ),
        );
      } else {
        // Handle error responses
        if (kDebugMode) {
          print('Error response: ${response.body}');
        }

        // Specific navigation based on error message
        if (responseBody['msg'] == 'Mobile number already registered.') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.lightRed,
              content: Text(
                responseBody['msg'] + " please Login" ?? 'Failed to send OTP!',
                style: const TextStyle(
                  color: AppColors.white,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize16,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ),
          );
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 500),
              child: LoginScreen(
                phoneNumber:
                    _phoneController.text, // Pass phone number if needed
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle network or other unexpected errors
      Navigator.of(context).pop(); // Ensure dialog is closed
      if (kDebugMode) {
        print('Error occurred while sending OTP: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.lightRed,
          content: Text(
            'Failed to send OTP! Please try again later',
            style: TextStyle(
              color: AppColors.white,
              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              fontSize: AppFonts.fontSize16,
              fontWeight: AppFonts.fontWeightMedium,
            ),
          ),
        ),
      );
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                height: 250.0,
                decoration: const BoxDecoration(
                  gradient: AppColors.customBlueGradient,
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signup',
                            style: TextStyle(
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize26,
                              fontWeight: AppFonts.fontWeightSemiBold,
                              color: AppColors.hintWhite,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Welcome to Rinze Laundry',
                            style: TextStyle(
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightRegular,
                              color: AppColors.hintWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(
                  right: 24.0,
                  bottom: 24.0,
                  left: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name TextField
                    const Text(
                      'Name',
                      style: TextStyle(
                        color: AppColors.hintBlack,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightMedium,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextField(
                      controller: _nameController,
                      cursorColor: AppColors.hintBlack.withOpacity(0.6),
                      cursorRadius: const Radius.circular(10.0),
                      decoration: InputDecoration(
                        hintText: 'Enter Name',
                        hintStyle: TextStyle(
                          color: AppColors.hintBlack.withOpacity(0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                        fillColor: AppColors.lightWhite,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Phone Number TextField
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: AppColors.hintBlack,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightMedium,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      cursorColor: AppColors.hintBlack.withOpacity(0.6),
                      cursorRadius: const Radius.circular(10.0),
                      decoration: InputDecoration(
                        hintText: 'Enter Phone Number',
                        hintStyle: TextStyle(
                          color: AppColors.hintBlack.withOpacity(0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                        fillColor: AppColors.lightWhite,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email TextField
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: AppColors.hintBlack,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightMedium,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: AppColors.hintBlack.withOpacity(0.6),
                      cursorRadius: const Radius.circular(10.0),
                      decoration: InputDecoration(
                        hintText: 'Enter Email Address',
                        hintStyle: TextStyle(
                          color: AppColors.hintBlack.withOpacity(0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                        fillColor: AppColors.lightWhite,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.06),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Terms & Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: AppColors.green,
                          ),
                          child: Transform.scale(
                            scale: 1.4,
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: const BorderSide(
                                  color: AppColors.green,
                                  width: 0.1,
                                ),
                              ),
                              checkColor: Colors.white,
                              activeColor: Colors.green,
                              value: isTermsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  isTermsAccepted = value ?? false;
                                  _validateForm();
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I accept the ',
                              style: const TextStyle(
                                color: AppColors.hintBlack,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightRegular,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchURL(
                                        'https://rinzelaundry.com/terms-conditions/'),
                                ),
                                const TextSpan(
                                  text: ' and have read the ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _launchURL(
                                        'https://rinzelaundry.com/privacy-policy/'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Consent Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: AppColors.green,
                          ),
                          child: Transform.scale(
                            scale: 1.4,
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: const BorderSide(
                                  color: AppColors.green,
                                  width: 0.1,
                                ),
                              ),
                              checkColor: Colors.white,
                              activeColor: Colors.green,
                              value: isConsentGiven,
                              onChanged: (bool? value) {
                                setState(() {
                                  isConsentGiven = value ?? false;
                                  _validateForm();
                                });
                              },
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text:
                                  'I hereby give my consent to receive Call/SMS/Email/Whatsapp communication from Rinze Laundry Pvt. Ltd. ',
                              style: TextStyle(
                                color: AppColors.hintBlack,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightRegular,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Already a member? Login button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const LoginScreen(),
                              duration: const Duration(milliseconds: 500),
                              isIos: true,
                            ),
                          );
                        },
                        child: const Text(
                          'Already a member? Login',
                          style: TextStyle(
                            color: AppColors.greyPurple,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Continue button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 64.0,
                        child: ElevatedButton(
                          onPressed: isButtonActive
                              ? () async {
                                  final mobileNumber = _phoneController.text;
                                  await sendOtp(mobileNumber);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonActive
                                ? AppColors.darkBlue
                                : AppColors.baseWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: isButtonActive
                              ? const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Color(0xFFFCFCFD),
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize16,
                                    fontWeight: AppFonts.fontWeightSemiBold,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: AppColors.greyPurple,
                                    fontFamily:
                                        AppFonts.fontFamilyPlusJakartaSans,
                                    fontSize: AppFonts.fontSize16,
                                    fontWeight: AppFonts.fontWeightSemiBold,
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
    );
  }
}
