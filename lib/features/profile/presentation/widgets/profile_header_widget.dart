import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfileEntity? user;
  final VoidCallback onEditPressed;
  final VoidCallback? onLoginPressed;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.onEditPressed,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: AppIcon(
                AppAssets.iconUser3Line,
                size: 30.r,
                color: AppColors.primary,
              ),
            ),
          ),
          Gap(14.w),
          Expanded(
            child: Text(
              AppStrings.loginOrRegister,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onLoginPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(80.w, 36.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              AppStrings.login,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // Logged in user header row
    final avatarPath = user!.avatarUrl ?? AppAssets.me;

    return Row(
      children: [
        // Avatar with green status indicator
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F4F6),
              ),
              child: ClipOval(
                child: Image.asset(
                  avatarPath,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primarySoft,
                    child: AppIcon(
                      AppAssets.iconUser3Fill,
                      size: 32.r,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 2.h,
              child: Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        Gap(14.w),

        // User Name and Phone Number
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user!.fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(4.h),
              Text(
                user!.phoneNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // "Tahrirlash" button with pencil icon and text
        GestureDetector(
          onTap: onEditPressed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppAssets.iconEditLine,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                Gap(6.w),
                Text(
                  AppStrings.editProfile,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
