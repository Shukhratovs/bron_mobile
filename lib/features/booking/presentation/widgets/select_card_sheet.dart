import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../profile/domain/entities/card_entity.dart';

/// Bron tasdiqlash ekranida "Karta" qatoriga bosilganda ochiladigan,
/// mavjud kartalar orasidan tanlash uchun varaq.
///
/// `show` allaqachon biriktirilgan kartalardan birining `id`sini, yoki
/// "Yangi karta qo'shish" bosilsa [addNewCardSentinel]ni qaytaradi —
/// chaqiruvchi shu sentinel bo'yicha `BindCardScreen`ga o'tadi.
class SelectCardSheet extends StatelessWidget {
  static const String addNewCardSentinel = '__add_new_card__';

  final List<CardEntity> cards;
  final String? selectedCardId;

  const SelectCardSheet({super.key, required this.cards, this.selectedCardId});

  static Future<String?> show(
    BuildContext context, {
    required List<CardEntity> cards,
    String? selectedCardId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SelectCardSheet(cards: cards, selectedCardId: selectedCardId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Gap(18.h),
            Text(
              AppStrings.selectCardTitle,
              style: GoogleFonts.unbounded(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Gap(20.h),
            ...cards.map((card) {
              final isSelected = card.id == selectedCardId;
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(card.id),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySoft : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      AppIcon(AppAssets.iconWallet3Line, size: 20.r, color: AppColors.textSecondary),
                      Gap(12.w),
                      Expanded(
                        child: Text(
                          '${card.cardType.toUpperCase()} ${card.maskedPan}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.textMuted, width: 2),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10.r,
                                  height: 10.r,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(addNewCardSentinel),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFFFB29D), width: 1.2),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: const Color(0xFFE53935), size: 20.r),
                      Gap(6.w),
                      Text(
                        AppStrings.addNewCard,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFFE53935)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
