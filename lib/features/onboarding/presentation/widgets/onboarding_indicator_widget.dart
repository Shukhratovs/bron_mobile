import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingIndicatorWidget extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingIndicatorWidget({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (index) {
          final isCompleted = index <= currentIndex;
          return Expanded(
            child: Container(
              height: 2.5.h,
              margin: EdgeInsets.only(
                right: index == count - 1 ? 0 : 5.w,
              ),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.indicatorActive
                    : AppColors.indicatorInactive,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        },
      ),
    );
  }
}
