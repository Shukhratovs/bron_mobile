import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';
import '../../../venue_detail/presentation/widgets/booking_bottom_sheet.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/venue_model.dart';
import '../widgets/home_available_today_section.dart';
import '../widgets/home_banner_widget.dart';
import '../widgets/home_categories_widget.dart';
import '../widgets/home_collections_section.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_search_bar_widget.dart';
import '../widgets/venue_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CategoryModel> _categories = CategoryModel.mockCategories;
  final List<VenueModel> _venues = VenueModel.mockVenues;
  final BannerModel _banner = BannerModel.mockBanners.first;

  String _selectedCategoryId = 'restaurant';
  final Set<String> _favoriteVenueIds = {};

  void _onCategorySelected(String id) {
    setState(() {
      _selectedCategoryId = id;
    });
  }

  void _openVenueDetail(VenueModel venue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenueDetailScreen(venue: venue),
      ),
    );
  }

  void _openTimeSlotBooking(VenueModel venue, String time) {
    BookingBottomSheet.show(context, venue: venue, initialTime: time);
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteVenueIds.contains(id)) {
        _favoriteVenueIds.remove(id);
      } else {
        _favoriteVenueIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableVenues = _venues.where((v) => v.isAvailableToday).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: Logo, City Pill, Notification Bell
              HomeHeaderWidget(
                onCityTap: () {},
                onNotificationTap: () {},
              ),
              Gap(16.h),

              // 2. Search Bar & Filter Trigger
              HomeSearchBarWidget(
                onTap: () {},
                onFilterTap: () {},
              ),
              Gap(18.h),

              // 3. Category Selector Circles
              HomeCategoriesWidget(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: _onCategorySelected,
              ),
              Gap(16.h),

              // 4. Promo Banner
              HomeBannerWidget(
                banner: _banner,
                onTap: () {
                  if (_venues.isNotEmpty) {
                    _openVenueDetail(_venues.first);
                  }
                },
              ),
              Gap(24.h),

              // 5. Bugun 19:30 ga borish (Horizontal Scroll)
              HomeAvailableTodaySection(
                venues: availableVenues,
                onVenueTap: _openVenueDetail,
                onTimeSlotTap: _openTimeSlotBooking,
                onViewAllTap: () {},
              ),
              Gap(24.h),

              // 6. To'plamlar (Collections)
              HomeCollectionsSection(
                onCollectionTap: (collection) {},
                onViewAllTap: () {},
              ),
              Gap(24.h),

              // 7. Yaqin atrofda (Feed Section)
              Text(
                'Yaqin atrofda',
                style: GoogleFonts.unbounded(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(14.h),

              // Vertical List of Venue Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _venues.length,
                separatorBuilder: (context, index) => Gap(16.h),
                itemBuilder: (context, index) {
                  final venue = _venues[index];
                  final isFavorite = _favoriteVenueIds.contains(venue.id);

                  return VenueCardWidget(
                    venue: venue,
                    isFavorite: isFavorite,
                    onTap: () => _openVenueDetail(venue),
                    onTimeSlotTap: (time) => _openTimeSlotBooking(venue, time),
                    onFavoriteTap: () => _toggleFavorite(venue.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
