import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_toast.dart';

enum SubscriptionPlan { monthly, yearly }

class BonusScreen extends StatefulWidget {
  final int initialBalance;
  final ProfileRepository? repository;
  final bool initialIsActive;

  const BonusScreen({
    super.key,
    this.initialBalance = 25000,
    this.repository,
    this.initialIsActive = false,
  });

  @override
  State<BonusScreen> createState() => _BonusScreenState();
}

class _BonusScreenState extends State<BonusScreen> {
  late bool _isSubscribed;
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSubscribed = widget.initialIsActive;
  }

  void _handleSubscribe() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSubscribed = true;
    });

    AppToast.success(context, AppStrings.bronPlusActivatedSuccess);
  }

  void _showCancelBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Gap(16.h),

                  // Title
                  Text(
                    AppStrings.cancelSubscriptionTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF181A20),
                    ),
                  ),
                  Gap(8.h),

                  // Subtitle
                  Text(
                    AppStrings.cancelSubscriptionDesc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.45,
                    ),
                  ),
                  Gap(14.h),

                  // Gray Highlight Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFECEFF3)),
                    ),
                    child: Text(
                      AppStrings.cancelSubscriptionSavingsNote,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                        height: 1.4,
                      ),
                    ),
                  ),
                  Gap(20.h),

                  // Primary Button: "Yo'q, obunani qoldiraman"
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.keepSubscriptionButton,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Gap(12.h),

                  // Secondary Button: "Ha, bekor qilaman"
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isSubscribed = false;
                        });
                        AppToast.warning(context, AppStrings.subscriptionCancelledToast);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                        child: Text(
                          AppStrings.confirmCancelSubscription,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        return _isSubscribed ? _buildActiveSubscriptionView() : _buildPurchaseView();
      },
    );
  }

  // =========================================================================
  // 1. PURCHASE / INTRO VIEW (Screen 1)
  // =========================================================================
  Widget _buildPurchaseView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Dark Header with Arches Banner — scroll bo'lganda joyidan
          // siljimasligi uchun scroll kontentdan tashqarida, sobit
          // sarlavha sifatida turadi.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF181A20),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.r),
              ),
              image: const DecorationImage(
                image: AssetImage(AppAssets.bonusBackBig),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                alignment: Alignment.topRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20.r,
                          ),
                        ),
                      ),
                    ),
                    Gap(18.h),

                    // "BRON PLUS" Pill Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        AppStrings.bronPlus,
                        style: GoogleFonts.unbounded(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Gap(12.h),

                    // Title
                    Text(
                      AppStrings.bonusPlusHeaderTitle,
                      style: GoogleFonts.unbounded(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    Gap(8.h),

                    // Subtitle
                    Text(
                      AppStrings.bonusPlusHeaderSubtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(16.h),

                  // Padding for body items
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      children: [
                        // Benefits List Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: const Color(0xFFECEFF3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          child: Column(
                            children: [
                              _buildBenefitRow(
                                title: AppStrings.benefitPriorityTitle,
                                subtitle: AppStrings.benefitPrioritySubtitle,
                              ),
                              Gap(16.h),
                              _buildBenefitRow(
                                title: AppStrings.benefitDiscountTitle,
                                subtitle: AppStrings.benefitDiscountSubtitle,
                              ),
                              Gap(16.h),
                              _buildBenefitRow(
                                title: AppStrings.benefitNoDepositTitle,
                                subtitle: AppStrings.benefitNoDepositSubtitle,
                              ),
                              Gap(16.h),
                              _buildBenefitRow(
                                title: AppStrings.benefitBirthdayTitle,
                                subtitle: AppStrings.benefitBirthdaySubtitle,
                              ),
                            ],
                          ),
                        ),
                        Gap(14.h),

                        // Plan 1: 1 oy
                        _buildPlanOption(
                          plan: SubscriptionPlan.monthly,
                          title: AppStrings.planMonthlyTitle,
                          subtitle: AppStrings.planMonthlySubtitle,
                          price: '39 000',
                          isSelected: _selectedPlan == SubscriptionPlan.monthly,
                        ),
                        Gap(10.h),

                        // Plan 2: 12 oy (with -25% badge)
                        _buildPlanOption(
                          plan: SubscriptionPlan.yearly,
                          title: AppStrings.planYearlyTitle,
                          badgeText: '-25%',
                          subtitle: AppStrings.planYearlySubtitle,
                          price: '29 000',
                          isSelected: _selectedPlan == SubscriptionPlan.yearly,
                        ),
                        Gap(16.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _selectedPlan == SubscriptionPlan.yearly
                                  ? AppStrings.activatePlusYearly
                                  : AppStrings.activatePlusMonthly,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    AppStrings.cancelAnytimeNote,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check,
          color: AppColors.primary,
          size: 20.r,
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF181A20),
                ),
              ),
              Gap(2.h),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanOption({
    required SubscriptionPlan plan,
    required String title,
    String? badgeText,
    required String subtitle,
    required String price,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF2ED) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFECEFF3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF181A20),
                        ),
                      ),
                      if (badgeText != null) ...[
                        Gap(8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Gap(4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181A20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. ACTIVE SUBSCRIPTION VIEW (Screen 2)
  // =========================================================================
  Widget _buildActiveSubscriptionView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftSLine, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.subscriptionTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF181A20),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Subscription Dark Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(20.r),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.bonusBack),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  alignment: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      AppStrings.bronPlus,
                      style: GoogleFonts.unbounded(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Gap(12.h),

                  // Title: "Obuna faol"
                  Text(
                    AppStrings.subscriptionActiveTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Gap(4.h),

                  // Subtitle
                  Text(
                    AppStrings.subscriptionActiveUntil,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Gap(14.h),

            // Savings & Stats Card (480 000 so'm / 12 bron)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFECEFF3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '480 000 so\'m',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF181A20),
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        AppStrings.savingsWithPlusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '12',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF181A20),
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        AppStrings.bookingsCountLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(20.h),

            // FAOL IMTIYOZLAR Header
            Text(
              AppStrings.activeBenefitsHeader,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8E8E93),
                letterSpacing: 0.6,
              ),
            ),
            Gap(10.h),

            // Active Privileges Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFECEFF3)),
              ),
              child: Column(
                children: [
                  _buildSimpleBenefitItem(AppStrings.benefitPriorityTitle),
                  Gap(14.h),
                  _buildSimpleBenefitItem(AppStrings.benefitDiscountTitle),
                  Gap(14.h),
                  _buildSimpleBenefitItem(AppStrings.benefitNoDepositTitle),
                  Gap(14.h),
                  _buildSimpleBenefitItem(AppStrings.benefitBirthdayTitle),
                ],
              ),
            ),
            Gap(16.h),

            // Obunani bekor qilish Card Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFECEFF3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showCancelBottomSheet,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        AppStrings.cancelSubscriptionButton,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBenefitItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check,
          color: AppColors.primary,
          size: 18.r,
        ),
        Gap(12.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF181A20),
            ),
          ),
        ),
      ],
    );
  }
}
