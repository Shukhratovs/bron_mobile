import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/data/models/venue_model.dart';
import 'booking_confirmed_screen.dart';

class SmsVerificationScreen extends StatefulWidget {
  final VenueModel venue;
  final String date;
  final String time;
  final int guestCount;
  final String tableZone;
  final String phoneNumber;

  const SmsVerificationScreen({
    super.key,
    required this.venue,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.tableZone,
    this.phoneNumber = '+998 90 123-45-67',
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  int _timerSeconds = 45;
  Timer? _timer;
  bool _hasError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controllers[0].text = '4';
    _controllers[1].text = '1';
    _controllers[2].text = '9';
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onVerify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 5) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmedScreen(
            venue: widget.venue,
            date: widget.date,
            time: widget.time,
            guestCount: widget.guestCount,
            tableZone: widget.tableZone,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tasdiqlash',
          style: GoogleFonts.unbounded(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SMS kodni kiriting',
              style: GoogleFonts.unbounded(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(8.h),
            Text(
              '${widget.phoneNumber} raqamiga 5 xonali kod yuborildi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
            Gap(32.h),

            // 5-digit PIN input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: 58.w,
                  height: 64.h,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.unbounded(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: _hasError ? AppColors.error : AppColors.textPrimary,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 4) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      setState(() => _hasError = false);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: _hasError
                              ? AppColors.error
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: _hasError
                              ? AppColors.error
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: _hasError ? AppColors.error : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Gap(16.h),

            // Error or Resend Timer
            if (_hasError)
              Center(
                child: Text(
                  'Kod noto\'g\'ri. Qayta tekshiring.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              )
            else
              Center(
                child: _timerSeconds > 0
                    ? Text(
                        'Kodni qayta yuborish - 00:${_timerSeconds.toString().padLeft(2, '0')}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : GestureDetector(
                        onTap: _startTimer,
                        child: Text(
                          'Kod kelmadimi? Qayta yuborish',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: AppButton.primary(
            text: 'Tasdiqlash va davom etish',
            isLoading: _isLoading,
            onPressed: _onVerify,
          ),
        ),
      ),
    );
  }
}
