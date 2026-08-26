import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/menu_item_model.dart';

class FullMenuScreen extends StatefulWidget {
  final String venueName;
  final List<MenuItemModel>? menuItems;

  const FullMenuScreen({
    super.key,
    required this.venueName,
    this.menuItems,
  });

  @override
  State<FullMenuScreen> createState() => _FullMenuScreenState();
}

class _FullMenuScreenState extends State<FullMenuScreen> {
  final List<String> _categories = const [
    'Hammasi',
    'Mashhur',
    'Salatlar',
    'Issiq taomlar',
    'Shirinliklar',
  ];

  String _selectedCategory = 'Hammasi';

  @override
  Widget build(BuildContext context) {
    final items = widget.menuItems ?? MenuItemModel.mockMenuItems;
    final filteredItems = _selectedCategory == 'Hammasi'
        ? items
        : items.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'To\'liq menyu',
              style: GoogleFonts.unbounded(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.venueName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Filter Tabs
          SizedBox(
            height: 48.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => Gap(8.w),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;

                return Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textPrimary
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textPrimary
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Gap(12.h),

          // Menu Items List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => Gap(12.h),
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                return Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Item icon
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2ED),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primary,
                          size: 24.r,
                        ),
                      ),
                      Gap(14.w),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Gap(4.h),
                            Text(
                              item.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Gap(6.h),
                            Text(
                              item.price,
                              style: GoogleFonts.unbounded(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
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
    );
  }
}
