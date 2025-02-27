import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';

class FreeDeliveryModal extends StatelessWidget {
  const FreeDeliveryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow[100]!, Colors.yellow[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Get free delivery',
                  style: TextStyle(
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    fontSize: AppFonts.fontSize24,
                    fontWeight: AppFonts.fontWeightSemiBold,
                    color: Colors.brown[700],
                  ),
                ),
                const SizedBox(height: 4),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'on all Scheduled Pickups 🥳',
                      style: TextStyle(
                        fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        fontSize: AppFonts.fontSize14,
                        fontWeight: AppFonts.fontWeightMedium,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Image.asset(
                    'assets/images/vector.png',
                    height: 170,
                    width: 170,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.yellowGreenGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 08),
                        child: Text(
                          'Got it, thanks!',
                          style: TextStyle(
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightMedium,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Positioned(
              left: 20,
              top: 50,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 30),
            ),
            Positioned(
              left: 20,
              top: 90,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 18),
            ),
            Positioned(
              left: 50,
              top: 76,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 22),
            ),
            Positioned(
              right: 20,
              top: 100,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 30),
            ),
            Positioned(
              right: 40,
              top: 125,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 22),
            ),
            Positioned(
              right: 10,
              top: 135,
              child: Icon(Icons.star, color: Colors.yellow[700], size: 30),
            ),
            Positioned(
              left: 20,
              bottom: 50,
              child:
                  Icon(Icons.celebration, color: Colors.purple[300], size: 30),
            ),
            Positioned(
              right: 50,
              bottom: 100,
              child:
                  Icon(Icons.celebration, color: Colors.purple[300], size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
