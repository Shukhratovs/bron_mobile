import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/bron_logo.dart';

class HomeHeaderWidget extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const HomeHeaderWidget({
    super.key,
    this.onNotificationTap,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28.r),
        ),
      ),
      child: Column(
        children: [
          HomeHeaderLogoRow(onNotificationTap: onNotificationTap),
          Gap(24.h),
          HomeHeaderSearchRow(
            onSearchTap: onSearchTap,
            onFilterTap: onFilterTap,
          ),
        ],
      ),
    );
  }
}

/// Logo + notification icon row (always pinned in sticky header).
class HomeHeaderLogoRow extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const HomeHeaderLogoRow({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BronLogo(
          width: 64.w,
          height: 24.h,
          isDarkText: true,
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: AppIcon(
            AppAssets.iconNotification3Line,
            size: 24.r,
            color: const Color(0xFF5C5C5C),
          ),
        ),
      ],
    );
  }
}

/// Search bar + filter button row.
class HomeHeaderSearchRow extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const HomeHeaderSearchRow({super.key, this.onSearchTap, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  AppIcon(
                    AppAssets.iconSearch2Line,
                    size: 20.r,
                    color: const Color(0xFFA3A3A3),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      AppStrings.searchPlaceholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        color: const Color(0xFFA3A3A3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap(8.w),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppIcon(
                  AppAssets.iconEqualizer2Line,
                  size: 22.r,
                  color: const Color(0xFF161616),
                ),
                // Active filter dot
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    width: 12.r,
                    height: 12.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
