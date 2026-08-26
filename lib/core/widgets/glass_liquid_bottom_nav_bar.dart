import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item model for [GlassLiquidBottomNavBar].
class GlassNavItem {
  final String label;
  final String? svgPath;
  final String? activeSvgPath;
  final IconData? icon;
  final IconData? activeIcon;

  const GlassNavItem({
    required this.label,
    this.svgPath,
    this.activeSvgPath,
    this.icon,
    this.activeIcon,
  }) : assert(
  svgPath != null || icon != null,
  'Either svgPath or icon must be provided for GlassNavItem.',
  );
}

/// Real iOS/macOS Liquid Glass Floating Bottom Navigation Bar.
class GlassLiquidBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;
  final Color activeTint;
  final Color inactiveColor;
  final double blurSigma;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool enableHaptics;

  const GlassLiquidBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeTint = const Color(0xFFFF3B30), // iOS Vibrant Red
    this.inactiveColor = const Color(0x99FFFFFF), // Semi-transparent white
    this.blurSigma = 25.0,
    this.borderRadius,
    this.margin,
    this.padding,
    this.enableHaptics = true,
  });

  @override
  State<GlassLiquidBottomNavBar> createState() => _GlassLiquidBottomNavBarState();
}

class _GlassLiquidBottomNavBarState extends State<GlassLiquidBottomNavBar> {
  void _handleTap(int index) {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    widget.onTap(index);
  }

  Widget _buildIcon(GlassNavItem item, bool isSelected) {
    final color = isSelected ? Colors.white : widget.inactiveColor;

    if (item.svgPath != null) {
      final svgAsset =
      (isSelected && item.activeSvgPath != null) ? item.activeSvgPath! : item.svgPath!;
      return SvgPicture.asset(
        svgAsset,
        width: 20.r,
        height: 20.r,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          color,
          BlendMode.srcIn,
        ),
      );
    }

    final iconData = (isSelected && item.activeIcon != null)
        ? item.activeIcon!
        : (item.icon ?? Icons.circle);

    return Icon(
      iconData,
      size: 22.r,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? 36.r;
    final effectiveMargin = widget.margin ?? EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h);
    final effectivePadding = widget.padding ?? EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h);

    return Padding(
      padding: effectiveMargin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              // Liquid Glass — Shaffoflik (Opacity) juda past va Ultra Glossy Gradient bo'lishi shart!
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              // Shisha chetidagi ingichka yaltiroq chegara
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: -2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: effectivePadding,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemCount = widget.items.length;
                    final itemWidth = constraints.maxWidth / itemCount;
                    final indicatorPadding = 3.w;
                    final indicatorWidth = itemWidth - (indicatorPadding * 2);

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. Liquid Active Glass Capsule Indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: widget.currentIndex * itemWidth + indicatorPadding,
                          top: 2.h,
                          bottom: 2.h,
                          width: indicatorWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              // Active tab uchun shishasimon qizil gloss va gradient
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.activeTint.withValues(alpha: 0.85),
                                  widget.activeTint.withValues(alpha: 0.45),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                effectiveBorderRadius - 8.r,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.0.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.activeTint.withValues(alpha: 0.45),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Tab Items Row
                        Row(
                          children: List.generate(itemCount, (index) {
                            final item = widget.items[index];
                            final isSelected = index == widget.currentIndex;

                            return Expanded(
                              child: InkWell(
                                onTap: () => _handleTap(index),
                                borderRadius: BorderRadius.circular(
                                  effectiveBorderRadius - 6.r,
                                ),
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
                                        child: _buildIcon(item, isSelected),
                                      ),
                                      Gap(4.h),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : widget.inactiveColor,
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