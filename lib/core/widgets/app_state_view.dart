import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Ilova bo'ylab bir xil ko'rinishdagi holat ekrani: bo'sh ro'yxat,
/// internet yo'qligi yoki umumiy xato. Figma'dagi "Bo'sh kun / Internet
/// yo'q / Yuklanmoqda" holatlariga mos — barcha ekranlar shu bitta
/// widget'dan foydalanadi, shuning uchun har birini alohida qayta
/// yozish shart emas.
class AppStateView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? description;
  final VoidCallback? onRetry;

  const AppStateView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.description,
    this.onRetry,
  });

  factory AppStateView.noInternet({VoidCallback? onRetry}) => AppStateView(
        icon: Icons.wifi_off_rounded,
        iconColor: AppColors.warning,
        iconBackground: AppColors.warningSoft,
        title: AppStrings.noInternetTitle,
        description: AppStrings.noInternetDesc,
        onRetry: onRetry,
      );

  factory AppStateView.empty({
    IconData icon = Icons.inbox_outlined,
    String? title,
    String? description,
  }) =>
      AppStateView(
        icon: icon,
        iconColor: AppColors.textMuted,
        iconBackground: const Color(0xFFF3F4F6),
        title: title ?? AppStrings.noData,
        description: description,
      );

  factory AppStateView.error({VoidCallback? onRetry, String? title, String? description}) => AppStateView(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        iconBackground: AppColors.errorSoft,
        title: title ?? AppStrings.somethingWentWrong,
        description: description,
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Icon(icon, size: 34.r, color: iconColor),
            ),
            Gap(16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.unbounded(fontSize: 15.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (description != null) ...[
              Gap(6.h),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
            if (onRetry != null) ...[
              Gap(20.h),
              SizedBox(
                height: 44.h,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh_rounded, size: 18.r, color: Colors.white),
                  label: Text(
                    AppStrings.retry,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
