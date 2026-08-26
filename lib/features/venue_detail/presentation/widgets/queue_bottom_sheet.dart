import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/data/models/venue_model.dart';

class QueueBottomSheet extends StatelessWidget {
  final VenueModel venue;

  const QueueBottomSheet({
    super.key,
    required this.venue,
  });

  static Future<void> show(BuildContext context, {required VenueModel venue}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QueueBottomSheet(venue: venue),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Gap(16.h),
            Text(
              'Navbatga yozilishmi?',
              style: GoogleFonts.unbounded(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(6.h),
            Text(
              'Bugun 19:00 ga biror stol bo\'shasa, sizga darhol SMS xabar beramiz.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            Gap(16.h),

            // Warning / Information Box
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2ED),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Text(
                      'Bir nechta mijoz navbatda turibdi. Joy bo\'shasa, birinchi kelgan tasdiqlagan mijozga beriladi.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(24.h),

            AppButton.primary(
              text: 'Navbatga yozilish',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Siz navbatga muvaffaqiyatli qo\'shildingiz!',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
