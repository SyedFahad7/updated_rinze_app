import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class EmailVerifyBottomSheet extends StatefulWidget {
  final String email;
  final VoidCallback onEmailVerified;

  const EmailVerifyBottomSheet({
    super.key,
    required this.email,
    required this.onEmailVerified,
  });

  @override
  State<EmailVerifyBottomSheet> createState() => _EmailVerifyBottomSheetState();
}

class _EmailVerifyBottomSheetState extends State<EmailVerifyBottomSheet> {
  int _timer = 60;
  bool _isResendEnabled = false;
  bool _isLoading = false;
  bool _isOtpComplete = false;
  Timer? _countdownTimer;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timer = 60;
      _isResendEnabled = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOTP() async {
    if (_isResendEnabled) {
      setState(() {
        _isLoading = true;
      });

      final url =
          Uri.parse('${dotenv.env['API_URL']}/auth/otp/email/send/general');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _showDialog('An Email OTP has been sent to you');
        _startTimer();
      } else {
        _showDialog('Failed to resend OTP: ${response.statusCode}');
      }
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showDialog('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${dotenv.env['API_URL']}/auth/otp/email/verify');
    final requestBody = jsonEncode({'email': widget.email, 'otp': otp});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['ok'] == true) {
        _showSuccessDialog('Email verified successfully');
      } else {
        _showDialog('Failed to verify email: ${responseBody['msg']}');
      }
    } else {
      _showDialog('Failed to verify email: ${response.statusCode}');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                widget.onEmailVerified();
                Navigator.of(context).pop(); // Close the modal bottom sheet
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _checkOtpComplete() {
    setState(() {
      _isOtpComplete =
          _otpControllers.every((controller) => controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset('assets/icons/close.svg'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 48), // Placeholder to balance the row
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        color: AppColors.hintBlack,
                        fontSize: 20,
                        fontWeight: AppFonts.fontWeightSemiBold,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      ),
                    ),
                    Text(
                      '$_timer:00',
                      style: const TextStyle(
                        color: AppColors.iconGrey,
                        fontSize: 14,
                        fontWeight: AppFonts.fontWeightBold,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please enter the 6 digit code sent to your email',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: AppFonts.fontWeightMedium,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 43,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkBlue),
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          _checkOtpComplete();
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Didn’t get code?',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                      fontWeight: AppFonts.fontWeightMedium,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _resendOTP,
                  child: Center(
                    child: Text(
                      'Click to resend',
                      style: TextStyle(
                        color: _isResendEnabled
                            ? AppColors.lightBlue
                            : AppColors.black.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: AppFonts.fontWeightMedium,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _isOtpComplete ? _verifyOTP : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOtpComplete
                              ? AppColors.darkBlue
                              : AppColors.lightGrey,
                          fixedSize: const Size(175, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Verify & Proceed',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightSemiBold,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
