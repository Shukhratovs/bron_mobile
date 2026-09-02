import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
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

class CustomBottomNavBar extends StatefulWidget {
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

  static const Color activeTint = Color(0xFFDC3009);
  static const Color inactiveTint = Color(0xFF6B7280);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  bool _isDragging = false;
  double _dragOffset = 0.0;
  int _lastHapticIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastHapticIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.currentIndex != widget.currentIndex) {
      _lastHapticIndex = widget.currentIndex;
    }
  }

  void _handleTap(int index) {
    HapticFeedback.lightImpact();
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
      final hoveredIndex =
          (_dragOffset / itemWidth).floor().clamp(0, CustomBottomNavBar.items.length - 1);
      if (hoveredIndex != _lastHapticIndex) {
        HapticFeedback.selectionClick();
        _lastHapticIndex = hoveredIndex;
      }
    });
  }

  void _onPanEnd(DragEndDetails details, double totalWidth, double itemWidth) {
    final targetIndex =
        (_dragOffset / itemWidth).floor().clamp(0, CustomBottomNavBar.items.length - 1);
    setState(() {
      _isDragging = false;
    });
    HapticFeedback.mediumImpact();
    widget.onTap(targetIndex);
  }

  void _onPanCancel() {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navItems = CustomBottomNavBar.items;
    // Ba'zi Android qurilmalarida tizim navigatsiya paneli (3 tugmali yoki
    // gesture bar) qattiq `24.h`dan balandroq bo'ladi va bu suzuvchi panelni
    // o'ziga bosib qo'yadi — shuning uchun haqiqiy tizim inseti qo'shiladi,
    // panel har doim navigatsiyadan butunlay yuqorida turadi.
    final systemNavInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h + systemNavInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
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
                borderRadius: BorderRadius.circular(40.r),
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
                  final itemWidth = totalWidth / navItems.length;
                  final indicatorPadding = 3.w;
                  final indicatorWidth = itemWidth - (indicatorPadding * 2);

                  final double pillLeft;
                  final int activeDisplayIndex;

                  if (_isDragging) {
                    pillLeft = (_dragOffset - (indicatorWidth / 2))
                        .clamp(indicatorPadding, totalWidth - indicatorWidth - indicatorPadding);
                    activeDisplayIndex =
                        (_dragOffset / itemWidth).floor().clamp(0, navItems.length - 1);
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
                        // 1. Draggable/Swipeable Liquid Glass Pill Indicator
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
                                // Shishasimon nozik shaffof to'q sariq gradient
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    CustomBottomNavBar.activeTint.withValues(alpha: 0.16),
                                    CustomBottomNavBar.activeTint.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomBottomNavBar.activeTint.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. Tab Items Row
                        Row(
                          children: List.generate(navItems.length, (index) {
                            final item = navItems[index];
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
                                      AnimatedScale(
                                        scale: isSelected ? 1.06 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOutCubic,
                                        child: SvgPicture.asset(
                                          isSelected ? item.activeSvgPath : item.svgPath,
                                          width: 20.r,
                                          height: 20.r,
                                          fit: BoxFit.contain,
                                          colorFilter: isSelected
                                              ? null
                                              : const ColorFilter.mode(
                                                  CustomBottomNavBar.inactiveTint,
                                                  BlendMode.srcIn,
                                                ),
                                        ),
                                      ),
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
                                              ? CustomBottomNavBar.activeTint
                                              : CustomBottomNavBar.inactiveTint,
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
