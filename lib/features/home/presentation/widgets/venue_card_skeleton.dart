import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';

/// Figma "6 · HOLATLAR → Yuklanmoqda" → "Skelet karta" bilan bir xil.
class VenueCardSkeleton extends StatelessWidget {
  const VenueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 180.h, radius: 0),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 190.w, height: 20.h),
                Gap(10.h),
                ShimmerBox(width: 250.w, height: 16.h),
                Gap(10.h),
                Row(
                  children: [
                    ShimmerBox.pill(width: 66.w, height: 36.h),
                    Gap(8.w),
                    ShimmerBox.pill(width: 66.w, height: 36.h),
                    Gap(8.w),
                    ShimmerBox.pill(width: 66.w, height: 36.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bir nechta karta skeleti — ro'yxat yuklanayotganda ko'rsatiladi.
class VenueListSkeleton extends StatelessWidget {
  final int count;

  const VenueListSkeleton({super.key, this.count = 2});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 18.h),
            child: const VenueCardSkeleton(),
          ),
        ),
      ),
    );
  }
}
