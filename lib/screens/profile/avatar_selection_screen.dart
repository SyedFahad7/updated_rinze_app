import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  final List<String> _avatarUrls = [
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fdummy.png?alt=media&token=caeb298a-fb51-4858-8252-429aeffeb2b5',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Ffemale.png?alt=media&token=db36acd1-ce6b-4df6-95ef-53b2a9bfd6d6',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Ffemale2.png?alt=media&token=26037189-a455-4a9c-9fca-fdf0953d702b',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Ffemale3.png?alt=media&token=42bfdb2b-30c0-451e-b234-81d47b9e93fe',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Ffemale4.png?alt=media&token=5e5ac00e-7854-4dbb-bc41-7e14a9c87259',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Ffemale5.png?alt=media&token=4f03eb08-fefd-408b-a2b1-b0e91b71161e',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Ffemale6.png?alt=media&token=d182d812-bd89-400d-a49d-3e4139e7b3bf',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fmale.png?alt=media&token=99be24a2-dac0-45f0-98d5-6a40ef7fd3ee',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fmale2.png?alt=media&token=6cbaee4f-665b-459e-a854-8b623e4085d1',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fmale3.png?alt=media&token=1e1e2095-cbcc-4599-9cca-8b274ec9a2d6',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fmale4.png?alt=media&token=d0b19d97-4f7b-43d3-8161-8005c9ca15b7',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fmale5.png?alt=media&token=379da2d1-471b-4476-a39e-8e43b910d195',
    'https://firebasestorage.googleapis.com/v0/b/bitrex-b1b1d.appspot.com/o/avatars%2Fmale6.png?alt=media&token=712307ea-52c4-46fc-a93c-9c84368afbc9',
  ];

  String? _selectedAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: AppColors.lightWhite,
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
                  'Select Profile Picture',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _avatarUrls.length,
                itemBuilder: (context, index) {
                  final avatarUrl = _avatarUrls[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarUrl = avatarUrl;
                      });
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        if (_selectedAvatarUrl == avatarUrl)
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                ElevatedButton(
                  onPressed: _selectedAvatarUrl != null
                      ? () {
                          Navigator.pop(context, _selectedAvatarUrl);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAvatarUrl != null
                        ? AppColors.darkerBlue
                        : Colors.grey,
                    fixedSize: const Size(154, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: AppColors.baseWhite,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize14,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
