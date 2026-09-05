import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: GoogleFonts.unbounded(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
    final actionsRow = actions != null
        ? Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
          )
        : null;

    // iOS 26 Liquid Glass app bar. Android keeps the Material AppBar below —
    // liquid_glass_widgets renders its background colors incorrectly there.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return GlassAppBar(
        backgroundColor: backgroundColor ?? const Color(0x00000000),
        toolbarHeight: 56.h,
        centerTitle: true,
        title: titleWidget,
        leading: showBackButton
            ? Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Center(
                  child: GlassIconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16.r,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
                    size: 40.r,
                    shape: GlassIconButtonShape.roundedSquare,
                    borderRadius: 12.r,
                    useOwnLayer: true,
                  ),
                ),
              )
            : null,
        actions: actionsRow != null ? [actionsRow] : null,
      );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Center(
                child: InkWell(
                  onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16.r,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: titleWidget,
      actions: actionsRow != null ? [actionsRow] : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
