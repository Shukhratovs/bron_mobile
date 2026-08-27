import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../home/data/models/venue_model.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';
import '../../domain/entities/favorite_place_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class FavoritesScreen extends StatefulWidget {
  final ProfileRepository repository;

  const FavoritesScreen({
    super.key,
    required this.repository,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoritePlaceEntity> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final result = await widget.repository.getFavoritePlaces();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _favorites = data.isNotEmpty ? data : _defaultFavorites;
          _isLoading = false;
        });
      case Failure():
        setState(() {
          _favorites = _defaultFavorites;
          _isLoading = false;
        });
    }
  }

  List<FavoritePlaceEntity> get _defaultFavorites => const [
        FavoritePlaceEntity(
          id: 'fav-1',
          name: 'Osteria Da Vinci',
          category: 'Yevropa · 1,2 km · ~120 ming so\'m',
          location: '1.2 km',
          rating: 4.8,
          reviewsCount: 124,
          imagePath: AppAssets.onboardingThird,
          averageCheck: '120 ming so\'m',
          isFavorite: true,
        ),
        FavoritePlaceEntity(
          id: 'fav-2',
          name: 'Bahor Choyxonasi',
          category: 'Milliy · 2,8 km · ~45 ming so\'m',
          location: '2.8 km',
          rating: 4.5,
          reviewsCount: 89,
          imagePath: AppAssets.onboardingFirst,
          averageCheck: '45 ming so\'m',
          isFavorite: true,
        ),
      ];

  List<String> _getSlotsForPlace(String name) {
    if (name.contains('Osteria')) {
      return ['19:00', '19:30', '20:00'];
    } else {
      return ['18:00', '18:30', '19:00'];
    }
  }

  String _getSubtitleForPlace(FavoritePlaceEntity place) {
    if (place.name.contains('Osteria')) {
      return 'Yevropa · 1,2 km · ~120 ming so\'m';
    } else if (place.name.contains('Bahor') || place.name.contains('Chorsu')) {
      return 'Milliy · 2,8 km · ~45 ming so\'m';
    }
    return place.category;
  }

  void _onVenueTap(FavoritePlaceEntity place) {
    final slots = _getSlotsForPlace(place.name);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VenueDetailScreen(
          venue: VenueModel(
            id: place.id,
            name: place.name,
            category: place.category,
            imagePath: place.imagePath,
            images: [place.imagePath],
            rating: place.rating,
            reviewsCount: place.reviewsCount,
            address: 'Toshkent shahar',
            distance: place.location,
            workingHours: '11:00 - 23:00',
            priceRange: place.averageCheck,
            availableTimeSlots: slots,
            description: place.name,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sevimlilar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF181A20),
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Subheader Counter
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                    child: Text(
                      '12 ta joy saqlangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),

                  // Favorite Places Cards
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _favorites.length,
                    separatorBuilder: (context, index) => Gap(14.h),
                    itemBuilder: (context, index) {
                      final place = _favorites[index];
                      return _buildPlaceCard(place);
                    },
                  ),
                  Gap(20.h),
                ],
              ),
            ),
    );
  }

  Widget _buildPlaceCard(FavoritePlaceEntity place) {
    final slots = _getSlotsForPlace(place.name);
    final subtitle = _getSubtitleForPlace(place);

    return GestureDetector(
      onTap: () => _onVenueTap(place),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFECEFF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            SizedBox(
              height: 185.h,
              width: double.infinity,
              child: Image.asset(
                place.imagePath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 48.r,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),

            // Card Body
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Title & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF181A20),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18.r,
                            color: const Color(0xFFFF5222),
                          ),
                          Gap(4.w),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF181A20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(4.h),

                  // Row 2: Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Gap(14.h),

                  // Row 3: Available Time Slot Chips
                  Row(
                    children: slots.map((time) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFECEFF3)),
                          ),
                          child: Text(
                            time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF181A20),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
