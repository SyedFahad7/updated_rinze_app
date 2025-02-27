import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rinze/components/email_verify_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:rinze/main.dart';
import 'package:rinze/providers/customer_provider.dart';
import 'dart:convert';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';
import 'avatar_selection_screen.dart';
import 'user_profile_screen.dart'; // Import the UserProfileScreen

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final double iconTextSpacing = 12.0;
  final double buttonSpacing = 50.0;
  String? _selectedAvatarUrl;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  Color _verifyEmailColor = AppColors.black;
  bool _isEmailVerified = false;
  bool _isLoading = false;

  void _showVerifyEmailModal() {
    if (_verifyEmailColor == AppColors.lightRed) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return EmailVerifyBottomSheet(
            email: _emailController.text,
            onEmailVerified: () {
              setState(() {
                _isEmailVerified = true;
              });
            },
          );
        },
      );
    }
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date); // Parse the ISO date string
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return date; // Return the original string if parsing fails
    }
  }

  @override
  void initState() {
    super.initState();
    final globalState =
        Provider.of<CustomerGlobalState>(context, listen: false);
    // Access customerProvider.userData if needed
    final userData = globalState.userData;

    final profileImageUrl =
        userData['profileImg'] ?? 'https://placehold.co/100x100';
    final fullName = userData['fullName'] ?? 'N/A';
    final email = userData['email'] ?? 'N/A';
    final phoneNumber = userData['mobileNumber'] ?? 'N/A';
    // final customerId = userData['profile']['profileRef']['customerId'] ?? 'N/A';
    print(userData['dob']);
    setState(() {
      _emailController.text = email;
      _nameController.text = fullName;
      _dobController.text =
          userData['dob'] != null ? _formatDate(userData['dob']) : '';
      _selectedAvatarUrl = profileImageUrl;
      _selectedGender = userData['gender'] ?? '';
    });
    // Add listener to the _emailController
    _emailController.addListener(() {
      setState(() {
        _verifyEmailColor = _emailController.text.contains('@')
            ? AppColors.lightRed
            : AppColors.black;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _navigateToAvatarSelection() async {
    final selectedAvatarUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AvatarSelectionScreen(),
      ),
    );

    if (selectedAvatarUrl != null) {
      setState(() {
        _selectedAvatarUrl = selectedAvatarUrl;
      });
    }
  }

  Future<void> _sendOtpToEmail() async {
    final email = _emailController.text;
    if (email.isEmpty || !_emailController.text.contains('@')) {
      debugPrint('Invalid email address');
      return;
    }

    final url =
        Uri.parse('${dotenv.env['API_URL']}/auth/otp/email/send/general');
    debugPrint('Sending OTP to $email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      debugPrint('OTP sent successfully to $email');
    } else {
      debugPrint('Failed to send OTP: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');
    if (storedToken == null) {
      debugPrint('No stored token found');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    Map<String, dynamic> requestBody = {};

    if (_nameController.text.isNotEmpty) {
      requestBody['fullName'] = _nameController.text;
    }
    if (_dobController.text.isNotEmpty) {
      requestBody['dob'] = _dobController.text;
    }
    if (_selectedGender != null) {
      requestBody['gender'] = _selectedGender;
    }
    if (_emailController.text.isNotEmpty) {
      requestBody['email'] = _emailController.text;
      requestBody['emailVerified'] = _isEmailVerified;
    }
    if (_selectedAvatarUrl != null) {
      requestBody['profileImg'] = _selectedAvatarUrl;
    }

    if (requestBody.isEmpty) {
      debugPrint('No changes to save');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes made to save!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('${dotenv.env['API_URL']}/user/currentUser');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $storedToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      debugPrint('Profile updated successfully');
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/currentUser'),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final profileDetails = decodedResponse['user'];
        // Store the user data in the provider
        if (mounted) {
          final customerProvider =
              Provider.of<CustomerGlobalState>(context, listen: false);
          customerProvider.setUserData(profileDetails);
        }
      }
      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UserProfileScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updated your details successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      debugPrint('Failed to update profile: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: AppColors.lightWhite,
          surfaceTintColor: AppColors.lightWhite,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 28.0, right: 28.0),
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
                  'Edit Profile',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedAvatarUrl != null
                          ? NetworkImage(_selectedAvatarUrl!)
                          : const AssetImage('assets/images/dummy.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _navigateToAvatarSelection,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/pencil.svg',
                                colorFilter: const ColorFilter.mode(
                                  AppColors.darkBlue,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: iconTextSpacing),
                              const Text(
                                'Change Picture',
                                style: TextStyle(
                                  color: AppColors.darkBlue,
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize16,
                                  fontWeight: AppFonts.fontWeightMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize16,
                    fontWeight: AppFonts.fontWeightRegular,
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize16,
                    fontWeight: AppFonts.fontWeightRegular,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    debugPrint('Verify Email tapped');
                    _showVerifyEmailModal();
                    _sendOtpToEmail();
                  },
                  child: _isEmailVerified
                      ? const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Email Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightRegular,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Verify Email',
                          style: TextStyle(
                            color: _verifyEmailColor,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightRegular,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Date of Birth',
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dobController.text.isNotEmpty
                          ? DateTime.tryParse(_dobController.text) ??
                              DateTime.now()
                          : DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.lightWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            'assets/icons/calendar_check.svg',
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: AppColors.black,
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize16,
                        fontWeight: AppFonts.fontWeightRegular,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gender',
                    style: TextStyle(
                      color: AppColors.darkBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightRegular,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['Male', 'Female', 'Others']
                      .map((label) => DropdownMenuItem(
                            value: label.toLowerCase(),
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/icons/genders.svg',
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize16,
                    fontWeight: AppFonts.fontWeightRegular,
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                      SizedBox(width: buttonSpacing),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkerBlue,
                          fixedSize: const Size(154, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.baseWhite),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: AppColors.baseWhite,
                                  fontFamily:
                                      AppFonts.fontFamilyPlusJakartaSans,
                                  fontSize: AppFonts.fontSize14,
                                  fontWeight: AppFonts.fontWeightSemiBold,
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
      ),
    );
  }
}
