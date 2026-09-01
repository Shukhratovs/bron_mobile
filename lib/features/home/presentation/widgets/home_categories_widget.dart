import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
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
          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: SizedBox(
              width: 80.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
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
                  Gap(6.h),
                  Text(
                    category.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
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
