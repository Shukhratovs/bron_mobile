import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../home/presentation/widgets/venue_card_skeleton.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../venue_detail/presentation/screens/vaqt_tanlash_screen.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VenueRepository? venueRepository;

  const FavoritesScreen({
    super.key,
    this.venueRepository,
    // ignore old parameter
    dynamic repository,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final VenueRepository _venueRepository;
  List<VenueEntity> _venues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _venueRepository = widget.venueRepository ??
        VenueRepositoryImpl(
          remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final favoriteIds = AppSession.favorites.ids;
    if (favoriteIds.isEmpty) {
      setState(() {
        _venues = [];
        _isLoading = false;
      });
      return;
    }

    // Har bir favorite venue'ni API'dan yuklaymiz
    final loaded = <VenueEntity>[];
    for (final id in favoriteIds) {
      final result = await _venueRepository.getVenueById(id);
      if (result case Success(:final data)) {
        loaded.add(data);
      }
    }
    if (!mounted) return;

    setState(() {
      _venues = loaded;
      _isLoading = false;
    });
  }

  void _onVenueTap(VenueEntity venue) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VenueDetailScreen(venueId: venue.id),
      ),
    );
    if (mounted) _loadFavorites();
  }

  void _onTimeSlotTap(VenueEntity venue, String time) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VaqtTanlashScreen(venue: venue, initialTime: time),
      ),
    );
  }

  Future<void> _toggleFavorite(VenueEntity venue) async {
    await AppSession.favorites.toggle(venue.id);
    if (mounted) {
      setState(() {
        _venues.removeWhere((v) => v.id == venue.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftLine, color: Color(0xFF161616)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.myFavorites,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? Padding(
              padding: EdgeInsets.all(16.w),
              child: const AppShimmer(child: VenueCardSkeleton()),
            )
          : _venues.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: _venues.length + 1,
                    separatorBuilder: (context, index) => Gap(14.h),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(left: 4.w, bottom: 0),
                          child: Text(
                            '${_venues.length} ta joy saqlangan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF5C5C5C),
                            ),
                          ),
                        );
                      }
                      final venue = _venues[index - 1];
                      return _FavoriteVenueCard(
                        venue: venue,
                        onTap: () => _onVenueTap(venue),
                        onTimeSlotTap: (time) => _onTimeSlotTap(venue, time),
                        onFavoriteTap: () => _toggleFavorite(venue),
                      );
                    },
                  ),
                ),
    );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            AppAssets.iconHeartLine,
            size: 48.r,
            color: AppColors.textMuted,
          ),
          Gap(16.h),
          Text(
            AppStrings.noFavoritesFound,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF161616),
            ),
          ),
          Gap(8.h),
          Text(
            'Yoqtirgan joylarni ♥ bosib saqlang',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: const Color(0xFF5C5C5C),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteVenueCard extends StatelessWidget {
  final VenueEntity venue;
  final VoidCallback? onTap;
  final Function(String time)? onTimeSlotTap;
  final VoidCallback? onFavoriteTap;

  const _FavoriteVenueCard({
    required this.venue,
    this.onTap,
    this.onTimeSlotTap,
    this.onFavoriteTap,
  });

  String get _subtitle {
    final parts = <String>[
      if (venue.cuisine != null && venue.cuisine!.isNotEmpty) venue.cuisine!,
      if (venue.district != null && venue.district!.isNotEmpty) venue.district!,
      if (venue.avgCheck != null) '~${_formatCheck(venue.avgCheck!)}',
    ];
    return parts.join(' · ');
  }

  String _formatCheck(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer so\'m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: _buildImage(),
                ),
                // Favorite heart (always filled)
                Positioned(
                  right: 12.w,
                  top: 12.h,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppIcon(
                          AppAssets.iconHeartFill,
                          size: 18.r,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF161616),
                          ),
                        ),
                      ),
                      if (venue.rating != null) ...[
                        Gap(8.w),
                        AppIcon(
                          AppAssets.iconStarFill,
                          size: 16.r,
                          color: AppColors.primary,
                        ),
                        Gap(4.w),
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF161616),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_subtitle.isNotEmpty) ...[
                    Gap(4.h),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C5C5C),
                      ),
                    ),
                  ],
                  // Time slots
                  if (venue.freeSlots.isNotEmpty) ...[
                    Gap(10.h),
                    Row(
                      children: venue.freeSlots.take(4).map(
                        (time) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: GestureDetector(
                            onTap: () => onTimeSlotTap?.call(time),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(color: const Color(0xFFEAEAEA)),
                              ),
                              child: Text(
                                time,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF161616),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (venue.photoUrl == null || venue.photoUrl!.isEmpty) {
      return Container(
        height: 180.h,
        width: double.infinity,
        color: const Color(0xFFFFF2EF),
        child: Center(
          child: AppIcon(
            AppAssets.iconImageLine,
            size: 48.r,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return Image.network(
      venue.photoUrl!,
      height: 180.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 180.h,
        width: double.infinity,
        color: const Color(0xFFFFF2EF),
        child: Center(
          child: AppIcon(
            AppAssets.iconImageLine,
            size: 48.r,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
