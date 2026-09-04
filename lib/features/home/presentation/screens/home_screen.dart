import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
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
import '../../../main/presentation/widgets/custom_bottom_nav_bar.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_available_today_section.dart';
import '../widgets/home_banner_widget.dart';
import '../widgets/home_categories_widget.dart';
import '../widgets/home_collections_section.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/venue_card_skeleton.dart';
import '../widgets/venue_card_widget.dart';

class HomeScreen extends StatefulWidget {
  final VenueRepository? repository;

  const HomeScreen({super.key, this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;
  final List<CategoryModel> _categories = CategoryModel.categories;
  final BannerModel _banner = BannerModel.mockBanners.first;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    final repo = widget.repository ??
        VenueRepositoryImpl(
          remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _homeBloc = HomeBloc(venueRepository: repo)..add(const HomeLoadRequested());
    _scrollController.addListener(_onScroll);
    AppSession.favorites.idsListenable.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _homeBloc.close();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    AppSession.favorites.idsListenable.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 10;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  void _onCategorySelected(String id) {
    _homeBloc.add(HomeCategorySelected(id));
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
    AppSession.favorites.toggle(id);
  }

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _openFilters() async {
    final currentFilters = _homeBloc.state.filters;
    final result = await FiltrlarScreen.show(
      context,
      initial: currentFilters,
      selectedKind: _homeBloc.state.selectedKind ?? currentFilters.kind,
    );
    if (result != null) {
      _homeBloc.add(HomeFiltersChanged(result));
    }
  }

  Future<void> _showFcmToken() async {
    final token = await AppSession.pushService.getToken();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FCM token (test)'),
        content: SelectableText(token ?? 'Token topilmadi'),
        actions: [
          TextButton(
            onPressed: () {
              if (token != null) Clipboard.setData(ClipboardData(text: token));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Token nusxalandi')),
              );
            },
            child: const Text('Nusxalash'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
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
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, langState) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F7),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: kDebugMode
                ? FloatingActionButton.small(
                    heroTag: 'fcm_token_debug_fab',
                    onPressed: _showFcmToken,
                    child: const Icon(Icons.bug_report_outlined),
                  )
                : null,
            body: Column(
              children: [
                // Fixed header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(_isScrolled ? 0 : 28.r),
                    ),
                    boxShadow: _isScrolled
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: HomeHeaderWidget(
                      onNotificationTap: _openNotifications,
                      onSearchTap: _openSearch,
                      onFilterTap: _openFilters,
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    bloc: _homeBloc,
                    builder: (context, state) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async {
                          _homeBloc.add(const HomeLoadRequested());
                          await _homeBloc.stream.firstWhere(
                            (s) => s.status != HomeStatus.loading,
                          );
                        },
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(16.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: state.status == HomeStatus.loading && state.venues.isEmpty
                                    ? _buildShimmerContent()
                                    : _buildContent(state),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerContent() {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (_) => Column(
                children: [
                  ShimmerBox(width: 56.r, height: 56.r, radius: 999),
                  Gap(8.h),
                  ShimmerBox(width: 48.w, height: 12.h, radius: 4),
                ],
              ),
            ),
          ),
          Gap(16.h),
          ShimmerBox(width: double.infinity, height: 84.h, radius: 20),
          Gap(24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 160.w, height: 18.h),
              ShimmerBox(width: 60.w, height: 16.h),
            ],
          ),
          Gap(14.h),
          SizedBox(
            height: 214.h,
            child: Row(
              children: [
                Expanded(child: _buildSmallCardSkeleton()),
                Gap(12.w),
                Expanded(child: _buildSmallCardSkeleton()),
              ],
            ),
          ),
          Gap(24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 100.w, height: 18.h),
              ShimmerBox(width: 60.w, height: 16.h),
            ],
          ),
          Gap(14.h),
          SizedBox(
            height: 112.h,
            child: Row(
              children: [
                Expanded(child: ShimmerBox(width: double.infinity, height: 112.h, radius: 16)),
                Gap(10.w),
                Expanded(child: ShimmerBox(width: double.infinity, height: 112.h, radius: 16)),
              ],
            ),
          ),
          Gap(24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 130.w, height: 18.h),
              ShimmerBox(width: 60.w, height: 16.h),
            ],
          ),
          Gap(14.h),
          const VenueCardSkeleton(),
          Gap(14.h),
          const VenueCardSkeleton(),
          Gap(CustomBottomNavBar.reservedBottomSpace(context)),
        ],
      ),
    );
  }

  Widget _buildSmallCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 110.h, radius: 0),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140.w, height: 16.h),
                Gap(8.h),
                ShimmerBox(width: 100.w, height: 12.h),
                Gap(8.h),
                Row(
                  children: [
                    ShimmerBox.pill(width: 50.w, height: 28.h),
                    Gap(6.w),
                    ShimmerBox.pill(width: 50.w, height: 28.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeCategoriesWidget(
          categories: _categories,
          selectedCategoryId: state.selectedKind ?? '',
          onCategorySelected: _onCategorySelected,
        ),
        Gap(16.h),
        HomeBannerWidget(
          banner: _banner,
          onTap: () {
            if (state.venues.isNotEmpty) _openVenueDetail(state.venues.first);
          },
        ),
        Gap(24.h),
        HomeAvailableTodaySection(
          venues: state.todayVenues,
          onVenueTap: _openVenueDetail,
          onTimeSlotTap: _openTimeSlotBooking,
          onViewAllTap: _openSearch,
        ),
        if (state.todayVenues.isNotEmpty) Gap(24.h),
        HomeCollectionsSection(
          onCollectionTap: (collection) {},
          onViewAllTap: () {},
        ),
        Gap(24.h),

        // Yaqin atrofda
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.nearMe,
              style: GoogleFonts.unbounded(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF161616),
              ),
            ),
            GestureDetector(
              onTap: _openSearch,
              child: Text(
                AppStrings.viewAll,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB12A0B),
                ),
              ),
            ),
          ],
        ),
        Gap(14.h),

        if (state.errorMessage != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: state.isOffline
                ? AppStateView.noInternet(onRetry: () => _homeBloc.add(const HomeLoadRequested()))
                : AppStateView.error(
                    description: state.errorMessage,
                    onRetry: () => _homeBloc.add(const HomeLoadRequested()),
                  ),
          )
        else if (state.venues.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: AppStateView.empty(icon: Icons.storefront_outlined),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: state.venues.length,
                  itemBuilder: (context, index) {
                    final venue = state.venues[index];
                    final isFavorite = AppSession.favorites.isFavorite(venue.id);
                    return VenueCardWidget(
                      venue: venue,
                      isFavorite: isFavorite,
                      onTap: () => _openVenueDetail(venue),
                      onTimeSlotTap: (time) => _openTimeSlotBooking(venue, time),
                      onFavoriteTap: () => _toggleFavorite(venue.id),
                    );
                  },
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.venues.length,
                separatorBuilder: (context, index) => Gap(14.h),
                itemBuilder: (context, index) {
                  final venue = state.venues[index];
                  final isFavorite = AppSession.favorites.isFavorite(venue.id);
                  return VenueCardWidget(
                    venue: venue,
                    isFavorite: isFavorite,
                    onTap: () => _openVenueDetail(venue),
                    onTimeSlotTap: (time) => _openTimeSlotBooking(venue, time),
                    onFavoriteTap: () => _toggleFavorite(venue.id),
                  );
                },
              );
            },
          ),

        Gap(CustomBottomNavBar.reservedBottomSpace(context)/3),
      ],
    );
  }
}
