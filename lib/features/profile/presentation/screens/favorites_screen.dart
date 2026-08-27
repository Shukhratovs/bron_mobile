import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/custom_app_bar.dart';
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
          _favorites = data;
          _isLoading = false;
        });
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.myFavorites,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 64.r, color: AppColors.textMuted),
                      Gap(12.h),
                      Text(
                        AppStrings.noFavoritesFound,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: _favorites.length,
                  separatorBuilder: (context, index) => Gap(14.h),
                  itemBuilder: (context, index) {
                    final place = _favorites[index];
                    return _buildPlaceCard(place);
                  },
                ),
    );
  }

  Widget _buildPlaceCard(FavoritePlaceEntity place) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Heart badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: SizedBox(
                  height: 160.h,
                  width: double.infinity,
                  child: Image.asset(
                    place.imagePath,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primarySoft,
                      child: Icon(Icons.restaurant_rounded, size: 48.r, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12.w,
                top: 12.h,
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 20.r,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 18.r, color: AppColors.warning),
                        Gap(4.w),
                        Text(
                          '${place.rating} (${place.reviewsCount})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(4.h),
                Text(
                  place.category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Gap(4.h),
                Text(
                  place.location,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                Gap(14.h),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${place.name} sahifasiga o\'tilmoqda...'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 44.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(AppStrings.bookNow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
