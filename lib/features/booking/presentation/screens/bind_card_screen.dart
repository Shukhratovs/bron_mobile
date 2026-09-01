import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../profile/data/datasources/card_remote_data_source.dart';
import '../../../profile/data/models/card_model.dart';
import '../../../profile/data/repositories/card_repository_impl.dart';
import '../../../profile/domain/repositories/card_repository.dart';
import '../widgets/card_declined_bottom_sheet.dart';
import 'card_sms_verification_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class BindCardScreen extends StatefulWidget {
  final CardRepository? repository;

  const BindCardScreen({super.key, this.repository});

  @override
  State<BindCardScreen> createState() => _BindCardScreenState();
}

class _BindCardScreenState extends State<BindCardScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _holderController = TextEditingController();
  late final CardRepository _repository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        CardRepositoryImpl(
          remoteDataSource: CardRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  String get _expiryFormatted {
    final digits = _expiryController.text;
    if (digits.length < 4) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2, 4)}';
  }

  Future<void> _onSubmit() async {
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;
    final pan = _cardNumberController.text.trim();
    final holder = _holderController.text.trim();
    if (pan.length < 16 || _expiryController.text.length < 4 || holder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcha maydonlarni to\'ldiring')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _repository.addCard(
      pan: pan,
      expiry: _expiryFormatted,
      holder: holder.toUpperCase(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Success(:final data):
        switch (data) {
          case BindCardSuccess(:final card):
            Navigator.pop(context, card.id);
          case BindCardSmsRequired(:final bindingId, :final maskedPan):
            final cardId = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => CardSmsVerificationScreen(
                  bindingId: bindingId,
                  maskedPan: maskedPan,
                  repository: _repository,
                ),
              ),
            );
            if (cardId != null && mounted) Navigator.pop(context, cardId);
        }
      case Failure(:final exception):
        if (exception.code == 'payment_declined') {
          if (!mounted) return;
          CardDeclinedBottomSheet.show(
            context,
            onSelectAnotherCard: () {
              _cardNumberController.clear();
              _expiryController.clear();
              _holderController.clear();
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(exception.message), backgroundColor: AppColors.error),
          );
        }
    }
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
            icon: const AppIcon(AppAssets.iconArrowLeftSLine, color: AppColors.textPrimary),
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

              Text(
                'Karta egasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(8.h),
              TextField(
                controller: _holderController,
                textCapitalization: TextCapitalization.characters,
                cursorColor: AppColors.primary,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _fieldDecoration(hint: 'IVANOV IVAN', icon: Icons.person_outline_rounded),
              ),
              Gap(16.h),

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
                decoration: _fieldDecoration(hint: '8600 0000 0000 0000', icon: Icons.credit_card),
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
                decoration: _fieldDecoration(hint: 'OOYY', icon: Icons.calendar_today_rounded),
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
                      'Karta raqami hech qachon saqlanmaydi. Ma\'lumotlar xavfsiz shifrlanadi. CVV kodi talab etilmaydi.',
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
              text: 'Kartani biriktirish',
              isLoading: _isLoading,
              onPressed: _onSubmit,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
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
    );
  }
}
