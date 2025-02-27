import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rinze/components/calender_bottom_sheet.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';

class SchedulePickupBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final String? initialSlot;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String?> onSlotSelected;

  const SchedulePickupBottomSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.onSlotSelected,
    this.initialSlot,
  });

  @override
  State<SchedulePickupBottomSheet> createState() =>
      _SchedulePickupBottomSheetState();
}

class _SchedulePickupBottomSheetState extends State<SchedulePickupBottomSheet> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedSlot = widget.initialSlot;
    _currentTime = DateTime.now();
  }

  void _openDatePicker() async {
    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(
        maxHeight: 700.0,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
      ),
      builder: (BuildContext context) {
        return const CalendarBottomSheet();
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedSlot = null; // Reset the selected slot when date changes
      });
    }
  }

  bool _isSlotAvailable(String slot) {
    if (_selectedDate.isAfter(DateTime.now())) {
      return true;
    }

    final slotTime = _parseTime(slot);
    final currentTimePlus40 = _currentTime.add(const Duration(minutes: 40));

    return slotTime.isAfter(currentTimePlus40);
  }

  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    final hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final isPM = timeParts[1] == 'PM';

    return DateTime(
      now.year,
      now.month,
      now.day,
      isPM ? hour + 12 : hour,
      minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
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
                  const Text(
                    'Schedule Pickup',
                    style: TextStyle(
                      color: AppColors.darkestBlue,
                      fontSize: AppFonts.fontSize28,
                      fontWeight: AppFonts.fontWeightSemiBold,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Text(
                'Select a timeslot',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize16,
                  fontWeight: AppFonts.fontWeightRegular,
                ),
              ),
              const SizedBox(height: 22),
              _buildTimeSlotSection(
                iconPath: 'assets/icons/morning.svg',
                title: 'Morning',
                slots: ['9:30 AM', '11:00 AM'],
              ),
              const SizedBox(height: 16),
              _buildTimeSlotSection(
                iconPath: 'assets/icons/afternoon.svg',
                title: 'Afternoon',
                slots: ['1:30 PM', '3:00 PM'],
              ),
              const SizedBox(height: 16),
              _buildTimeSlotSection(
                iconPath: 'assets/icons/evening.svg',
                title: 'Evening',
                slots: ['4:30 PM', '6:00 PM'],
              ),
              const SizedBox(height: 16),
              Container(
                width: 312,
                height: 75,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.timeGrey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected date',
                          style: TextStyle(
                            color: AppColors.iconGrey,
                            fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                            fontSize: AppFonts.fontSize12,
                            fontWeight: AppFonts.fontWeightRegular,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset('assets/icons/calendar_light.svg'),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                color: AppColors.darkBlack,
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize14,
                                fontWeight: AppFonts.fontWeightMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _openDatePicker,
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.lightBlue,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_selectedDate);
                  widget.onSlotSelected(_selectedSlot);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  minimumSize: const Size(312, 48),
                ),
                child: const Text(
                  'Confirm Pickup',
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
      ),
    );
  }

  Widget _buildTimeSlotSection({
    required String iconPath,
    required String title,
    required List<String> slots,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: AppFonts.fontWeightSemiBold,
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize16,
                color: AppColors.opaqueGrey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${slots.length} slots',
              style: const TextStyle(
                color: AppColors.fadeBlue,
                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                fontSize: AppFonts.fontSize12,
                fontWeight: AppFonts.fontWeightRegular,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isAvailable = _isSlotAvailable(slot);
            final isSelected = slot == _selectedSlot;
            return GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    }
                  : null,
              child: Container(
                width: 96,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.skillWhite : AppColors.white,
                  border: Border.all(
                    color: isAvailable
                        ? (isSelected
                            ? AppColors.lightBlue
                            : AppColors.hintGrey)
                        : AppColors.hintGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  isAvailable ? slot : 'Unavailable',
                  style: TextStyle(
                    color: isAvailable
                        ? (isSelected
                            ? AppColors.darkerBlue
                            : AppColors.hintBlack)
                        : AppColors.hintBlack.withOpacity(0.5),
                    fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)}';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
