import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  final List<Map<String, String>> _faqItems = const [
    {
      'question': 'Bronni qanday bekor qilish mumkin?',
      'answer':
          'Bronlarim bo\'limiga o\'ting, bekor qilmoqchi bo\'lgan broningizni tanlang va "Bronni bekor qilish" tugmasini bosing. Tashrifdan 2 soat oldin bekor qilish bepul amalga oshiriladi.',
    },
    {
      'question': 'Bron Bonusi qanday to\'planadi?',
      'answer':
          'Har safar ilova orqali muassasaga tashrif buyurib, to\'lovni amalga oshirganingizda va QR-kodni ko\'rsatganingizda hisobingizga keshbek bonusi yoziladi.',
    },
    {
      'question': 'QR-kod qayerda ko\'rinadi?',
      'answer':
          'Bron muvaffaqiyatli tasdiqlangandan so\'ng "Bronlarim" bo\'limida har bir bron kartasida "QR-kodni ko\'rsatish" tugmasi paydo bo\'ladi.',
    },
    {
      'question': 'Muassasa egasi bilan qanday bog\'lanaman?',
      'answer':
          'Har bir muassasa sahifasida "Qo\'ng\'iroq qilish" va "Xaritada ko\'rish" tugmalari mavjud.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.helpAndSupport,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Cards
            Text(
              AppStrings.contactSupport,
              style: GoogleFonts.unbounded(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(12.h),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.send_rounded,
                    title: 'Telegram Bot',
                    subtitle: '@bron_support_bot',
                    color: const Color(0xFF0088CC),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Telegram botga ulanmoqda...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Qo\'ng\'iroq',
                    subtitle: '+998 71 200 00 00',
                    color: AppColors.success,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('+998 71 200 00 00 ga qo\'ng\'iroq qilinmoqda...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            Gap(28.h),

            // FAQ List
            Text(
              AppStrings.faqTitle,
              style: GoogleFonts.unbounded(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(14.h),

            ...List.generate(_faqItems.length, (index) {
              final item = _faqItems[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    title: Text(
                      item['question']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                        child: Text(
                          item['answer']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.r, color: color),
            ),
            Gap(10.h),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(2.h),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
