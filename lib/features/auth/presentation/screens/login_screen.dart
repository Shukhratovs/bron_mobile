import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/telegram_config.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/widgets/bron_logo.dart';
import '../../data/models/telegram_auth_request_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'telegram_webview_login_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.authRepository,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  void _showNotConfiguredNotice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Telegram kirish hali sozlanmagan'),
        content: const Text(
          'Backend har bir kirishda Telegramning o\'zi hisoblagan raqamli '
          'imzoni (`hash`) talab qiladi — uni qo\'lda yoki soxta yuborib '
          'bo\'lmaydi (xavfsizlik uchun ataylab shunday). Haqiqiy kirish '
          'faqat Telegram bot username sozlangach ishlaydi '
          '(core/constants/telegram_config.dart).',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tushunarli')),
        ],
      ),
    );
  }

  Future<void> _handleTelegramLogin() async {
    _unfocus();

    if (!TelegramConfig.isConfigured) {
      _showNotConfiguredNotice();
      return;
    }

    // Haqiqiy Telegram Login Widget (mijoz/00-kirish-va-profil.md §1-2).
    final widgetResult = await Navigator.push<TelegramAuthRequestModel>(
      context,
      MaterialPageRoute(builder: (context) => const TelegramWebviewLoginScreen()),
    );
    if (widgetResult == null || !mounted) return;
    final req = widgetResult;

    setState(() => _isLoading = true);
    final result = await widget.authRepository.loginWithTelegram(req);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      onSuccess: (token) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xush kelibsiz! Tizimga muvaffaqiyatli kirdingiz.'),
            backgroundColor: AppColors.success,
          ),
        );
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          Navigator.of(context).pop(true);
        }
      },
      onFailure: (exception) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const AppIcon(AppAssets.iconArrowLeftLine, color: Color(0xFF181A20)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(10.h),
                Center(
                  child: BronLogo(
                    width: 100.w,
                    height: 38.h,
                    isDarkText: true,
                  ),
                ),
                Gap(32.h),

                Text(
                  AppStrings.loginOrRegister,
                  style: GoogleFonts.unbounded(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF181A20),
                    height: 1.3,
                  ),
                ),
                Gap(8.h),
                Text(
                  'Bron platformasi orqali eng yaxshi restoran va joylarni bir zumda band qiling.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                Gap(32.h),

                // Telegram Primary Auth Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleTelegramLogin,
                    icon: _isLoading
                        ? const SizedBox.shrink()
                        : const AppIcon(AppAssets.iconSendPlaneFill, color: Colors.white, size: 20),
                    label: _isLoading
                        ? SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Telegram orqali kirish',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF229ED9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                Gap(20.h),

                if (!TelegramConfig.isConfigured) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppIcon(AppAssets.iconInformationLine, color: Color(0xFFB45309), size: 20),
                      Gap(10.w),
                      Expanded(
                        child: Text(
                          'Telegram bot hali sozlanmagan — kirish ishlamaydi. Backend '
                          'har doim Telegramning haqiqiy raqamli imzosini (`hash`) '
                          'talab qiladi, uni soxta yuborib bo\'lmaydi.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF92400E),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(20.h),
                ],

                // Terms & Privacy Note
                Center(
                  child: Text(
                    'Davom etish orqali siz Foydalanish shartlari va Maxfiylik siyosatiga rozilik bildirasiz.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: const Color(0xFF8E8E93),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
