import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/bonus_history_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class BonusScreen extends StatefulWidget {
  final int initialBalance;
  final ProfileRepository repository;

  const BonusScreen({
    super.key,
    required this.initialBalance,
    required this.repository,
  });

  @override
  State<BonusScreen> createState() => _BonusScreenState();
}

class _BonusScreenState extends State<BonusScreen> {
  List<BonusHistoryEntity> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final result = await widget.repository.getBonusHistory();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _history = data;
          _isLoading = false;
        });
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.bronBonus,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Bonus Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: const Color(0xFF1E2024),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.bonusBackBig),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  alignment: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.yourBonusBalance,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textWhite.withValues(alpha: 0.8),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    '${widget.initialBalance} B',
                    style: GoogleFonts.unbounded(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  Gap(6.h),
                  Text(
                    '1 bonus = 1 so\'m',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppColors.textWhite.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Gap(28.h),

            // How it works section
            Text(
              AppStrings.howItWorks,
              style: GoogleFonts.unbounded(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(14.h),
            _buildStepItem('1', AppStrings.bonusStep1),
            _buildStepItem('2', AppStrings.bonusStep2),
            _buildStepItem('3', AppStrings.bonusStep3),
            _buildStepItem('4', AppStrings.bonusStep4),

            Gap(28.h),

            // Bonus History section
            Text(
              AppStrings.bonusHistory,
              style: GoogleFonts.unbounded(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(14.h),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.dividerLight,
                      ),
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        final isEarned = item.type == BonusTransactionType.earned;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          child: Row(
                            children: [
                              Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  color: isEarned ? AppColors.successSoft : AppColors.errorSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isEarned ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  size: 20.r,
                                  color: isEarned ? AppColors.success : AppColors.error,
                                ),
                              ),
                              Gap(14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Gap(2.h),
                                    Text(
                                      item.date,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.sp,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isEarned ? '+' : '-'}${item.amount} B',
                                style: GoogleFonts.unbounded(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isEarned ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.unbounded(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Gap(14.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
