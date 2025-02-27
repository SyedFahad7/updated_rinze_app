import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';

class CalendarBottomSheet extends StatefulWidget {
  const CalendarBottomSheet({super.key});

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final DateTime _currentDate = DateTime.now();

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
        initialPage: _focusedDate.month -
            1 +
            (_focusedDate.year - _currentDate.year) * 12);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: AppColors.fadeRed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1500),
      animation: CurvedAnimation(
        parent: AnimationController(
          duration: const Duration(milliseconds: 1000),
          vsync: Navigator.of(context),
        ),
        curve: Curves.fastOutSlowIn,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset('assets/icons/close.svg'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 36.0),
                            child: Text(
                              'Schedule Pickup',
                              style: TextStyle(
                                color: AppColors.darkestBlue,
                                fontSize: AppFonts.fontSize28,
                                fontWeight: AppFonts.fontWeightSemiBold,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select a preferred date',
                        style: TextStyle(
                          color: AppColors.darkestBlue,
                          fontSize: 16,
                          fontWeight: AppFonts.fontWeightRegular,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon:
                                SvgPicture.asset('assets/icons/arrow_left.svg'),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                          Text(
                            '${_months[_focusedDate.month - 1]} ${_focusedDate.year}',
                            style: const TextStyle(
                              color: AppColors.opaqueGrey,
                              fontSize: 16,
                              fontWeight: AppFonts.fontWeightMedium,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            ),
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                                'assets/icons/arrow_right.svg'),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _focusedDate = DateTime(
                                  _currentDate.year + (index ~/ 12),
                                  (index % 12) + 1);
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildCalendarPage(
                                _currentDate.year + (index ~/ 12),
                                (index % 12) + 1);
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    const Divider(
                      color: AppColors.lightGrey,
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selectedDate.isBefore(DateTime(
                              _currentDate.year,
                              _currentDate.month,
                              _currentDate.day))
                          ? null
                          : () {
                              Navigator.of(context).pop(_selectedDate);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        minimumSize: const Size(312, 48), // Size of the button
                        elevation: 0, // Remove shadow
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: AppFonts.fontWeightSemiBold,
                          color: AppColors.white,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
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
    );
  }

  Widget _buildCalendarPage(int year, int month) {
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int firstDayOfMonthWeekday = firstDayOfMonth.weekday;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    // Adjust the starting index to align with the correct day of the week
    int startOffset = (firstDayOfMonthWeekday - 1) % 7;

    return GridView.builder(
      shrinkWrap: true,
      itemCount: daysInMonth + startOffset + 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.6,
        mainAxisSpacing: 20.0, // Spacing between rows of dates
      ),
      itemBuilder: (context, index) {
        if (index < 7) {
          return Center(
            child: Text(
              ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][index],
              style: const TextStyle(
                color: AppColors.fadeBlue,
                fontSize: AppFonts.fontSize14,
                fontWeight: AppFonts.fontWeightRegular,
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
              ),
            ),
          );
        } else if (index < startOffset + 7) {
          return const SizedBox.shrink();
        } else {
          int day = index - startOffset - 6;
          DateTime date = DateTime(year, month, day);
          bool isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;
          bool isToday = _currentDate.year == date.year &&
              _currentDate.month == date.month &&
              _currentDate.day == date.day;
          bool isPastDate = date.isBefore(DateTime(
              _currentDate.year, _currentDate.month, _currentDate.day));

          return GestureDetector(
            onTap: () {
              if (isPastDate) {
                _showSnackbar(context, "You cannot select past dates.");
              } else {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkerBlue : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.darkBlue)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isPastDate
                        ? AppColors.black.withOpacity(0.3)
                        : isSelected
                            ? Colors.white
                            : AppColors.black.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: AppFonts.fontWeightSemiBold,
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
