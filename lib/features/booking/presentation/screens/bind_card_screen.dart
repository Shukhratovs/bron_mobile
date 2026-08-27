import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class BindCardScreen extends StatefulWidget {
  const BindCardScreen({super.key});

  @override
  State<BindCardScreen> createState() => _BindCardScreenState();
}

class _BindCardScreenState extends State<BindCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _onGetSmsCode() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final rawCard = _cardNumberController.text.replaceAll(' ', '');
      final last4 = rawCard.length >= 4 ? rawCard.substring(rawCard.length - 4) : '4821';
      final formattedCard = 'UZCARD •••• $last4';

      Navigator.pop(context, formattedCard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Karta biriktirish',
            style: GoogleFonts.unbounded(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Notice Box
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
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20.r,
                      ),
                      Gap(8.w),
                      Text(
                        'Nega karta kerak?',
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
                    'Pik vaqtidagi bronlarda depozit kartada bloklanadi. Hozir hech narsa yechilmaydi va bloklanmaydi — karta faqat saqlanadi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: const Color(0xFF4B5563),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Gap(24.h),

            // Karta raqami
            Text(
              'Karta raqami',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(8.h),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              cursorColor: AppColors.primary,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: InputDecoration(
                hintText: '8600 0000 0000 0000',
                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                prefixIcon: const Icon(Icons.credit_card, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            Gap(16.h),

            // Amal muddati
            Text(
              'Amal muddati',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(8.h),
            TextField(
              controller: _expiryController,
              keyboardType: TextInputType.number,
              cursorColor: AppColors.primary,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                hintText: 'OO / YY',
                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            Gap(20.h),

            // Security note
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16.r,
                  color: AppColors.textSecondary,
                ),
                Gap(8.w),
                Expanded(
                  child: Text(
                    'Karta ma\'lumotlari xavfsiz shifrlanadi. Biz ularni saqlamaymiz va ko\'rmaymiz. CVV kodi talab etilmaydi.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: AppButton.primary(
            text: 'SMS kod olish',
            isLoading: _isLoading,
            onPressed: _onGetSmsCode,
          ),
        ),
      ),
    ),
    );
  }
}
