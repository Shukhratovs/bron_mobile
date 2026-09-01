import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class TimeSlotChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool large;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.time,
    this.isSelected = false,
    this.large = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 14.w : 10.w,
          vertical: large ? 8.h : 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(large ? 999.r : 9.r),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFEAEAEA),
                  width: 1,
                ),
        ),
        child: Text(
          time,
          style: GoogleFonts.plusJakartaSans(
            fontSize: large ? 14.sp : 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF161616),
          ),
        ),
      ),
    );
  }
}
