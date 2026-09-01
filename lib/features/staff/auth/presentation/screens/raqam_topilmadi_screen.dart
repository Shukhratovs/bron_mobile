import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';

/// 01-kirish.md §2.4 — `staff_not_found` odatiy holat, xato emas.
class RaqamTopilmadiScreen extends StatelessWidget {
  const RaqamTopilmadiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84.r,
              height: 84.r,
              decoration: const BoxDecoration(color: Color(0xFFFEF3EB), shape: BoxShape.circle),
              child: AppIcon(AppAssets.iconUserSearchLine, color: const Color(0xFFF79009), size: 42.r),
            ),
            Gap(20.h),
            Text(
              'Raqam topilmadi',
              style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Gap(10.h),
            Text(
              'Xodim raqami administrator tomonidan tizimga qo\'shiladi. Raqamingizni tekshiring yoki administratorga murojaat qiling.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary, height: 1.5),
            ),
            Gap(28.h),
            AppButton.primary(text: 'Qayta urinish', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
