import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

/// Figma "6 · HOLATLAR → Yuklanmoqda" skeleti bilan bir xil ranglar:
/// fon `bg/weak-50 #f7f7f7`, skelet to'ldirilishi `bg/soft-200 #ebebeb`.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  static const baseColor = Color(0xFFEBEBEB);
  static const highlightColor = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// Bitta skelet bloki — Figma'dagi "skelet" qatlamlari (to'ldirilgan
/// to'rtburchak, `bg/soft-200`, turli radius bilan).
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({super.key, required this.width, required this.height, this.radius = 6});

  const ShimmerBox.pill({super.key, required this.width, required this.height}) : radius = 999;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppShimmer.baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Umumiy ro'yxat qatori skeleti — bronlar, bildirishnomalar, sevimlilar,
/// kartalar kabi kartochka-ro'yxat ekranlari uchun (kvadrat rasm/ikonka +
/// ikki qator matn).
class ListRowSkeleton extends StatelessWidget {
  final bool leadingIsCircle;

  const ListRowSkeleton({super.key, this.leadingIsCircle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFECEFF3)),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 48.w, height: 48.w, radius: leadingIsCircle ? 999 : 12),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 160.w, height: 16.h),
                Gap(8.h),
                ShimmerBox(width: 100.w, height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Butun ekran tafsilot skeleti — hero rasm + sarlavha/qator matnlar
/// (muassasa/bron tafsilot ekranlari uchun).
class DetailScreenSkeleton extends StatelessWidget {
  final double heroHeight;

  const DetailScreenSkeleton({super.key, this.heroHeight = 280});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: double.infinity, height: heroHeight.h, radius: 0),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 220.w, height: 22.h),
                  Gap(10.h),
                  ShimmerBox(width: 150.w, height: 16.h),
                  Gap(20.h),
                  Row(
                    children: [
                      ShimmerBox.pill(width: 70.w, height: 32.h),
                      Gap(8.w),
                      ShimmerBox.pill(width: 70.w, height: 32.h),
                      Gap(8.w),
                      ShimmerBox.pill(width: 70.w, height: 32.h),
                    ],
                  ),
                  Gap(24.h),
                  ShimmerBox(width: double.infinity, height: 14.h),
                  Gap(10.h),
                  ShimmerBox(width: double.infinity, height: 14.h),
                  Gap(10.h),
                  ShimmerBox(width: 200.w, height: 14.h),
                  Gap(24.h),
                  ShimmerBox(width: double.infinity, height: 90.h, radius: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bir nechta ro'yxat-qator skeleti.
class ListRowSkeletonGroup extends StatelessWidget {
  final int count;
  final bool leadingIsCircle;

  const ListRowSkeletonGroup({super.key, this.count = 4, this.leadingIsCircle = false});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 10.h),
            child: ListRowSkeleton(leadingIsCircle: leadingIsCircle),
          ),
        ),
      ),
    );
  }
}
