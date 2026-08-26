import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

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
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20.r,
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      AppStrings.searchPlaceholder,
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
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.w,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.tune_rounded,
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
