import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextStyle? textStyle;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = AppColors.backgroundDark,
    this.borderColor,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.textStyle,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
  });

  /// Factory constructor for Primary Orange Button
  factory AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    double? width = double.infinity,
    double? height,
    double? borderRadius,
    double? fontSize,
    FontWeight? fontWeight,
    TextStyle? textStyle,
    bool isLoading = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textStyle: textStyle,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      padding: padding,
    );
  }

  /// Factory constructor for White Button (like onboarding "Boshlash")
  factory AppButton.white({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    double? width = double.infinity,
    double? height,
    double? borderRadius,
    double? fontSize,
    FontWeight? fontWeight,
    TextStyle? textStyle,
    bool isLoading = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: AppColors.backgroundDark,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textStyle: textStyle,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      padding: padding,
    );
  }

  /// Factory constructor for Outlined Button
  factory AppButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color borderColor = AppColors.borderDark,
    Color textColor = AppColors.textWhite,
    double? width = double.infinity,
    double? height,
    double? borderRadius,
    double? fontSize,
    FontWeight? fontWeight,
    TextStyle? textStyle,
    bool isLoading = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      borderColor: borderColor,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textStyle: textStyle,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? Colors.white;
    final effectiveTextColor = textColor ?? AppColors.backgroundDark;
    final effectiveBorderRadius = borderRadius ?? 20.r;
    final effectiveHeight = height ?? 54.h;

    final content = isLoading
        ? SizedBox(
            width: 22.r,
            height: 22.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  Gap(8.w),
                ],
                Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: textStyle ??
                      GoogleFonts.plusJakartaSans(
                        fontSize: fontSize ?? 16.sp,
                        fontWeight: fontWeight ?? FontWeight.w600,
                        color: effectiveTextColor,
                      ),
                ),
                if (suffixIcon != null) ...[
                  Gap(8.w),
                  suffixIcon!,
                ],
              ],
            ),
          );

    // iOS 26 Liquid Glass button. Android keeps the Material button below —
    // liquid_glass_widgets renders its background colors incorrectly there.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final isOutline = effectiveBgColor == Colors.transparent;
      return SizedBox(
        width: width,
        height: effectiveHeight,
        child: GlassButton.custom(
          onTap: (isLoading || onPressed == null) ? () {} : onPressed!,
          enabled: !isLoading && onPressed != null,
          useOwnLayer: true,
          width: width,
          height: effectiveHeight,
          shape: LiquidRoundedRectangle(
            borderRadius: effectiveBorderRadius,
            side: borderColor != null ? BorderSide(color: borderColor!, width: 1.w) : BorderSide.none,
          ),
          style: isOutline ? GlassButtonStyle.transparent : GlassButtonStyle.prominent,
          settings: isOutline ? null : LiquidGlassSettings(glassColor: effectiveBgColor.withValues(alpha: 0.55)),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
            child: content,
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBgColor.withValues(alpha: 0.6),
          disabledForegroundColor: effectiveTextColor.withValues(alpha: 0.6),
          elevation: 0,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.w)
                : BorderSide.none,
          ),
        ),
        child: content,
      ),
    );
  }
}
