import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class TimeSlotChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.time,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
            width: 0.8.w,
          ),
        ),
        child: Text(
          time,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
