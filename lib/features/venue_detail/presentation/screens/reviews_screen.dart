import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/review_model.dart';

class ReviewsScreen extends StatelessWidget {
  final String venueName;
  final double rating;
  final int reviewsCount;
  final List<ReviewModel>? reviews;

  const ReviewsScreen({
    super.key,
    required this.venueName,
    this.rating = 4.8,
    this.reviewsCount = 124,
    this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final list = reviews ?? ReviewModel.mockReviews;

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
        title: Text(
          'Sharhlar',
          style: GoogleFonts.unbounded(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  // Large Rating Box
                  Column(
                    children: [
                      Text(
                        rating.toString(),
                        style: GoogleFonts.unbounded(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 16.r,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        '$reviewsCount sharh',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Gap(20.w),

                  // Progress Bars for 5, 4, 3, 2, 1 Stars
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 0.85),
                        _buildRatingBar(4, 0.10),
                        _buildRatingBar(3, 0.03),
                        _buildRatingBar(2, 0.01),
                        _buildRatingBar(1, 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(24.h),

            // Section Title
            Text(
              'Foydalanuvchilar fikri',
              style: GoogleFonts.unbounded(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Gap(12.h),

            // Review Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => Gap(12.h),
              itemBuilder: (context, index) {
                final review = list[index];

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16.r,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                child: Text(
                                  review.authorName.isNotEmpty
                                      ? review.authorName[0]
                                      : 'U',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Gap(10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.authorName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    review.date,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16.r,
                              ),
                              Gap(2.w),
                              Text(
                                review.rating.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gap(10.h),
                      Text(
                        review.comment,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: const Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(6.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 5.h,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
