import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../core/widgets/app_button.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../data/datasources/review_remote_data_source.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import 'full_menu_screen.dart';
import 'reviews_screen.dart';
import 'vaqt_tanlash_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueId;
  final VenueRepository? repository;

  const VenueDetailScreen({
    super.key,
    required this.venueId,
    this.repository,
  });

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  late final VenueRepository _repository;
  late final ReviewRepository _reviewRepository;
  VenueEntity? _venue;
  ReviewModel? _topReview;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        VenueRepositoryImpl(
          remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _reviewRepository = ReviewRepositoryImpl(remoteDataSource: ReviewRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    AppSession.favorites.idsListenable.addListener(_onFavChanged);
    _load();
  }

  @override
  void dispose() {
    AppSession.favorites.idsListenable.removeListener(_onFavChanged);
    super.dispose();
  }

  void _onFavChanged() {
    if (mounted) setState(() {});
  }

  bool get _isFavorite => AppSession.favorites.isFavorite(widget.venueId);

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _repository.getVenueById(widget.venueId);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _venue = data;
          _isLoading = false;
        });
        if ((data.reviewsCount ?? 0) > 0) _loadTopReview();
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  Future<void> _loadTopReview() async {
    final result = await _reviewRepository.getVenueReviews(widget.venueId, limit: 1);
    if (!mounted) return;
    if (result case Success(:final data)) {
      if (data.items.isNotEmpty) setState(() => _topReview = data.items.first);
    }
  }

  void _openBookingFlow() {
    final venue = _venue;
    if (venue == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VaqtTanlashScreen(venue: venue)),
    );
  }

  void _openFullMenu() {
    final venue = _venue;
    if (venue == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullMenuScreen(venueId: venue.id, venueName: venue.name),
      ),
    );
  }

  void _openReviews() {
    final venue = _venue;
    if (venue == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsScreen(
          venueId: venue.id,
          venueName: venue.name,
          rating: venue.rating ?? 0,
          reviewsCount: venue.reviewsCount ?? 0,
        ),
      ),
    );
  }

  void _share() {
    final venue = _venue;
    if (venue == null) return;
    final text = '${venue.name}${venue.address != null ? ' • ${venue.address}' : ''}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.linkCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: DetailScreenSkeleton(),
      );
    }

    if (_errorMessage != null || _venue == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(AppAssets.iconErrorWarningLine, size: 56.r, color: AppColors.textMuted),
                Gap(12.h),
                Text(
                  _errorMessage ?? AppStrings.venueNotFound,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textSecondary),
                ),
                Gap(16.h),
                AppButton.primary(text: AppStrings.retry, onPressed: _load),
              ],
            ),
          ),
        ),
      );
    }

    final venue = _venue!;
    final popularMenu = venue.popularItems.take(3).toList();
    final topReview = _topReview;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image Header with Top Buttons
                Stack(
                  children: [
                    venue.photoUrl == null || venue.photoUrl!.isEmpty
                        ? Container(
                            width: double.infinity,
                            height: 280.h,
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: AppIcon(AppAssets.iconStore2Fill, size: 64, color: Colors.grey),
                            ),
                          )
                        : Image.network(
                            venue.photoUrl!,
                            width: double.infinity,
                            height: 280.h,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 280.h,
                              color: const Color(0xFFF3F4F6),
                              child: const Center(
                                child: AppIcon(AppAssets.iconStore2Fill, size: 64, color: Colors.grey),
                              ),
                            ),
                          ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            _buildSvgCircleButton(
                              svgPath: AppAssets.iconArrowLeftSLine,
                              onTap: () => Navigator.pop(context),
                            ),
                            Row(
                              children: [
                                _buildSvgCircleButton(
                                  svgPath: AppAssets.iconShareForwardLine,
                                  onTap: _share,
                                ),
                                Gap(10.w),
                                _buildSvgCircleButton(
                                  svgPath: _isFavorite
                                      ? AppAssets.iconHeartFill
                                      : AppAssets.iconHeartLine,
                                  color: _isFavorite
                                      ? AppColors.primary
                                      : const Color(0xFF1A1A1A),
                                  onTap: () => AppSession.favorites.toggle(widget.venueId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Main Venue Details Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              venue.name,
                              style: GoogleFonts.unbounded(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (venue.rating != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  AppIcon(
                                    AppAssets.iconStarFill,
                                    size: 16.r,
                                    color: AppColors.primary,
                                  ),
                                  Gap(3.w),
                                  Text(
                                    '${venue.rating!.toStringAsFixed(1)} (${venue.reviewsCount ?? 0})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Gap(12.h),

                      // Location & Hours
                      _buildSvgTextRow(
                        AppAssets.iconMapPinLine,
                        [
                          if (venue.address != null) venue.address!,
                          if (venue.hoursText != null) venue.hoursText!,
                        ].join(' • '),
                      ),
                      if (venue.avgCheck != null) ...[
                        Gap(6.h),
                        _buildSvgTextRow(
                          AppAssets.iconWallet3Line,
                          '~${formatSom(venue.avgCheck!)} / ${AppStrings.perPerson}',
                        ),
                      ],
                      Gap(16.h),

                      // Description
                      if (venue.description != null)
                        Text(
                          venue.description!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      Gap(24.h),

                      // 3. Menu / Services Preview
                      if (popularMenu.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.popularDishes,
                                style: GoogleFonts.unbounded(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openFullMenu,
                              child: Text(
                                '${AppStrings.fullMenu} >',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(12.h),
                        ...popularMenu.map(
                          (item) => Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (item.description != null) ...[
                                        Gap(2.h),
                                        Text(
                                          item.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5.sp,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Gap(10.w),
                                Text(
                                  formatSom(item.price),
                                  style: GoogleFonts.unbounded(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(20.h),
                      ],

                      // 4. Reviews Preview
                      if (venue.reviewsCount != null && venue.reviewsCount! > 0 && topReview != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppStrings.reviews,
                                style: GoogleFonts.unbounded(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openReviews,
                              child: Text(
                                '${AppStrings.viewAll} >',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(12.h),
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    topReview.authorName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      AppIcon(
                                        AppAssets.iconStarFill,
                                        size: 15.r,
                                        color: AppColors.primary,
                                      ),
                                      Gap(2.w),
                                      Text(
                                        topReview.rating.toString(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Gap(6.h),
                              Text(
                                topReview.text ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sticky Button Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AppButton.primary(
                  text: AppStrings.bookNow,
                  onPressed: _openBookingFlow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSvgCircleButton({
    required String svgPath,
    required VoidCallback onTap,
    Color color = const Color(0xFF1A1A1A),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: AppIcon(svgPath, size: 20.r, color: color),
        ),
      ),
    );
  }

  Widget _buildSvgTextRow(String svgPath, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        AppIcon(svgPath, size: 16.r, color: AppColors.textSecondary),
        Gap(8.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
