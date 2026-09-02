import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
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
          title: 'Osh joylari',
          placesCount: '12 ta joy',
          imagePath: AppAssets.onboardingSecond,
        ),
        CollectionItem(
          id: '2',
          title: 'Terasali',
          placesCount: '18 ta joy',
          imagePath: AppAssets.onboardingThird,
        ),
        CollectionItem(
          id: '3',
          title: 'Yangi ochilgan',
          placesCount: '6 ta joy',
          imagePath: AppAssets.onboardingFourth,
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
            Text(
              AppStrings.collections,
              style: GoogleFonts.unbounded(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF161616),
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                AppStrings.viewAll,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB12A0B),
                ),
              ),
            ),
          ],
        ),
        Gap(14.h),
        SizedBox(
          height: 112.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: collections.length,
            separatorBuilder: (context, index) => Gap(10.w),
            itemBuilder: (context, index) {
              final item = collections[index];
              return GestureDetector(
                onTap: () => onCollectionTap?.call(item),
                child: Container(
                  width: 148.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: const Color(0xFFF7F7F7),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: const Color(0xFFF7F7F7)),
                      ),
                      // Darkening gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                      // Text
                      Positioned(
                        left: 12.w,
                        right: 12.w,
                        bottom: 12.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Gap(2.h),
                            Text(
                              item.placesCount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.7),
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
