import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CollectionItem {
  final String id;
  final String title;
  final String placesCount;
  final String imagePath;

  const CollectionItem({
    required this.id,
    required this.title,
    required this.placesCount,
    required this.imagePath,
  });
}

class HomeCollectionsSection extends StatelessWidget {
  final ValueChanged<CollectionItem>? onCollectionTap;
  final VoidCallback? onViewAllTap;

  const HomeCollectionsSection({
    super.key,
    this.onCollectionTap,
    this.onViewAllTap,
  });

  static List<CollectionItem> get mockCollections => const [
        CollectionItem(
          id: '1',
          title: 'Romantik kecha',
          placesCount: '18 ta joy',
          imagePath: 'assets/images/onboarding_second.png',
        ),
        CollectionItem(
          id: '2',
          title: 'Do\'stlar bilan',
          placesCount: '24 ta joy',
          imagePath: 'assets/images/onboarding_third.png',
        ),
        CollectionItem(
          id: '3',
          title: 'Oila davrasida',
          placesCount: '15 ta joy',
          imagePath: 'assets/images/onboarding_fourth.png',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final collections = mockCollections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'To\'plamlar',
                style: GoogleFonts.unbounded(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Row(
                children: [
                  Text(
                    AppStrings.viewAll,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap(2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16.r,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap(14.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: collections.length,
            separatorBuilder: (context, index) => Gap(12.w),
            itemBuilder: (context, index) {
              final item = collections[index];

              return GestureDetector(
                onTap: () => onCollectionTap?.call(item),
                child: Container(
                  width: 150.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.w,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background Image with dark gradient overlay
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.asset(
                          item.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF3F4F6),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),

                      // Text Info
                      Positioned(
                        left: 10.w,
                        right: 10.w,
                        bottom: 10.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              item.placesCount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
