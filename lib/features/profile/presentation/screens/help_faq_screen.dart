import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_toast.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftLine, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.help,
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
            // Top Contact Group
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFECEFF3)),
              ),
              child: Column(
                children: [
                  // Telegram option
                  InkWell(
                    onTap: () {
                      AppToast.info(context, AppStrings.telegramOpening);
                    },
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.telegramBot,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE53935),
                                  ),
                                ),
                                Gap(3.h),
                                Text(
                                  AppStrings.telegramSupportSubtitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 20.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFECEFF3),
                  ),
                  // Call option
                  InkWell(
                    onTap: () {
                      AppToast.info(context, AppStrings.callOpening);
                    },
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.callUs,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF181A20),
                                  ),
                                ),
                                Gap(3.h),
                                Text(
                                  AppStrings.callUsSubtitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 20.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(22.h),

            // TEZ-TEZ BERILADIGAN SAVOLLAR Section Header
            Text(
              AppStrings.faqSectionHeader,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8E8E93),
                letterSpacing: 0.5,
              ),
            ),
            Gap(10.h),

            // FAQ List Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFECEFF3)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppStrings.faqItems.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFECEFF3),
                ),
                itemBuilder: (context, index) {
                  final faqItems = AppStrings.faqItems;
                  final (question, answer) = faqItems[index];
                  final isExpanded = _expandedIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? Radius.circular(16.r) : Radius.zero,
                      bottom: index == faqItems.length - 1 ? Radius.circular(16.r) : Radius.zero,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  question,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF181A20),
                                  ),
                                ),
                              ),
                              Gap(8.w),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.chevron_right_rounded,
                                color: const Color(0xFF9CA3AF),
                                size: 20.r,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            Gap(10.h),
                            Text(
                              answer,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Gap(20.h),

            // Footer Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                AppStrings.faqFooterNote,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                  height: 1.4,
                ),
              ),
            ),
            Gap(30.h),
          ],
        ),
      ),
    );
      },
    );
  }
}
