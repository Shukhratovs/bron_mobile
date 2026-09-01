import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/bron_logo.dart';
import '../../../core/staff_session.dart';
import '../../data/datasources/staff_auth_remote_data_source.dart';
import '../../data/repositories/staff_auth_repository_impl.dart';
import '../../domain/entities/staff_auth_entity.dart';
import '../../domain/repositories/staff_auth_repository.dart';
import 'muassasa_tanlash_screen.dart';
import 'raqam_topilmadi_screen.dart';
import '../../../main/presentation/screens/staff_main_screen.dart';

/// Figma: xostes "Kirish" ekrani. 01-kirish.md — Telegram bot orqali,
/// SMS yo'q. `deep_link` ochiladi, so'ng nonce har `poll_after_seconds`da
/// so'raladi (`expires_in` gacha).
class StaffLoginScreen extends StatefulWidget {
  final StaffAuthRepository? repository;

  const StaffLoginScreen({super.key, this.repository});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

enum _LoginState { idle, waitingForTelegram, polling }

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  late final StaffAuthRepository _repository;
  _LoginState _state = _LoginState.idle;
  Timer? _pollTimer;
  DateTime? _expiresAt;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        StaffAuthRepositoryImpl(
          remoteDataSource: StaffAuthRemoteDataSourceImpl(apiClient: StaffSession.apiClient),
        );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _startLogin() async {
    setState(() {
      _state = _LoginState.waitingForTelegram;
      _errorMessage = null;
    });
    final result = await _repository.start();
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

    final result = await _repository.poll(nonce);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        switch (data.status) {
          case TelegramLoginPollStatus.pending:
            _schedulePoll(nonce, afterSeconds);
          case TelegramLoginPollStatus.success:
            await _onLoggedIn(data.token!);
          case TelegramLoginPollStatus.staffNotFound:
            setState(() => _state = _LoginState.idle);
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RaqamTopilmadiScreen()));
          case TelegramLoginPollStatus.loginExpired:
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

  Future<void> _onLoggedIn(StaffTokenOut token) async {
    final storage = StaffSession.localStorage;
    await storage.saveAuthToken(
      accessToken: token.accessToken,
      tokenType: token.tokenType,
      expiresIn: token.expiresIn,
    );
    await storage.saveStaffMeta(role: token.role, organizationId: token.organizationId, venueId: token.venueId);

    final venuesResult = await _repository.getVenues();
    if (!mounted) return;

    final venues = venuesResult.dataOrNull ?? const <StaffVenueEntity>[];
    if (venues.length > 1) {
      // `pushReplacement` (`pushAndRemoveUntil` emas) — bu ekran Xostes
      // ilovasining ildizi bo'lganda ikkalasi bir xil natija beradi, lekin
      // Mijoz ilovasi ichidan "dev" rejimida ochilganda mijoz stekini
      // yo'q qilib qo'ymaydi (Profil -> Xostes rejimi).
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MuassasaTanlashScreen(venues: venues, localStorage: storage)),
      );
    } else {
      if (venues.length == 1) await storage.setSelectedVenueId(venues.first.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StaffMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _state != _LoginState.idle;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BronLogo(width: 120.w, height: 44.h, isDarkText: true),
              Gap(10.h),
              Text(
                'Xostes',
                style: GoogleFonts.unbounded(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1.0),
              ),
              Gap(40.h),
              Text(
                'Telegram orqali kirish',
                style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              Gap(10.h),
              Text(
                isBusy
                    ? 'Telegramda "Raqamni yuborish" tugmasini bosing. Tasdiqlanishi bir necha soniya davom etadi.'
                    : 'Administrator tizimga qo\'shgan telefon raqamingiz bilan Telegram orqali kiring.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary, height: 1.5),
              ),
              Gap(28.h),
              if (isBusy)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                AppButton.primary(text: 'Telegram orqali kirish', onPressed: _startLogin),
              if (_errorMessage != null) ...[
                Gap(16.h),
                Text(_errorMessage!, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.error), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
