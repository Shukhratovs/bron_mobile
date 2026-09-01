import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../core/staff_local_storage.dart';
import '../../domain/entities/staff_auth_entity.dart';
import '../../../main/presentation/screens/staff_main_screen.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';

/// 01-kirish.md §3 — `GET /staff/venues` ro'yxatida bittadan ko'p bo'lsa
/// ko'rsatiladi ("Qaysi joyda ishlaysiz?").
class MuassasaTanlashScreen extends StatelessWidget {
  final List<StaffVenueEntity> venues;
  final StaffLocalStorage localStorage;

  const MuassasaTanlashScreen({super.key, required this.venues, required this.localStorage});

  void _select(BuildContext context, StaffVenueEntity venue) async {
    await localStorage.setSelectedVenueId(venue.id);
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StaffMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Qaysi joyda ishlaysiz?',
          style: GoogleFonts.unbounded(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: venues.length,
        separatorBuilder: (context, index) => Gap(10.h),
        itemBuilder: (context, index) {
          final venue = venues[index];
          return GestureDetector(
            onTap: () => _select(context, venue),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(color: const Color(0xFFFFF2ED), borderRadius: BorderRadius.circular(12.r)),
                    child: AppIcon(AppAssets.iconStore2Fill, color: AppColors.primary, size: 22.r),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                venue.name,
                                style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ),
                            if (venue.isPrimary) ...[
                              Gap(6.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(6.r)),
                                child: Text('ASOSIY', style: GoogleFonts.plusJakartaSans(fontSize: 9.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
                              ),
                            ],
                          ],
                        ),
                        if (venue.district != null) ...[
                          Gap(2.h),
                          Text(venue.district!, style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  AppIcon(AppAssets.iconArrowRightSLine, color: AppColors.textSecondary, size: 20.r),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
