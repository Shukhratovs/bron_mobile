import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/bron_logo.dart';

class HomeHeaderWidget extends StatelessWidget {
  final VoidCallback? onCityTap;
  final VoidCallback? onNotificationTap;

  const HomeHeaderWidget({
    super.key,
    this.onCityTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bron Brand Logo (Dark text for Light mode)
        BronLogo(
          width: 86.w,
          height: 32.h,
          isDarkText: true,
        ),

        Row(
          children: [
            // City Location Selector Pill
            GestureDetector(
              onTap: onCityTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 15.r,
                      color: AppColors.primary,
                    ),
                    Gap(4.w),
                    Text(
                      AppStrings.cityTashkent,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Gap(2.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.r,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            Gap(10.w),

            // Notification Bell Button
            GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.w,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 20.r,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
