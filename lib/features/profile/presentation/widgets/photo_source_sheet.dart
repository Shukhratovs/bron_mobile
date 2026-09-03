import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

enum PhotoSourceAction { camera, gallery, remove }

/// "Profil rasmini o'zgartirish" bosilganda chiqadigan tanlov varag'i —
/// Kameradan olish / Galereyadan tanlash, mavjud rasm bo'lsa esa uni
/// olib tashlash.
class PhotoSourceSheet extends StatelessWidget {
  final bool canRemove;

  const PhotoSourceSheet({super.key, required this.canRemove});

  static Future<PhotoSourceAction?> show(BuildContext context, {required bool canRemove}) {
    return showModalBottomSheet<PhotoSourceAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PhotoSourceSheet(canRemove: canRemove),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(18.h),
            Text(
              AppStrings.choosePhotoTitle,
              style: GoogleFonts.unbounded(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(20.h),
            _option(
              context,
              icon: Icons.camera_alt_outlined,
              label: AppStrings.takePhoto,
              onTap: () => Navigator.of(context).pop(PhotoSourceAction.camera),
            ),
            Gap(12.h),
            _option(
              context,
              icon: Icons.photo_library_outlined,
              label: AppStrings.chooseFromGallery,
              onTap: () => Navigator.of(context).pop(PhotoSourceAction.gallery),
            ),
            if (canRemove) ...[
              Gap(12.h),
              _option(
                context,
                icon: Icons.delete_outline_rounded,
                label: AppStrings.removePhoto,
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap: () => Navigator.of(context).pop(PhotoSourceAction.remove),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.r, color: iconColor ?? AppColors.primary),
            Gap(14.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
