import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/category_model.dart';

class HomeCategoriesWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const HomeCategoriesWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((category) {
          final isSelected = category.id == selectedCategoryId;
          final isComingSoon = category.comingSoon;
          return GestureDetector(
            onTap: () => isComingSoon
                ? AppToast.info(context, AppStrings.comingSoonBadge)
                : onCategorySelected(category.id),
            child: SizedBox(
              width: 80.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Opacity(
                        opacity: isComingSoon ? 0.4 : 1.0,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: isComingSoon ? 1.2 : 0,
                            sigmaY: isComingSoon ? 1.2 : 0,
                          ),
                          child: Container(
                            width: 56.r,
                            height: 56.r,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: AppIcon(
                                category.iconAsset,
                                size: 24.r,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF161616),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isComingSoon)
                        Positioned(
                          top: -2.h,
                          right: -6.w,
                          child: Container(
                            width: 18.r,
                            height: 18.r,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 11.r,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Gap(6.h),
                  Text(
                    category.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isComingSoon
                          ? AppColors.textMuted
                          : isSelected
                              ? const Color(0xFF161616)
                              : const Color(0xFF5C5C5C),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
