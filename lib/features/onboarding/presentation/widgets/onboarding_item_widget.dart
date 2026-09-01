import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/onboarding_entity.dart';

class OnboardingItemWidget extends StatelessWidget {
  final OnboardingEntity item;
  final bool isLastPage;

  const OnboardingItemWidget({
    super.key,
    required this.item,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Asosiy Telefon Maketi Rasmi (Oldinda, aniq va katta o'lchamda)
        Positioned(
          top: 69.h,
          left: 0.w,
          right: 0.w,
          child: Image.asset(
            item.imagePath,
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Center(
            child: Icon(
                  Icons.phone_iphone_rounded,
                  size: 120.r,
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                ),
              );
            },
          ),
        ),

        // 2. Pastki yumshoq qora gradient (matn ostini to'q fonga silliq o'tkazish)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 400.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.12, 0.54, 0.6],
                colors: [
                  Colors.transparent,
                  AppColors.backgroundDark.withValues(alpha: 0.35),
                  AppColors.backgroundDark.withValues(alpha: 0.95),
                  AppColors.backgroundDark,
                ],
              ),
            ),
          ),
        ),

        // 3. Matnlar qismi (Figma: Unbounded SemiBold 25px, 33px line-height, -2% letter spacing)
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: isLastPage ? 31.h : 80.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: GoogleFonts.unbounded(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w600,
                  height: 33 / 25,
                  letterSpacing: -0.02 * 25.sp,
                  color: AppColors.textWhite,
                ),
              ),
              Gap(12.h),
              Text(
                item.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
