import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';

class CardDeclinedBottomSheet extends StatelessWidget {
  final VoidCallback? onSelectAnotherCard;
  final VoidCallback? onRetry;
  final String? message;

  const CardDeclinedBottomSheet({
    super.key,
    this.onSelectAnotherCard,
    this.onRetry,
    this.message,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSelectAnotherCard,
    VoidCallback? onRetry,
    String? message,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CardDeclinedBottomSheet(
        onSelectAnotherCard: onSelectAnotherCard,
        onRetry: onRetry,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Gap(20.h),
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 52.r,
            ),
            Gap(12.h),
            Text(
              AppStrings.cardDeclinedTitle,
              style: GoogleFonts.unbounded(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(8.h),
            Text(
              message ?? AppStrings.cardDeclinedDefaultMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            Gap(16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                AppStrings.cardNeverStoredNote,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB45309),
                ),
              ),
            ),
            Gap(24.h),
            AppButton.primary(
              text: AppStrings.selectAnotherCard,
              onPressed: () {
                Navigator.pop(context);
                onSelectAnotherCard?.call();
              },
            ),
            Gap(10.h),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry?.call();
              },
              child: Text(
                AppStrings.retry,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
