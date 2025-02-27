import 'package:flutter/material.dart';
import '../constants/app_fonts.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({
    super.key,
    required this.serviceName,
    required this.imagePath,
    required this.onTap,
  });

  final String serviceName;
  final String imagePath;
  final GestureTapCallback onTap;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            widget.imagePath,
            scale: 0.8,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Text(
              widget.serviceName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize14,
                fontWeight: AppFonts.fontWeightMedium,
              ),
              overflow: TextOverflow.visible,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
