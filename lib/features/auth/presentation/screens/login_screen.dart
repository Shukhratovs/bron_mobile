import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/bron_logo.dart';
import '../../data/models/telegram_auth_request_model.dart';
import '../../domain/repositories/auth_repository.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: 'Aziz Karimov');
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleTelegramLogin() async {
    _unfocus();
    setState(() => _isLoading = true);

    // Telegram OAuth / WebApp simulation or bot data
    final req = TelegramAuthRequestModel(
      id: DateTime.now().millisecondsSinceEpoch % 1000000000,
      firstName: _nameController.text.trim().split(' ').first,
      lastName: _nameController.text.trim().split(' ').length > 1
          ? _nameController.text.trim().split(' ').sublist(1).join(' ')
          : '',
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : '+998901234567',
      username: 'aziz_karimov',
      authDate: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      hash: 'telegram_auth_hash',
    );

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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF181A20)),
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
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

                // Divider with "yoki"
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFECEFF3))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Text(
                        'yoki telefon orqali',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFECEFF3))),
                  ],
                ),
                Gap(20.h),

                // Name Field
                Text(
                  'Ism va familiya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF181A20),
                  ),
                ),
                Gap(6.h),
                TextField(
                  controller: _nameController,
                  cursorColor: AppColors.primary,
                  onTapOutside: (_) => _unfocus(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF181A20),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Aziz Karimov',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFECEFF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFECEFF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                Gap(16.h),

                // Phone Field
                Text(
                  'Telefon raqam',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF181A20),
                  ),
                ),
                Gap(6.h),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  cursorColor: AppColors.primary,
                  onTapOutside: (_) => _unfocus(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF181A20),
                  ),
                  decoration: InputDecoration(
                    hintText: '+998 90 123-45-67',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFECEFF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFECEFF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                Gap(24.h),

                // Primary Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleTelegramLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Davom etish',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Gap(32.h),

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
  }
}
