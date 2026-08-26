import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/data/models/venue_model.dart';
import '../../../main/presentation/screens/main_navigation_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final VenueModel venue;
  final String date;
  final String time;
  final int guestCount;
  final String tableZone;
  final String bookingId;

  const BookingConfirmedScreen({
    super.key,
    required this.venue,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.tableZone,
    this.bookingId = 'BRN-4831',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Gap(20.h),
              // Success Icon Circle
              Container(
                width: 68.r,
                height: 68.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38.r,
                  ),
                ),
              ),
              Gap(16.h),

              // Title & Subtitle
              Text(
                'Bron tasdiqlandi',
                style: GoogleFonts.unbounded(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(6.h),
              Text(
                'Kelganingizda QR kodni xodimga ko\'rsating',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Gap(24.h),

              // QR Code Box
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 160.r,
                      color: Colors.black,
                    ),
                    Gap(8.h),
                    Text(
                      bookingId,
                      style: GoogleFonts.unbounded(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      '30 soniyada yangilanadi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(20.h),

              // Details Summary Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Restoran', venue.name),
                    const Divider(color: Color(0xFFF0F0F0), height: 20),
                    _buildInfoRow('Sana va vaqt', '$date • $time'),
                    const Divider(color: Color(0xFFF0F0F0), height: 20),
                    _buildInfoRow('Mehmonlar', '$guestCount kishi'),
                    const Divider(color: Color(0xFFF0F0F0), height: 20),
                    _buildInfoRow('Stol', tableZone),
                  ],
                ),
              ),
              Gap(16.h),

              // Quick Actions (Kalendarga, Xaritada, Ulashish)
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.calendar_today_rounded,
                    label: 'Kalendarga',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Taqvimga muvaffaqiyatli saqlandi'),
                        ),
                      );
                    },
                  ),
                  Gap(10.w),
                  _buildActionButton(
                    icon: Icons.map_outlined,
                    label: 'Xaritada',
                    onTap: () {},
                  ),
                  Gap(10.w),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Ulashish',
                    onTap: () {},
                  ),
                ],
              ),
              Gap(28.h),

              // Done Button
              AppButton.primary(
                text: 'Tayyor',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20.r),
              Gap(4.h),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
