import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../home/data/models/venue_model.dart';
import 'bind_card_screen.dart';
import 'sms_verification_screen.dart';

class DepositConfirmationScreen extends StatefulWidget {
  final VenueModel venue;
  final String date;
  final String time;
  final int guestCount;
  final String tableZone;

  const DepositConfirmationScreen({
    super.key,
    required this.venue,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.tableZone,
  });

  @override
  State<DepositConfirmationScreen> createState() =>
      _DepositConfirmationScreenState();
}

class _DepositConfirmationScreenState extends State<DepositConfirmationScreen> {
  String _selectedCard = 'UZCARD •••• 4821';
  bool _isLoading = false;

  void _onConfirmBooking() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmsVerificationScreen(
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

  void _onChangeCard() async {
    final newCard = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BindCardScreen(),
      ),
    );

    if (newCard != null && mounted) {
      setState(() => _selectedCard = newCard);
    }
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
          'Bronni tasdiqlash',
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
            // Venue Card
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
              child: Row(
                children: [
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2ED),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 26.r,
                    ),
                  ),
                  Gap(14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.venue.name,
                          style: GoogleFonts.unbounded(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          widget.venue.address,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Booking Details Table
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
                  _buildDetailRow('Sana', widget.date),
                  const Divider(color: Color(0xFFF0F0F0), height: 24),
                  _buildDetailRow('Vaqt', widget.time),
                  const Divider(color: Color(0xFFF0F0F0), height: 24),
                  _buildDetailRow('Mehmonlar', '${widget.guestCount} kishi'),
                  const Divider(color: Color(0xFFF0F0F0), height: 24),
                  _buildDetailRow('Stol', widget.tableZone),
                ],
              ),
            ),
            Gap(16.h),

            // Deposit Notice Box
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2ED),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 20.r,
                      ),
                      Gap(8.w),
                      Text(
                        'Depozit • ${widget.venue.depositAmount}',
                        style: GoogleFonts.unbounded(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Gap(8.h),
                  Text(
                    'Bu summa kartangizda bloklanadi — hisobingizdan yechilmaydi. Restoranda hisobingizga o\'tadi. Bronni 6 soat oldin bekor qilsangiz, blok butunlay olib tashlanadi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: const Color(0xFF4B5563),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),

            // Selected Bank Card
            GestureDetector(
              onTap: _onChangeCard,
              child: Container(
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
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.textPrimary,
                      size: 22.r,
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Text(
                        _selectedCard,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20.r,
                    ),
                  ],
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
            text: 'Bloklash va bron qilish',
            isLoading: _isLoading,
            onPressed: _onConfirmBooking,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
