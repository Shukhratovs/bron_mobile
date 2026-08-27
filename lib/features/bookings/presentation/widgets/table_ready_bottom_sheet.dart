import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/booking_detail_screen.dart';

class TableReadyBottomSheet extends StatefulWidget {
  final VoidCallback? onDismissQueue;

  const TableReadyBottomSheet({
    super.key,
    this.onDismissQueue,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onDismissQueue}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TableReadyBottomSheet(onDismissQueue: onDismissQueue),
    );
  }

  @override
  State<TableReadyBottomSheet> createState() => _TableReadyBottomSheetState();
}

class _TableReadyBottomSheetState extends State<TableReadyBottomSheet> {
  int _secondsRemaining = 582; // 09:42 = 9 * 60 + 42
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onConfirm() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BookingDetailScreen(
          venueName: 'Osteria Da Vinci',
          bookingId: 'BRN-4821',
          date: '27-iyul, yakshanba',
          time: '19:00',
          guests: '4 kishi',
          table: '12 · deraza yonida',
          address: 'Bunyodkor ko\'chasi 12 · 1,2 km',
        ),
      ),
    );
  }

  void _onCancel() {
    Navigator.of(context).pop();
    widget.onDismissQueue?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Grab Bar
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
            Gap(24.h),

            // Red/Orange Circular Icon
            Container(
              width: 56.r,
              height: 56.r,
              decoration: const BoxDecoration(
                color: Color(0xFFDC3009),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            Gap(16.h),

            // Title & Subtitle
            Text(
              'Stol bo\'shadi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181A20),
              ),
              textAlign: TextAlign.center,
            ),
            Gap(4.h),
            Text(
              'Osteria Da Vinci · bugun 19:30 · 4 kishi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            Gap(20.h),

            // Timer Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEEE8),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Text(
                    _formattedTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC3009),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    'tasdiqlash uchun qoldi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFDC3009),
                    ),
                  ),
                ],
              ),
            ),
            Gap(24.h),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3009),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'Bronni tasdiqlash',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Gap(10.h),

            // Cancel Text Button
            TextButton(
              onPressed: _onCancel,
              child: Text(
                'Voz kechaman',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            Gap(10.h),
          ],
        ),
      ),
    );
  }
}
