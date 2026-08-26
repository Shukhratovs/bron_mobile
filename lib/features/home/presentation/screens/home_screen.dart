import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/bron_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header (Logo & City)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BronLogo(width: 86.w, height: 32.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16.r, color: AppColors.primary),
                        Gap(4.w),
                        Text(
                          AppStrings.cityTashkent,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(24.h),

              // Greeting & Title
              Text(
                AppStrings.popularPlaces,
                style: GoogleFonts.unbounded(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              Gap(8.h),
              Text(
                'Toshkentdagi eng yaxshi joylarni qidiring va bron qiling',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Gap(20.h),

              // Search Bar Trigger
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22.r),
                    Gap(12.w),
                    Expanded(
                      child: Text(
                        AppStrings.searchPlaceholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: AppColors.textSecondaryDark,
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
}
