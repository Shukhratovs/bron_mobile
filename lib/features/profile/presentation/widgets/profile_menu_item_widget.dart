import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? iconData;
  final String? svgPath;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
  final bool showDivider;

  const ProfileMenuItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.iconData,
    this.svgPath,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
            child: Row(
              children: [
                // Leading Icon
                if (svgPath != null)
                  SvgPicture.asset(
                    svgPath!,
                    width: 22.r,
                    height: 22.r,
                    colorFilter: ColorFilter.mode(
                      isDestructive ? AppColors.error : const Color(0xFF2C2D30),
                      BlendMode.srcIn,
                    ),
                  )
                else if (iconData != null)
                  Icon(
                    iconData,
                    size: 22.r,
                    color: isDestructive ? AppColors.error : const Color(0xFF2C2D30),
                  ),

                Gap(14.w),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w600,
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ),

                // Subtitle / Trailing
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                  Gap(6.w),
                ],

                if (trailing != null)
                  trailing!
                else if (!isDestructive)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFFC7C7CC),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 54.w, right: 18.w),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.dividerLight,
            ),
          ),
      ],
    );
  }
}
