import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/datasources/review_remote_data_source.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';

/// `GET /venues/{id}/reviews` — mijoz/00-kirish-va-profil.md §"Sharhlar"
/// (jonli OpenAPI'da endi mavjud, statik hujjatda ❌ deb belgilangan edi).
class ReviewsScreen extends StatefulWidget {
  final String venueId;
  final String venueName;
  final double rating;
  final int reviewsCount;
  final ReviewRepository? repository;

  const ReviewsScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    this.rating = 0,
    this.reviewsCount = 0,
    this.repository,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewRepository _repository;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        ReviewRepositoryImpl(remoteDataSource: ReviewRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _repository.getVenueReviews(widget.venueId, limit: 50);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _reviews = data.items;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftSLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.reviews,
          style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: _isLoading
          ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 5, leadingIsCircle: true))
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator.adaptive(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(),
                        Gap(24.h),
                        Text(
                          AppStrings.userReviews,
                          style: GoogleFonts.unbounded(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Gap(12.h),
                        if (_reviews.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child: Center(
                              child: Text(
                                AppStrings.noReviewsYet,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length,
                            separatorBuilder: (context, index) => Gap(12.h),
                            itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
                          ),
                      ],
                    ),
                  ),
                ),
    );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(AppAssets.iconErrorWarningLine, size: 48.r, color: AppColors.textMuted),
            Gap(12.h),
            Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary)),
            Gap(16.h),
            TextButton(onPressed: _load, child: Text(AppStrings.retry)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      counts[r.rating] = (counts[r.rating] ?? 0) + 1;
    }
    final total = _reviews.isNotEmpty ? _reviews.length : widget.reviewsCount;
    final avg = _reviews.isNotEmpty
        ? _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length
        : widget.rating;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(avg.toStringAsFixed(1), style: GoogleFonts.unbounded(fontSize: 36.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(children: List.generate(5, (i) => AppIcon(AppAssets.iconStar, size: 16.r, color: Colors.amber))),
              Gap(4.h),
              Text('$total ${AppStrings.reviewCount}', style: GoogleFonts.plusJakartaSans(fontSize: 11.5.sp, color: AppColors.textSecondary)),
            ],
          ),
          Gap(20.w),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1]
                  .map((stars) => _buildRatingBar(stars, total > 0 ? (counts[stars] ?? 0) / total : 0))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      review.authorName.isNotEmpty ? review.authorName[0] : 'M',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                  Gap(10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.authorName, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(formatDateLong(review.createdAt.toLocal()), style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  AppIcon(AppAssets.iconStar, color: Colors.amber, size: 16.r),
                  Gap(2.w),
                  Text('${review.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          if (review.text != null && review.text!.isNotEmpty) ...[
            Gap(10.h),
            Text(review.text!, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF374151), height: 1.4)),
          ],
          if (review.replyText != null && review.replyText!.isNotEmpty) ...[
            Gap(10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.venueReply, style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  Gap(4.h),
                  Text(review.replyText!, style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: const Color(0xFF374151), height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text('$stars', style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: AppColors.textSecondary)),
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
