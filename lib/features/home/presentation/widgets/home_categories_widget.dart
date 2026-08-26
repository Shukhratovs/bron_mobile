import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
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
      height: 84.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (context, index) => Gap(14.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                      width: 1.2.w,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      category.icon,
                      size: 22.r,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
                Gap(6.h),
                Text(
                  category.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
