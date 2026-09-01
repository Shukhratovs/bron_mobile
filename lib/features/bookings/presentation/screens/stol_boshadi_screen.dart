import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../waitlist/domain/entities/waitlist_entity.dart';
import '../../../waitlist/domain/repositories/waitlist_repository.dart';
import 'booking_detail_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

/// Figma: `Stol bo'shadi` (`211:1481`) — mijoz/05-navbat.md §4.
/// `status: chaqirilgan` bo'lganda 10 daqiqalik tasdiqlash oynasi.
class StolBoshadiScreen extends StatefulWidget {
  final WaitlistEntity entry;
  final String venueName;
  final WaitlistRepository repository;

  const StolBoshadiScreen({
    super.key,
    required this.entry,
    required this.venueName,
    required this.repository,
  });

  @override
  State<StolBoshadiScreen> createState() => _StolBoshadiScreenState();
}

class _StolBoshadiScreenState extends State<StolBoshadiScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final expiresAt = widget.entry.expiresAt;
    if (expiresAt == null) return;
    final remaining = expiresAt.difference(DateTime.now());
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    if (remaining.isNegative) _timer?.cancel();
  }

  String get _formatted {
    final m = _remaining.inMinutes.toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _onConfirm() async {
    setState(() => _isSubmitting = true);
    final result = await widget.repository.confirm(widget.entry.id);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success(:final data):
        if (data.bookingId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: data.bookingId!)),
          );
        } else {
          Navigator.pop(context);
        }
      case Failure(:final exception):
        final message = switch (exception.code) {
          'confirm_expired' => 'Vaqt tugadi — stol boshqa mehmonga o\'tdi',
          'not_called' => 'Siz hali chaqirilmadingiz',
          _ => exception.message,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
        if (exception.code == 'confirm_expired') Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = _remaining == Duration.zero;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(color: Color(0xFFDC3009), shape: BoxShape.circle),
              child: const AppIcon(AppAssets.iconCalendarCheckFill, color: Colors.white, size: 34),
            ),
            Gap(18.h),
            Text(
              'Stol bo\'shadi',
              style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Gap(4.h),
            Text(
              '${widget.venueName} • ${widget.entry.guests} kishi${widget.entry.offeredTable != null ? ' • Stol ${widget.entry.offeredTable}' : ''}',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary),
            ),
            Gap(24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(color: const Color(0xFFFDEEE8), borderRadius: BorderRadius.circular(16.r)),
              child: Column(
                children: [
                  Text(
                    expired ? '00:00' : _formatted,
                    style: GoogleFonts.unbounded(fontSize: 34.sp, fontWeight: FontWeight.w800, color: const Color(0xFFDC3009)),
                  ),
                  Gap(2.h),
                  Text(
                    expired ? 'vaqt tugadi' : 'tasdiqlash uchun qoldi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, fontWeight: FontWeight.w500, color: const Color(0xFFDC3009)),
                  ),
                ],
              ),
            ),
            Gap(24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: expired || _isSubmitting ? null : _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3009),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Bronni tasdiqlash', style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600)),
              ),
            ),
            Gap(10.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Voz kechaman',
                style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
