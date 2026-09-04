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

/// Real Liquid Glass Floating Bottom Navigation Bar with Swipe & Drag gestures.
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
    this.activeTint = const Color(0xFFDC3009),
    this.inactiveColor = const Color(0xFF6B7280),
    this.blurSigma = 30.0,
    this.borderRadius,
    this.margin,
    this.padding,
    this.enableHaptics = true,
  });

  @override
  State<GlassLiquidBottomNavBar> createState() => _GlassLiquidBottomNavBarState();
}

class _GlassLiquidBottomNavBarState extends State<GlassLiquidBottomNavBar> {
  bool _isDragging = false;
  double _dragOffset = 0.0;
  int _lastHapticIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastHapticIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant GlassLiquidBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.currentIndex != widget.currentIndex) {
      _lastHapticIndex = widget.currentIndex;
    }
  }

  void _handleTap(int index) {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    widget.onTap(index);
  }

  void _onPanStart(DragStartDetails details, double totalWidth, double itemWidth) {
    setState(() {
      _isDragging = true;
      _dragOffset = details.localPosition.dx;
    });
  }

  void _onPanUpdate(DragUpdateDetails details, double totalWidth, double itemWidth) {
    setState(() {
      _dragOffset = details.localPosition.dx.clamp(0.0, totalWidth);
      final hoveredIndex = (_dragOffset / itemWidth).floor().clamp(0, widget.items.length - 1);
      if (hoveredIndex != _lastHapticIndex) {
        if (widget.enableHaptics) {
          HapticFeedback.selectionClick();
        }
        _lastHapticIndex = hoveredIndex;
      }
    });
  }

  void _onPanEnd(DragEndDetails details, double totalWidth, double itemWidth) {
    final targetIndex = (_dragOffset / itemWidth).floor().clamp(0, widget.items.length - 1);
    setState(() {
      _isDragging = false;
    });
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
    widget.onTap(targetIndex);
  }

  void _onPanCancel() {
    setState(() {
      _isDragging = false;
    });
  }

  Widget _buildIcon(GlassNavItem item, bool isSelected) {
    final color = isSelected ? widget.activeTint : widget.inactiveColor;

    if (item.svgPath != null) {
      final svgAsset =
          (isSelected && item.activeSvgPath != null) ? item.activeSvgPath! : item.svgPath!;
      return SvgPicture.asset(
        svgAsset,
        width: 20.r,
        height: 20.r,
        fit: BoxFit.contain,
        colorFilter: isSelected
            ? null
            : ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
      );
    }

    final iconData =
        (isSelected && item.activeIcon != null) ? item.activeIcon! : (item.icon ?? Icons.circle);

    return Icon(
      iconData,
      size: 20.r,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.borderRadius ?? 40.r;
    // Ba'zi Android qurilmalarida tizim navigatsiya paneli (3 tugmali yoki
    // gesture bar) qattiq `24.h`dan balandroq bo'ladi va bu suzuvchi panelni
    // o'ziga bosib qo'yadi — shuning uchun haqiqiy tizim inseti qo'shiladi,
    // panel har doim navigatsiyadan butunlay yuqorida turadi. Faqat
    // `widget.margin` berilmagan holatda ishlaydi — ataylab berilgan margin
    // ustidan yozilmaydi.
    final systemNavInset = MediaQuery.of(context).padding.bottom;
    final effectiveMargin =
        widget.margin ?? EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h + systemNavInset);

    return Padding(
      padding: effectiveMargin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                // Haqiqiy billur Liquid Glass shaffof gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final itemWidth = totalWidth / widget.items.length;
                  final indicatorPadding = 3.w;
                  final indicatorWidth = itemWidth - (indicatorPadding * 2);

                  final double pillLeft;
                  final int activeDisplayIndex;

                  if (_isDragging) {
                    pillLeft = (_dragOffset - (indicatorWidth / 2))
                        .clamp(indicatorPadding, totalWidth - indicatorWidth - indicatorPadding);
                    activeDisplayIndex =
                        (_dragOffset / itemWidth).floor().clamp(0, widget.items.length - 1);
                  } else {
                    pillLeft = widget.currentIndex * itemWidth + indicatorPadding;
                    activeDisplayIndex = widget.currentIndex;
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (d) => _onPanStart(d, totalWidth, itemWidth),
                    onHorizontalDragUpdate: (d) => _onPanUpdate(d, totalWidth, itemWidth),
                    onHorizontalDragEnd: (d) => _onPanEnd(d, totalWidth, itemWidth),
                    onHorizontalDragCancel: _onPanCancel,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. Draggable/Swipeable Liquid Glass Pill
                        AnimatedPositioned(
                          duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: pillLeft,
                          top: 2.h,
                          bottom: 2.h,
                          width: indicatorWidth,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.activeTint.withValues(alpha: 0.16),
                                    widget.activeTint.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.activeTint.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. Tab Items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(widget.items.length, (index) {
                            final item = widget.items[index];
                            final isSelected = index == activeDisplayIndex;

                            return Expanded(
                              child: InkWell(
                                onTap: () => _handleTap(index),
                                borderRadius: BorderRadius.circular(30.r),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 6.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildIcon(item, isSelected),
                                      Gap(2.h),
                                      Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5.sp,
                                          fontWeight:
                                              isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected
                                              ? widget.activeTint
                                              : widget.inactiveColor,
                                          letterSpacing: -0.2,
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
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}