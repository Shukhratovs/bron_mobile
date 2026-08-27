import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking/presentation/screens/bind_card_screen.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  final List<Map<String, dynamic>> _cards = [
    {
      'type': 'UZCARD',
      'number': '•••• 4821',
      'isPrimary': true,
    },
    {
      'type': 'HUMO',
      'number': '•••• 9034',
      'isPrimary': false,
    },
  ];

  void _onAddNewCard() async {
    final newCard = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const BindCardScreen(),
      ),
    );

    if (newCard != null && mounted) {
      setState(() {
        _cards.add({
          'type': newCard.contains('HUMO') ? 'HUMO' : 'UZCARD',
          'number': newCard.replaceAll('UZCARD', '').replaceAll('HUMO', '').trim(),
          'isPrimary': _cards.isEmpty,
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yangi karta muvaffaqiyatli qo\'shildi'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kartalarim',
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
            // Cards Group Container
            if (_cards.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFECEFF3)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cards.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFECEFF3),
                  ),
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            color: const Color(0xFF6B7280),
                            size: 22.r,
                          ),
                          Gap(14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      card['type'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF181A20),
                                      ),
                                    ),
                                    if (card['isPrimary'] == true) ...[
                                      Gap(8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'ASOSIY',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2563EB),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Gap(4.h),
                                Text(
                                  card['number'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5.sp,
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
                    );
                  },
                ),
              ),
              Gap(14.h),
            ],

            // Dashed / Outlined "+ Yangi karta qo'shish" button
            GestureDetector(
              onTap: _onAddNewCard,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFFFB29D),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: const Color(0xFFE53935),
                        size: 20.r,
                      ),
                      Gap(6.w),
                      Text(
                        'Yangi karta qo\'shish',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Gap(16.h),

            // Footnote
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Karta ma\'lumotlari Bron serverida saqlanmaydi. To\'lov tizimi tokenizatsiyasi ishlatiladi.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
