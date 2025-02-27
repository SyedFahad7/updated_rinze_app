import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../home_navigation_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.fullName,
    required this.screen,
  });

  final String fullName;
  final String phoneNumber;
  final String email;
  final String screen;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isButtonEnabled = false;
  int _timerSeconds = 30;
  Timer? _timer;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String getOtpText() {
    String otp = '';
    for (var controller in _otpControllers) {
      otp += controller.text; // Concatenate the text from each controller
    }
    return otp; // Return the complete OTP
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() => _updateButtonState());
    }

    // Add this listener to handle pasting the OTP
    _otpControllers[0].addListener(() async {
      if (_otpControllers[0].text.length > 1) {
        String pastedText = _otpControllers[0].text;
        _otpControllers[0].clear();
        _pasteOtp(pastedText);
      }
    });
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _timerSeconds = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateButtonState() {
    final isFilled =
        _otpControllers.every((controller) => controller.text.length == 1);
    setState(() {
      _isButtonEnabled = isFilled;
    });
    print('_otpControllers');
    num textLength = 0;
    // print(textLength);
    for (var controller in _otpControllers) {
      if (controller.text.length == 1) {
        textLength++;
      }
    }
    // Dismiss the keyboard only when exactly 10 digits are entered
    if (textLength == 6) {
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
    final url = '${dotenv.env['API_URL']}/auth/otp/mobile/send';
    // Show loading dialog

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobileNumber': mobileNumber,
        }),
      );

      if (response.statusCode == 200) {
      } else {
        // Handle error response
        if (kDebugMode) {
          print('Failed to send OTP: ${response.body}');
        }
      }
    } catch (e) {
      // Handle network or any other errors
      if (kDebugMode) {
        print('Error occurred while sending OTP: $e');
      }
    }

    Navigator.of(context).pop();
  }

  Future<void> verifyOtp(String mobileNumber, String otp) async {
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
      if (widget.screen == 'signup') {
        final response = await http.post(
          Uri.parse('${dotenv.env['API_URL']}/auth/otp/mobile/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mobileNumber': mobileNumber,
            'otp': otp,
          }),
        );
        if (response.statusCode == 200) {
          // OTP verification successful
          Navigator.of(context).pop();
          final userCreateResponse = await http.post(
            Uri.parse('${dotenv.env['API_URL']}/user/register/customer'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "fullName": widget.fullName,
              "mobileNumber": mobileNumber,
              "email": widget.email,
            }),
          );

          if (userCreateResponse.statusCode == 200 ||
              userCreateResponse.statusCode == 201 ||
              userCreateResponse.statusCode == 203 ||
              userCreateResponse.statusCode == 204) {
            final responseBody = jsonDecode(userCreateResponse.body);
            final token = responseBody['token'];

            await secureStorage.write(key: 'Rin8k1H2mZ', value: token);

            // Navigate to the home screen after signup
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeBottomNavigation(
                  selectedIndex: 0,
                ),
              ),
            );
          } else {
            // Handle user creation failure
            print(
                '${userCreateResponse.statusCode} + ${userCreateResponse.body}');
            print('${response.statusCode} + ${response.body}');
            _showSnackbar('Failed to create user. Please try again!');
          }
        } else {
          // Handle incorrect OTP or other error responses
          _showSnackbar('Invalid OTP. Please try again.');
        }
      } else {
        final response = await http.post(
          Uri.parse('${dotenv.env['API_URL']}/auth/otp/mobile/verify/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mobileNumber': mobileNumber,
            'otp': otp,
          }),
        );
        Navigator.of(context).pop();
        if (response.statusCode == 200) {
          // OTP verification successful

          final responseBody = jsonDecode(response.body);
          final token = responseBody['token'];

          await secureStorage.write(key: 'Rin8k1H2mZ', value: token);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeBottomNavigation(
                selectedIndex: 0,
              ),
            ),
          );
        } else {
          // Handle incorrect OTP or other error responses
          _showSnackbar('Invalid OTP. Please try again.');
        }
      }
    } catch (e) {
      // Handle network or any other errors
      _showSnackbar('An error occurred. Please try again.');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightRed,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _pasteOtp(String otp) {
    for (int i = 0; i < otp.length && i < _otpControllers.length; i++) {
      _otpControllers[i].text = otp[i];
    }
    _updateButtonState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              height: 297.0,
              decoration: const BoxDecoration(
                gradient: AppColors.customBlueGradient,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      color: AppColors.hintWhite,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize26,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Enter the OTP we\'ve sent you on your phone number',
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
                          'OTP',
                          style: TextStyle(
                            color: AppColors.hintBlack,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize16,
                            fontWeight: AppFonts.fontWeightMedium,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 40.0,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                cursorColor:
                                    AppColors.hintBlack.withValues(alpha: 0.6),
                                decoration: InputDecoration(
                                  counterText: "",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: AppColors.black
                                          .withValues(alpha: 0.06),
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: AppColors.black
                                          .withValues(alpha: 0.06),
                                      width: 1.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 25.0),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.length == 1 &&
                                      index < _otpControllers.length - 1) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16.0),
                        if (_timerSeconds == 0)
                          Center(
                            child: TextButton(
                              onPressed: () async {
                                _startTimer();
                                final mobileNumber = widget.phoneNumber;
                                await sendOtp(mobileNumber);
                              },
                              child: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize14,
                                  fontWeight: AppFonts.fontWeightMedium,
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              'Resend OTP in: $_timerSeconds',
                              style: const TextStyle(
                                color: Color(0xFF6A707D),
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 64.0,
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled
                                ? () async {
                                    final otp = getOtpText();
                                    await verifyOtp(widget.phoneNumber, otp);
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
                            child: const Text(
                              'Verify',
                              style: TextStyle(
                                color: AppColors.white,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize18,
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
