import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Kartani o'chirishni tasdiqlash — o'rtada chiqadigan dialog (varaq
/// emas), ikonka bilan. "Bosib ushlab turing" orqali darhol o'chirib
/// yuborish o'rniga foydalanuvchidan aniq tasdiq so'raladi.
class DeleteCardDialog extends StatelessWidget {
  final String maskedPan;

  const DeleteCardDialog({super.key, required this.maskedPan});

  static Future<bool> show(BuildContext context, {required String maskedPan}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteCardDialog(maskedPan: maskedPan),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: const BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded, size: 32.r, color: AppColors.error),
            ),
            Gap(16.h),
            Text(
              AppStrings.deleteCardTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.unbounded(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(8.h),
            Text(
              '${AppStrings.deleteCardDesc}\n$maskedPan',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            Gap(22.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: Icon(Icons.delete_outline_rounded, size: 18.r, color: Colors.white),
                    label: Text(
                      AppStrings.delete,
                      style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: Size(double.infinity, 48.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
