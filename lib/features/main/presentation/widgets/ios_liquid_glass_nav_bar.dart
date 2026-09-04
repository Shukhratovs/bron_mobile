import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_bottom_nav_bar.dart' show BottomNavItem, CustomBottomNavBar;

/// iOS "Liquid Glass" floating bottom navigation bar.
///
/// Refinements:
/// - Real optical crystal glass transparency (crisp 10 sigma blur, no milky haze).
/// - Well-proportioned navbar height (58.h) placed lower towards bottom edge.
/// - Wider, more compact height pill (height: 44.h, width: 76.w) floating with breathing room.
/// - Dynamic liquid swelling & expansion during swipe and hold gestures.
/// - Inactive icons and text in sharp black (0xFF1C1C1E); active in main orange (0xFFDC3009).
class IosLiquidGlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem>? items;

  const IosLiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  /// Optimal height of the floating capsule navbar.
  static const double capsuleHeight = 58.0;

  /// Height of the floating liquid oval pill inside the navbar.
  static const double pillHeight = 44.0;

  /// Reserved space at the bottom of screens so scrollable content
  /// clears the floating navbar comfortably.
  static double reservedBottomSpace(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return capsuleHeight + (bottomInset > 0 ? bottomInset : 4) + 16;
  }

  @override
  State<IosLiquidGlassNavBar> createState() => _IosLiquidGlassNavBarState();
}

