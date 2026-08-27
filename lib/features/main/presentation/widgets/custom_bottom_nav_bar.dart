import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class BottomNavItem {
  final String svgPath;
  final String activeSvgPath;
  final String label;

  const BottomNavItem({
    required this.svgPath,
    required this.activeSvgPath,
    required this.label,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static List<BottomNavItem> get items => [
        BottomNavItem(
          svgPath: AppAssets.navHome,
          activeSvgPath: AppAssets.navHomeSelected,
          label: AppStrings.navHome,
        ),
        BottomNavItem(
          svgPath: AppAssets.navMap,
          activeSvgPath: AppAssets.navMapSelected,
          label: AppStrings.navMap,
        ),
        BottomNavItem(
          svgPath: AppAssets.navBron,
          activeSvgPath: AppAssets.navBronSelected,
          label: AppStrings.navBookings,
        ),
        BottomNavItem(
          svgPath: AppAssets.navProfile,
          activeSvgPath: AppAssets.navProfileSelected,
          label: AppStrings.navProfile,
        ),
      ];

  static const Color activeTint = AppColors.primary;
  static const Color inactiveTint = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final navItems = items;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(36.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.0.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / navItems.length;
                    final indicatorPadding = 3.w;
                    final indicatorWidth = itemWidth - (indicatorPadding * 2);

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. Liquid Glass Active Capsule (Smooth Sliding Glass Bubble)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * itemWidth + indicatorPadding,
                          top: 2.h,
                          bottom: 2.h,
                          width: indicatorWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeTint.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(
                                color: activeTint.withValues(alpha: 0.3),
                                width: 1.0.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeTint.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Tab Items Row
                        Row(
                          children: List.generate(navItems.length, (index) {
                            final item = navItems[index];
                            final isSelected = index == currentIndex;

                            return Expanded(
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  onTap(index);
                                },
                                borderRadius: BorderRadius.circular(28.r),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedScale(
                                        scale: isSelected ? 1.08 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutCubic,
                                        child: SvgPicture.asset(
                                          isSelected
                                              ? item.activeSvgPath
                                              : item.svgPath,
                                          width: 20.r,
                                          height: 20.r,
                                          fit: BoxFit.contain,
                                          colorFilter: isSelected
                                              ? null
                                              : const ColorFilter.mode(
                                                  inactiveTint,
                                                  BlendMode.srcIn,
                                                ),
                                        ),
                                      ),
                                      Gap(4.h),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? activeTint
                                              : inactiveTint,
                                          letterSpacing: -0.2,
                                        ),
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
