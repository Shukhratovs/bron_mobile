import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const HomeSearchBarWidget({
    super.key,
    this.onTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  AppIcon(
                    AppAssets.iconSearch2Line,
                    size: 18.r,
                    color: AppColors.textMuted,
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      'Restoran, taom yoki joy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap(10.w),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: AppIcon(
                AppAssets.iconEqualizer2Line,
                size: 20.r,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
