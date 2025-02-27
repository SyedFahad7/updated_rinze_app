import 'package:flutter/material.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rinze/constants/app_fonts.dart';

import '../constants/app_colors.dart';

class ReviewFeedback extends StatefulWidget {
  const ReviewFeedback({super.key});

  @override
  State<ReviewFeedback> createState() => _ReviewFeedbackState();
}

class _ReviewFeedbackState extends State<ReviewFeedback> {
  double _rating = 0.0; // To store the star rating
  final TextEditingController _feedbackController =
      TextEditingController(); // To store the feedback text

  @override
  void dispose() {
    _feedbackController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.8, // Limit height to 80% of screen
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Dialog Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rate your experience text
                        const Center(
                          child: Text(
                            'Rate your experience',
                            style: TextStyle(
                              fontSize: AppFonts.fontSize16,
                              fontWeight: AppFonts.fontWeightMedium,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Star rating
                        Center(
                          child: AnimatedRatingStars(
                            initialRating: _rating,
                            minRating: 3.0,
                            maxRating: 5.0,
                            filledColor: AppColors.amber,
                            emptyColor: AppColors.lightGray,
                            filledIcon: Icons.star,
                            halfFilledIcon: Icons.star_half,
                            emptyIcon: Icons.star_border,
                            onChanged: (double rating) {
                              setState(() {
                                _rating = rating; // Update the rating
                              });
                            },
                            displayRatingValue: true,
                            interactiveTooltips: true,
                            starSize: 45.0,
                            animationDuration:
                                const Duration(milliseconds: 100),
                            animationCurve: Curves.easeInOut,
                            readOnly: false,
                            customFilledIcon: Icons.star,
                            customHalfFilledIcon: Icons.star_half,
                            customEmptyIcon: Icons.star_border,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Additional Feedback text
                        const Text(
                          'Additional Feedback',
                          style: TextStyle(
                            fontSize: AppFonts.fontSize14,
                            fontWeight: AppFonts.fontWeightMedium,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Feedback text box
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _feedbackController,
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: 'Type your feedback here..',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Skip and Submit buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Skip button
                            SizedBox(
                              width: 124,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.whiteGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: AppColors.darkBlue,
                                    fontSize: AppFonts.fontSize14,
                                    fontWeight: AppFonts.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ),
                            // Submit button
                            SizedBox(
                              width: 124,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  final feedback = {
                                    'rating': _rating,
                                    'feedback': _feedbackController.text,
                                  };
                                  print('Feedback: $feedback'); // For debugging
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: AppFonts.fontSize14,
                                    fontWeight: AppFonts.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Close icon
                  Positioned(
                    top: -50,
                    right: -10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/close.svg',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
