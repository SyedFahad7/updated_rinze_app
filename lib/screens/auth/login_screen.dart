import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'signup_screen.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.phoneNumber,
  });

  final String? phoneNumber;
  static const id = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  bool _isLoading = false;
  static const String screen = 'login';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber ?? '');
    _phoneController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateButtonState);
    _phoneController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final textLength = _phoneController.text.length;

    setState(() {
      _isButtonEnabled = textLength == 10;
    });

    // Dismiss the keyboard only when exactly 10 digits are entered
    if (textLength == 10) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard only when 10 digits
    } else {
      // Make sure the keyboard is visible when the user starts editing again
      if (!FocusScope.of(context).hasFocus) {
        FocusScope.of(context).requestFocus(
            FocusNode()); // Ensure keyboard appears when user deletes digits
      }
    }
  }

  Future<void> sendOtp(String mobileNumber) async {
    final url = '${dotenv.env['API_URL']}/auth/otp/mobile/send/customer';

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog manually
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.darkBlue),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
        }),
      );

      Navigator.of(context).pop();

      final responseBody = jsonDecode(response.body);

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
              email: '',
              fullName: '',
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
        if (responseBody['msg'] == 'User not found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.lightRed,
              content: Text(
                responseBody['msg'] + " please Sign Up" ??
                    'Failed to send OTP!',
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
              child: SignupScreen(
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
            'Failed to send OTP!',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Blue Container
            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              height: 250.0,
              decoration: const BoxDecoration(
                gradient: AppColors.customBlueGradient,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      color: AppColors.hintWhite,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize26,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Welcome to Rinze Laundry',
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

            // White Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: Colors.blue,
                            selectionHandleColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            cursorColor:
                                AppColors.hintBlack.withValues(alpha: 0.6),
                            cursorRadius: const Radius.circular(10.0),
                            decoration: InputDecoration(
                              hintText: 'Enter Phone Number',
                              hintStyle: TextStyle(
                                color:
                                    AppColors.hintBlack.withValues(alpha: 0.6),
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
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const SignupScreen(),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: const Text(
                            textAlign: TextAlign.center,
                            "New Here? Signup Now",
                            style: TextStyle(
                              color: AppColors.greyPurple,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightSemiBold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28.0),
                        SizedBox(
                          width: double.infinity,
                          height: 64.0,
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled
                                ? () async {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    final mobileNumber = _phoneController.text;
                                    await sendOtp(mobileNumber);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isButtonEnabled
                                  ? AppColors.darkerBlue
                                  : const Color(0xFFD2D1DB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _isButtonEnabled
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