class _IosLiquidGlassNavBarState extends State<IosLiquidGlassNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _positionAnim;

  // Hold / Touch swell controller
  late AnimationController _holdController;
  late Animation<double> _holdScaleAnim;

  // Liquid wobble/wave controller for live fluid movement while swiping
  late AnimationController _waveController;

  // Swipe & Fluid Liquid state
  bool _isDragging = false;
  double _dragStartTouchX = 0.0;
  double _startPosition = 0.0;
  double _currentPosition = 0.0;
  double _lastDragX = 0.0;
  double _dragStretch = 0.0;
  int _lastHapticIndex = 0;
  double _animBegin = 0.0;
  double _animEnd = 0.0;

  List<BottomNavItem> get _items => widget.items ?? CustomBottomNavBar.items;

  static const Color itemColor = Color(0xFF1C1C1E); // Crisp black for all items

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentIndex.toDouble();
    _lastHapticIndex = widget.currentIndex;
    _animBegin = _currentPosition;
    _animEnd = _currentPosition;

    // Movement animation controller
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _positionAnim = Tween<double>(
      begin: _animBegin,
      end: _animEnd,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    // Hold / Touch swell animation
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _holdScaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOutCubic,
    ));

    // Continuous wave wobble during drag
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant IosLiquidGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.currentIndex != widget.currentIndex) {
      _lastHapticIndex = widget.currentIndex;
      _animateTo(widget.currentIndex.toDouble());
    }
  }

  void _animateTo(double target) {
    _animBegin = _animController.isAnimating ? _positionAnim.value : _currentPosition;
    _animEnd = target;
    _currentPosition = _animBegin;

    _positionAnim = Tween<double>(
      begin: _animBegin,
      end: _animEnd,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _animController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _holdController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onTapItem(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  // --- Smooth Drag / Swipe & Liquid Swell Handling ---
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _holdController.forward();
    _waveController.repeat();
    _dragStartTouchX = details.localPosition.dx;
    _lastDragX = details.localPosition.dx;
    _startPosition = _animController.isAnimating ? _positionAnim.value : widget.currentIndex.toDouble();
    _currentPosition = _startPosition;
    _dragStretch = 0.0;
    _animController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details, double itemWidth) {
    final deltaX = details.localPosition.dx - _dragStartTouchX;
    final deltaIndex = deltaX / itemWidth;

    final speed = (details.localPosition.dx - _lastDragX).abs();
    _lastDragX = details.localPosition.dx;

    setState(() {
      _currentPosition = (_startPosition + deltaIndex).clamp(0.0, _items.length - 1.0);
      // Fluid water stretching: expands visibly when moving
      _dragStretch = (_dragStretch * 0.5 + (speed / 10.0) * 0.5).clamp(0.0, 0.45);

      final hoveredIndex = _currentPosition.round().clamp(0, _items.length - 1);
      if (hoveredIndex != _lastHapticIndex) {
        HapticFeedback.selectionClick();
        _lastHapticIndex = hoveredIndex;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _dragStretch = 0.0;
    _holdController.reverse();
    _waveController.stop();
    _waveController.reset();

    final velocityX = details.primaryVelocity ?? 0.0;
    int targetIndex;
    if (velocityX > 350) {
      targetIndex = (_currentPosition + 0.35).ceil().clamp(0, _items.length - 1);
    } else if (velocityX < -350) {
      targetIndex = (_currentPosition - 0.35).floor().clamp(0, _items.length - 1);
    } else {
      targetIndex = _currentPosition.round().clamp(0, _items.length - 1);
    }

    HapticFeedback.lightImpact();
    widget.onTap(targetIndex);
    _animateTo(targetIndex.toDouble());
  }

  void _onPanCancel() {
    _isDragging = false;
    _dragStretch = 0.0;
    _holdController.reverse();
    _waveController.stop();
    _waveController.reset();
    _animateTo(widget.currentIndex.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Lower the navbar down towards the bottom
    final bottomPadding = bottomInset > 0 ? math.max(2.h, bottomInset - 6.h) : 4.h;
    final items = _items;
    final barHeight = IosLiquidGlassNavBar.capsuleHeight.h;
    final pillBaseHeight = IosLiquidGlassNavBar.pillHeight.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottomPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemWidth = totalWidth / items.length;
          // Wider pill width so icon and text sit comfortably
          final basePillWidth = math.min(itemWidth * 0.94, 76.w);

          return SizedBox(
            height: barHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. 100% Pure Crystal Glass Base Capsule (Orqa fon xuddi pill kabi tiniq ko'rinadi)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(barHeight / 2),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(barHeight / 2),
                          // 100% shaffof shisha (hech qanday xiralashtiruvchi oq qatlamlarsiz)
                          color: Colors.white.withValues(alpha: 0.04),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Fluid Liquid Glass Oval Pill Indicator (Swipe qilinganda kattalashib qimirlaydi)
                AnimatedBuilder(
                  animation: Listenable.merge([_positionAnim, _holdController, _waveController]),
                  builder: (context, _) {
                    final double activePos;
                    final double stretch;
                    final double wave;

                    if (_isDragging) {
                      activePos = _currentPosition;
                      stretch = _dragStretch;
                      // Liquid quiver / wobble while dragging
                      wave = math.sin(_waveController.value * math.pi * 2) * 0.04 * (_dragStretch > 0.05 ? 1.0 : 0.0);
                    } else {
                      activePos = _positionAnim.value;
                      final animProgress = _animController.value;
                      final dist = (_animEnd - _animBegin).abs();
                      stretch = math.sin(animProgress * math.pi) * 0.25 * math.min(dist, 1.5);
                      wave = 0.0;
                    }

                    // Expansion factor: grows larger during swipe & hold
                    final holdScale = _holdScaleAnim.value;
                    final swipeScale = 1.0 + (stretch * 0.15) + wave;

                    // Dynamic liquid width & height (kichikroq height, kattaroq width)
                    final currentPillWidth = basePillWidth * (1.0 + stretch) * holdScale * swipeScale;
                    final currentPillHeight = pillBaseHeight * (1.0 - stretch * 0.06) * holdScale;
                    final currentPillTop = (barHeight - currentPillHeight) / 2;

                    final pillLeft = (activePos * itemWidth) + (itemWidth - currentPillWidth) / 2;

                    // Shisha effekti: swipe yoki siljish paytida 1.0 (shisha), to'xtaganda 0.0 (hira grey)
                    final double glassIntensity;
                    if (_isDragging) {
                      glassIntensity = 1.0;
                    } else if (_animController.isAnimating) {
                      glassIntensity = (math.sin(_animController.value * math.pi) * 1.3).clamp(0.0, 1.0);
                    } else {
                      glassIntensity = 0.0;
                    }

                    return Positioned(
                      left: pillLeft,
                      top: currentPillTop,
                      width: currentPillWidth,
                      height: currentPillHeight,
                      child: IgnorePointer(
                        child: _LiquidGlassOvalPill(
                          width: currentPillWidth,
                          height: currentPillHeight,
                          glassIntensity: glassIntensity,
                        ),
                      ),
                    );
                  },
                ),

                // 3. Tab Items Row with Drag, Tap & Hold Detection
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (_) => _holdController.forward(),
                    onTapUp: (_) => _holdController.reverse(),
                    onTapCancel: () => _holdController.reverse(),
                    onHorizontalDragStart: _onPanStart,
                    onHorizontalDragUpdate: (d) => _onPanUpdate(d, itemWidth),
                    onHorizontalDragEnd: _onPanEnd,
                    onHorizontalDragCancel: _onPanCancel,
                    child: AnimatedBuilder(
                      animation: _positionAnim,
                      builder: (context, _) {
                        final currentPos = _isDragging ? _currentPosition : _positionAnim.value;

                        return Row(
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            final distance = (currentPos - index).abs();
                            final isSelected = distance < 0.45;

                            return Expanded(
                              child: InkWell(
                                onTap: () => _onTapItem(index),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Center(
                                  child: _TabItemContent(
                                    item: item,
                                    isSelected: isSelected,
                                    proximity: (1.0 - distance.clamp(0.0, 1.0)),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The Oval Pill Indicator:
/// - Shunchaki turganda: yumshoq hiraaa grey capsule.
/// - Swipe / harakatlanayotganda: dinamik tarzda suyuq billur shishaga aylanadi (liquid glass)!
class _LiquidGlassOvalPill extends StatelessWidget {
  final double width;
  final double height;
  final double glassIntensity;

  const _LiquidGlassOvalPill({
    required this.width,
    required this.height,
    required this.glassIntensity,
  });

  @override
  Widget build(BuildContext context) {
    final pillRadius = BorderRadius.circular(height / 2);
    final intensity = glassIntensity.clamp(0.0, 1.0);

    // Turganda: hiraaa grey (0x1F000000). Swipe paytida: yaqqol ko'rinadigan shaffof suyuq shisha linza
    final baseColor = Color.lerp(
      const Color(0x1F000000),
      const Color(0x36000000), // ko'rinadigan chuqur shisha foni
      intensity,
    )!;

    final borderColor = Color.lerp(
      const Color(0x14000000),
      const Color(0x38000000), // aniq ko'rinuvchi shisha hoshiyasi
      intensity,
    )!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: pillRadius,
        boxShadow: intensity > 0.05
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16 * intensity),
                  blurRadius: 12,
                  spreadRadius: -1,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: pillRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12.0 * intensity,
            sigmaY: 12.0 * intensity,
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: pillRadius,
              color: baseColor,
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: intensity > 0.05
                ? CustomPaint(
                    size: Size(width, height),
                    painter: _PillSpecularPainter(intensity: intensity),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Swipe paytida shisha yaltirashi (specular gleam) nuri
class _PillSpecularPainter extends CustomPainter {
  final double intensity;

  _PillSpecularPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Yuqori oq yaltiroq nurlanish yoyi (Top Specular Arc)
    final topSpecularPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.90 * intensity),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final topArcPath = Path();
    topArcPath.addArc(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      math.pi * 1.15,
      math.pi * 0.70,
    );
    canvas.drawPath(topArcPath, topSpecularPaint);

    // 2. Pastki nozik aks (Bottom Light Rim)
    final bottomRimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bottomArcPath = Path();
    bottomArcPath.addArc(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      math.pi * 0.20,
      math.pi * 0.60,
    );
    canvas.drawPath(bottomArcPath, bottomRimPaint);
  }

  @override
  bool shouldRepaint(covariant _PillSpecularPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}

/// Content of a single navigation tab (Icon + Text label)
class _TabItemContent extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final double proximity;

  const _TabItemContent({
    required this.item,
    required this.isSelected,
    required this.proximity,
  });

  @override
  Widget build(BuildContext context) {
    final activeProximity = proximity.clamp(0.0, 1.0);

    // Rang o'zgarmaydi: tanlanganda ham, tanlanmaganda ham qora (0xFF1C1C1E)
    const iconColor = _IosLiquidGlassNavBarState.itemColor;

    final scale = 1.0 + (0.04 * activeProximity);

    final isSvg = item.svgPath.endsWith('.svg');
    final activePath = item.activeSvgPath.isNotEmpty ? item.activeSvgPath : item.svgPath;
    final currentSvg = (isSelected && activePath.isNotEmpty) ? activePath : item.svgPath;

    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          if (isSvg)
            SvgPicture.asset(
              currentSvg,
              width: 20.r,
              height: 20.r,
              colorFilter: const ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            )
          else
            const Icon(
              Icons.circle,
              size: 20,
              color: iconColor,
            ),
          Gap(2.h),
          // Label
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: iconColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
