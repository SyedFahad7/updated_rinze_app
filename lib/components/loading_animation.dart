import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {
  int _currentGifIndex = 0;

  final List<String> gifPaths = [
    'assets/images/wash.gif',
    'assets/images/clean.gif',
    'assets/images/iron.gif',
    'assets/images/fold.gif',
    'assets/images/pour.gif',
    'assets/images/bubbles.gif',
    'assets/images/cloth.gif',
  ];

  @override
  void initState() {
    super.initState();
    _startGifRotation();
  }

  void _startGifRotation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentGifIndex = (_currentGifIndex + 1) % gifPaths.length;
        });
        _startGifRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.white
                  .withValues(alpha: 0.5), // Replace with your color
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  gifPaths[_currentGifIndex],
                  width: 100.0,
                  height: 100.0,
                ),
                const Text(
                  'Premium Care for Your Every Wear',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.blue, // Replace with your color
                  ),
                ),
                const SizedBox(height: 20),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 250,
                        height: 10,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 150,
                        height: 10,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
