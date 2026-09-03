import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'app_icon.dart';

enum AppToastType { success, error, warning, info }

/// Ilova dizayniga mos, tepadan (status bar ostidan) tushib keladigan
/// zamonaviy toast — `ScaffoldMessenger.of(context).showSnackBar(...)`
/// o'rniga ishlatiladi (standart Material SnackBar pastdan chiqadi va
/// ilova uslubiga mos emas edi).
///
/// `Overlay` orqali chiziladi — shuning uchun bottom sheet ichidan ham
/// (masalan tasdiqlash varag'i) chaqirilsa, sheet ustida ko'rinadi.
class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration? duration,
  }) {
    // Bir vaqtda faqat bitta toast — yangisi ko'rsatilishidan oldin
    // avvalgisi (agar bo'lsa) darhol olib tashlanadi.
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final effectiveDuration = duration ??
        Duration(milliseconds: (2200 + message.length * 30).clamp(2200, 4200));

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppToastContent(
        message: message,
        type: type,
        duration: effectiveDuration,
        onDismissed: () {
          entry.remove();
          if (identical(_currentEntry, entry)) _currentEntry = null;
        },
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: AppToastType.success, duration: duration);

  static void error(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: AppToastType.error, duration: duration);

  static void warning(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: AppToastType.warning, duration: duration);

  static void info(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: AppToastType.info, duration: duration);
}

class _ToastVisual {
  final Color color;
  final Color soft;
  final String icon;
  const _ToastVisual(this.color, this.soft, this.icon);
}

class _AppToastContent extends StatefulWidget {
  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _AppToastContent({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_AppToastContent> createState() => _AppToastContentState();
}

class _AppToastContentState extends State<_AppToastContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;
  Timer? _hideTimer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _offset = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6),
      reverseCurve: const Interval(0.35, 1.0),
    );
    _controller.forward();
    _hideTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _hideTimer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  _ToastVisual get _visual => switch (widget.type) {
        AppToastType.success => const _ToastVisual(AppColors.success, AppColors.successSoft, AppAssets.iconCheckboxCircleFill),
        AppToastType.error => const _ToastVisual(AppColors.error, AppColors.errorSoft, AppAssets.iconErrorWarningLine),
        AppToastType.warning => const _ToastVisual(AppColors.warning, AppColors.warningSoft, AppAssets.iconErrorWarningLine),
        AppToastType.info => const _ToastVisual(AppColors.primary, AppColors.primarySoft, AppAssets.iconInformationLine),
      };

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _opacity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < 0) {
                    _controller.value = (_controller.value + details.delta.dy / 120).clamp(0.0, 1.0);
                  }
                },
                onVerticalDragEnd: (details) {
                  if (_controller.value < 0.6 || (details.primaryVelocity ?? 0) < -300) {
                    _dismiss();
                  } else {
                    _controller.forward();
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 10)),
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(color: visual.soft, shape: BoxShape.circle),
                          child: Center(child: AppIcon(visual.icon, size: 17.r, color: visual.color)),
                        ),
                        Gap(10.w),
                        Expanded(
                          child: Text(
                            widget.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
