import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/widgets/bron_logo.dart';
import '../../domain/entities/telegram_login_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_toast.dart';

/// Figma: mijoz "Telefon raqami"/"SMS kirish" ekranlari SMS gateway
/// bo'lmagani uchun chizilmaydi — buning o'rniga Telegram bot oqimi
/// (mijoz/00-kirish-va-profil.md §1-2): `start` -> deep_link -> `status`
/// pollingi, xostesdagi bilan bir xil naqsh.
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

enum _LoginState { idle, waitingForTelegram, polling }

class _LoginScreenState extends State<LoginScreen> {
  _LoginState _state = _LoginState.idle;
  Timer? _pollTimer;
  DateTime? _expiresAt;
  String? _errorMessage;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _startLogin() async {
    _unfocus();
    setState(() {
      _state = _LoginState.waitingForTelegram;
      _errorMessage = null;
    });

    final result = await widget.authRepository.startTelegramLogin();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        _expiresAt = DateTime.now().add(Duration(seconds: data.expiresIn));
        await launchUrl(Uri.parse(data.deepLink), mode: LaunchMode.externalApplication);
        if (!mounted) return;
        setState(() => _state = _LoginState.polling);
        _schedulePoll(data.nonce, data.pollAfterSeconds);
      case Failure(:final exception):
        setState(() {
          _state = _LoginState.idle;
          _errorMessage = exception.message;
        });
    }
  }

  void _schedulePoll(String nonce, int afterSeconds) {
    _pollTimer?.cancel();
    _pollTimer = Timer(Duration(seconds: afterSeconds), () => _poll(nonce, afterSeconds));
  }

  Future<void> _poll(String nonce, int afterSeconds) async {
    if (!mounted) return;
    if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
      setState(() {
        _state = _LoginState.idle;
        _errorMessage = 'Kirish vaqti tugadi — qaytadan urinib ko\'ring';
      });
      return;
    }

    final result = await widget.authRepository.pollTelegramLogin(nonce);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        switch (data.status) {
          case TelegramLoginPollStatus.pending:
            _schedulePoll(nonce, afterSeconds);
          case TelegramLoginPollStatus.success:
            await _onLoggedIn();
          case TelegramLoginPollStatus.expired:
            setState(() {
              _state = _LoginState.idle;
              _errorMessage = 'Kirish vaqti tugadi — qaytadan urinib ko\'ring';
            });
        }
      case Failure():
        // Vaqtinchalik tarmoq nosozligi (fonga o'tish, wifi uzilishi va
        // h.k.) butun 5 daqiqalik oynani bekor qilmasligi kerak —
        // shunchaki keyingi urinishgacha kutamiz; `_expiresAt` yuqorida
        // allaqachon tekshiriladi va haqiqiy muddat tugashini nazorat
        // qiladi.
        _schedulePoll(nonce, afterSeconds);
    }
  }

  Future<void> _onLoggedIn() async {
    await AppSession.pushService.registerTokenAfterLogin();
    if (!mounted) return;

    AppToast.success(context, 'Xush kelibsiz! Tizimga muvaffaqiyatli kirdingiz.');
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _state != _LoginState.idle;
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
                      isBusy
                          ? 'Telegramda "Raqamni yuborish" tugmasini bosing. Tasdiqlanishi bir necha soniya davom etadi.'
                          : 'Bron platformasi orqali eng yaxshi restoran va joylarni bir zumda band qiling.',
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
                        onPressed: isBusy ? null : _startLogin,
                        icon: isBusy
                            ? const SizedBox.shrink()
                            : const AppIcon(AppAssets.iconSendPlaneFill, color: Colors.white, size: 20),
                        label: isBusy
                            ? SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                AppStrings.loginViaTelegram,
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
                    if (_errorMessage != null) ...[
                      Gap(16.h),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    Gap(20.h),

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
