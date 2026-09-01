import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final List<Map<String, String>> _faqItems = const [
    {
      'question': 'Depozit nima va u qachon qaytariladi?',
      'answer':
          'Depozit — bu gavjum va pik soatlarda stolni siz uchun kafolatli saqlab turish garovidir. Restoranga o\'z vaqtida tashrif buyurganingizda, depozit to\'liq hisobdan chiqariladi yoki umumiy chekingizdan chegirib beriladi.',
    },
    {
      'question': 'Bronni qanday bekor qilaman?',
      'answer':
          'Bronlarim bo\'limiga o\'tib, kerakli bronni tanlang va "Bronni bekor qilish" tugmasini bosing. Tashrifdan 2 soat oldin bekor qilinsa, hech qanday jarima qo\'llanilmaydi.',
    },
    {
      'question': 'Kelmasam nima bo\'ladi?',
      'answer':
          'Agar ogohlantirmasdan kelmasangiz (no-show), depozit qaytarilmasligi va profilingizning ishonchlilik reytingi pasayishi mumkin.',
    },
    {
      'question': 'Geym klubda soatlab bron qanday ishlaydi?',
      'answer':
          'Geym klublarda aniq soatlar (masalan, 19:00 dan 22:00 gacha) va VIP xonalar to\'g\'ridan-to\'g\'ri tanlanadi va band qilinadi.',
    },
    {
      'question': 'Usta tanlamasam kim xizmat ko\'rsatadi?',
      'answer':
          'Agar usta tanlanmasa, tashrif vaqtidagi birinchi bo\'sh mutaxassis sizga xizmat ko\'rsatadi.',
    },
    {
      'question': 'BRON Plus obunasini qanday bekor qilaman?',
      'answer':
          'Profil -> BRON PLUS bo\'limiga kirib, "Obunani bekor qilish" tugmasini bosish orqali istalgan payt bekor qilishingiz mumkin.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
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
          'Yordam',
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('@bron_support Telegram qo\'llab-quvvatlash ochilmoqda...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
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
                                  'Telegram orqali yozish',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE53935),
                                  ),
                                ),
                                Gap(3.h),
                                Text(
                                  '@bron_support · odatda 5 daqiqada javob',
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('+998 71 200-00-00 raqamiga ulanmoqda...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
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
                                  'Qo\'ng\'iroq qilish',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF181A20),
                                  ),
                                ),
                                Gap(3.h),
                                Text(
                                  '+998 71 200-00-00 · 09:00–21:00',
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
              'TEZ-TEZ BERILADIGAN SAVOLLAR',
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
                itemCount: _faqItems.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFECEFF3),
                ),
                itemBuilder: (context, index) {
                  final item = _faqItems[index];
                  final isExpanded = _expandedIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? Radius.circular(16.r) : Radius.zero,
                      bottom: index == _faqItems.length - 1 ? Radius.circular(16.r) : Radius.zero,
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
                                  item['question']!,
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
                              item['answer']!,
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
                'Javob topa olmadingizmi — Telegramda yozing, menejerimiz yordam beradi.',
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
  }
}
