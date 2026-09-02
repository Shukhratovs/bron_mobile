import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import 'navbatga_yozilish_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

/// Figma: `Slot band bo'ldi` (`102:683`). Ochiladi: band chip bosilganda
/// yoki `POST /bookings` dan `409 no_table_available` kelganda
/// (mijoz/01-vaqt-tanlash.md, mijoz/02-bron-qilish.md).
class SlotBandBoldiScreen extends StatelessWidget {
  final VenueEntity venue;
  final DateTime date;
  final String time;
  final int guests;

  const SlotBandBoldiScreen({
    super.key,
    required this.venue,
    required this.date,
    required this.time,
    required this.guests,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84.r,
              height: 84.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3EB),
                shape: BoxShape.circle,
              ),
              child: AppIcon(AppAssets.iconCalendarCloseFill, color: const Color(0xFFF79009), size: 42.r),
            ),
            Gap(20.h),
            Text(
              AppStrings.slotTaken,
              style: GoogleFonts.unbounded(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(8.h),
            Text(
              '${venue.name} • ${formatDateShort(date)}, $time • $guests ${AppStrings.persons}',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            Gap(28.h),
            AppButton.primary(
              text: AppStrings.joinWaitlist,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavbatgaYozilishScreen(
                      venue: venue,
                      initialDate: date,
                      guests: guests,
                    ),
                  ),
                );
              },
            ),
            Gap(10.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.chooseAnotherTime,
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
      },
    );
  }
}
