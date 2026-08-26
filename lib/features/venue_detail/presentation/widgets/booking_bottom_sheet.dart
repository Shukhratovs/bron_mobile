import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../booking/presentation/screens/deposit_confirmation_screen.dart';
import '../../../home/data/models/venue_model.dart';
import 'queue_bottom_sheet.dart';

class BookingBottomSheet extends StatefulWidget {
  final VenueModel venue;
  final String? initialTime;

  const BookingBottomSheet({
    super.key,
    required this.venue,
    this.initialTime,
  });

  static Future<void> show(
    BuildContext context, {
    required VenueModel venue,
    String? initialTime,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        venue: venue,
        initialTime: initialTime,
      ),
    );
  }

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final List<String> _zones = const [
    'Farqi yo\'q',
    'Asosiy zal',
    'Deraza yonida',
    'Terrasa',
    'VIP xona',
  ];

  final List<Map<String, String>> _days = const [
    {'day': 'Bugun', 'date': '27'},
    {'day': 'Ert', 'date': '28'},
    {'day': 'Sesh', 'date': '29'},
    {'day': 'Chor', 'date': '30'},
    {'day': 'Pay', 'date': '31'},
  ];

  final List<String> _timeSlots = const [
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
  ];

  late String _selectedZone;
  late int _guestCount;
  late String _selectedDate;
  late String _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedZone = _zones.first;
    _guestCount = 4;
    _selectedDate = '27';
    _selectedTime = widget.initialTime ?? '19:00';
  }

  void _proceedToDeposit() {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepositConfirmationScreen(
          venue: widget.venue,
          date: '27-iyul, yakshanba',
          time: _selectedTime,
          guestCount: _guestCount,
          tableZone: '12 - $_selectedZone',
        ),
      ),
    );
  }

  void _openQueueModal() {
    Navigator.pop(context);
    QueueBottomSheet.show(context, venue: widget.venue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),

              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vaqt tanlang',
                    style: GoogleFonts.unbounded(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Gap(16.h),

              // 1. Joy / Zal tanlash
              Text(
                'QAYSI JOYDA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Gap(8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _zones.map((zone) {
                    final isSelected = zone == _selectedZone;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedZone = zone),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            zone,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Gap(18.h),

              // 2. Mehmonlar soni
              Text(
                'MEHMONLAR SONI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Gap(8.h),
              Row(
                children: List.generate(6, (index) {
                  final count = index + 1;
                  final isSelected = count == _guestCount;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _guestCount = count),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            count == 6 ? '6+' : '$count',
                            style: GoogleFonts.unbounded(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Gap(18.h),

              // 3. Qaysi kun
              Text(
                'QAYSI KUN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Gap(8.h),
              Row(
                children: _days.map((d) {
                  final isSelected = d['date'] == _selectedDate;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = d['date']!),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              d['day']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Gap(2.h),
                            Text(
                              d['date']!,
                              style: GoogleFonts.unbounded(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Gap(18.h),

              // 4. Bo'sh vaqtlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BO\'SH VAQTLAR',
                    style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
                  ),
                  GestureDetector(
                    onTap: _openQueueModal,
                    child: Text(
                      'Navbatga yozilish',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _timeSlots.map((time) {
                  final isSelected = time == _selectedTime;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTime = time),
                    child: Container(
                      width: 78.w,
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Gap(14.h),

              Center(
                child: Text(
                  'Bu vaqtda depozit kartada bloklanadi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Gap(16.h),

              // Action Button
              AppButton.primary(
                text: 'Bugun $_selectedTime • $_guestCount kishi - davom etish',
                onPressed: _proceedToDeposit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
