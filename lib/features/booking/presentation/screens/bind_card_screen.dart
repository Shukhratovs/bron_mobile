import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/card_input_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../profile/data/datasources/card_remote_data_source.dart';
import '../../../profile/data/models/card_model.dart';
import '../../../profile/data/repositories/card_repository_impl.dart';
import '../../../profile/domain/repositories/card_repository.dart';
import '../widgets/card_declined_bottom_sheet.dart';
import 'card_sms_verification_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_toast.dart';

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

  // Kiritish maydoni allaqachon "OO/YY" ko'rinishida saqlaydi
  // (CardExpiryInputFormatter), qayta formatlash shart emas.
  String get _expiryFormatted => _expiryController.text;

  Future<void> _onSubmit() async {
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;
    final panDigits = _cardNumberController.text.replaceAll(' ', '');
    final expiryDigits = _expiryController.text.replaceAll('/', '');
    final holder = _holderController.text.trim();
    if (panDigits.length < 16 || expiryDigits.length < 4 || holder.isEmpty) {
      AppToast.warning(context, AppStrings.fillAllFields);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _repository.addCard(
      pan: panDigits,
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
          AppToast.error(context, exception.message);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
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
            AppStrings.bindCardTitle,
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
                          AppStrings.whyCardNeededTitle,
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
                      AppStrings.whyCardNeededDesc,
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
                AppStrings.cardHolderLabel,
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
                decoration: _fieldDecoration(hint: AppStrings.cardHolderHint, icon: Icons.person_outline_rounded),
              ),
              Gap(16.h),

              // Karta raqami
              Text(
                AppStrings.cardNumberLabel,
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
                inputFormatters: [CardNumberInputFormatter()],
                decoration: _fieldDecoration(hint: '#### #### #### ####', icon: Icons.credit_card),
              ),
              Gap(16.h),

              // Amal muddati
              Text(
                AppStrings.cardExpiryLabel,
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
                inputFormatters: [CardExpiryInputFormatter()],
                decoration: _fieldDecoration(hint: AppStrings.cardExpiryHint, icon: Icons.calendar_today_rounded),
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
                      AppStrings.cardSecurityNote,
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
              text: AppStrings.bindCardButton,
              isLoading: _isLoading,
              onPressed: _onSubmit,
            ),
          ),
        ),
      ),
    );
      },
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
