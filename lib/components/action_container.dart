import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class ActionContainer extends StatefulWidget {
  const ActionContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.padding,
  });

  final Widget icon;
  final String title;
  final GestureTapCallback onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<ActionContainer> createState() => _ActionContainerState();
}

class _ActionContainerState extends State<ActionContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.lightWhite,
            border: Border.all(
              color: AppColors.black.withValues(alpha: 0.06),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon,
              const SizedBox(width: 4.0),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.darkBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
