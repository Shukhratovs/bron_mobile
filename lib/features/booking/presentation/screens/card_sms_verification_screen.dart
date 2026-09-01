import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../profile/domain/repositories/card_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class CardSmsVerificationScreen extends StatefulWidget {
  final String bindingId;
  final String maskedPan;
  final CardRepository repository;

  const CardSmsVerificationScreen({
    super.key,
    required this.bindingId,
    required this.maskedPan,
    required this.repository,
  });

  @override
  State<CardSmsVerificationScreen> createState() => _CardSmsVerificationScreenState();
}

class _CardSmsVerificationScreenState extends State<CardSmsVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _hasError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _onVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await widget.repository.confirmCard(
      bindingId: widget.bindingId,
      code: code,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Success(:final data):
        Navigator.pop(context, data.id);
      case Failure(:final exception):
        if (exception.code == 'sms_invalid') {
          setState(() => _hasError = true);
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
            'SMS tasdiqlash',
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
                '${widget.maskedPan} kartasiga bog\'liq raqamga 6 xonali kod yuborildi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Gap(32.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48.w,
                    height: 60.h,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      cursorColor: AppColors.primary,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.unbounded(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: _hasError ? AppColors.error : AppColors.textPrimary,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
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
                            color: _hasError ? AppColors.error : const Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: _hasError ? AppColors.error : const Color(0xFFE5E7EB),
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

              if (_hasError)
                Center(
                  child: Text(
                    'SMS kod noto\'g\'ri. Qayta kiriting.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
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
              text: 'Tasdiqlash',
              isLoading: _isLoading,
              onPressed: _onVerify,
            ),
          ),
        ),
      ),
    );
  }
}
