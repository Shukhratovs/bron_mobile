import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/presentation/screens/notifications_screen.dart';
import '../../../search/presentation/screens/filtrlar_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../venue_detail/presentation/screens/vaqt_tanlash_screen.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../domain/venue_filters.dart';
import '../widgets/home_available_today_section.dart';
import '../widgets/home_banner_widget.dart';
import '../widgets/home_categories_widget.dart';
import '../widgets/home_collections_section.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_search_bar_widget.dart';
import '../widgets/venue_card_skeleton.dart';
import '../widgets/venue_card_widget.dart';

class HomeScreen extends StatefulWidget {
  final VenueRepository? repository;

  const HomeScreen({super.key, this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final VenueRepository _repository;
  final List<CategoryModel> _categories = CategoryModel.categories;
  final BannerModel _banner = BannerModel.mockBanners.first;

  String? _selectedKind;
  VenueFilters _filters = const VenueFilters();
  final Set<String> _favoriteVenueIds = {};

  List<VenueEntity> _venues = [];
  List<VenueEntity> _todayVenues = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final today = DateTime.now();
    final dateParam = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      _repository.getVenues(
        kind: _selectedKind ?? _filters.kind,
        district: _filters.district,
        cuisine: _filters.cuisine,
        check: _filters.check,
        ratingMin: _filters.ratingMin,
        sort: _filters.sort == 'yaqin' ? null : _filters.sort,
        limit: 20,
      ),
      _repository.getVenues(kind: 'restoran', date: dateParam, guests: 2, limit: 6),
    ]);
    if (!mounted) return;

    final listResult = results[0];
    final todayResult = results[1];

    switch (listResult) {
      case Success(:final data):
        setState(() {
          _venues = data.items;
          _isLoading = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
    if (todayResult case Success(:final data)) {
      setState(() => _todayVenues = data.items);
    }
  }

  void _onCategorySelected(String id) {
    setState(() {
      _selectedKind = _selectedKind == id ? null : id;
    });
    _load();
  }

  void _openVenueDetail(VenueEntity venue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VenueDetailScreen(venueId: venue.id)),
    );
  }

  void _openTimeSlotBooking(VenueEntity venue, String time) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VaqtTanlashScreen(venue: venue, initialTime: time)),
    );
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

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _openFilters() async {
    final result = await Navigator.push<VenueFilters>(
      context,
      MaterialPageRoute(builder: (context) => FiltrlarScreen(initial: _filters)),
    );
    if (result != null) {
      setState(() => _filters = result);
      _load();
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          repository: ProfileRepositoryImpl(
            remoteDataSource: ProfileRemoteDataSourceImpl(apiClient: AppSession.apiClient),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header: Logo, City Pill, Notification Bell
                HomeHeaderWidget(
                  onCityTap: () {},
                  onNotificationTap: _openNotifications,
                ),
                Gap(16.h),

                // 2. Search Bar & Filter Trigger
                HomeSearchBarWidget(
                  onTap: _openSearch,
                  onFilterTap: _openFilters,
                ),
                Gap(18.h),

                // 3. Category Selector Circles
                HomeCategoriesWidget(
                  categories: _categories,
                  selectedCategoryId: _selectedKind ?? '',
                  onCategorySelected: _onCategorySelected,
                ),
                Gap(16.h),

                // 4. Promo Banner
                HomeBannerWidget(
                  banner: _banner,
                  onTap: () {
                    if (_venues.isNotEmpty) _openVenueDetail(_venues.first);
                  },
                ),
                Gap(24.h),

                // 5. Bugun bo'sh joylar (Horizontal Scroll)
                HomeAvailableTodaySection(
                  venues: _todayVenues,
                  onVenueTap: _openVenueDetail,
                  onTimeSlotTap: _openTimeSlotBooking,
                  onViewAllTap: _openSearch,
                ),
                if (_todayVenues.isNotEmpty) Gap(24.h),

                // 6. To'plamlar (Collections) — kontent moduli hali yo'q
                HomeCollectionsSection(
                  onCollectionTap: (collection) {},
                  onViewAllTap: () {},
                ),
                Gap(24.h),

                // 7. Katalog (Feed Section)
                Text(
                  'Yaqin atrofda',
                  style: GoogleFonts.unbounded(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Gap(14.h),

                if (_isLoading)
                  const VenueListSkeleton()
                else if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else if (_venues.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'Bu bo\'yicha muassasa topilmadi',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
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
      ),
    );
  }
}
