import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/bron_logo.dart';
import '../../../home/data/models/venue_model.dart';
import '../../../profile/presentation/screens/notifications_screen.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';

class MapVenueItem {
  final VenueModel venue;
  final LatLng coordinate;

  const MapVenueItem({
    required this.venue,
    required this.coordinate,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late final PageController _pageController;
  int _selectedVenueIndex = 0;

  final List<MapVenueItem> _venues = [
    MapVenueItem(
      venue: const VenueModel(
        id: '1',
        name: 'Osteria Da Vinci',
        category: 'Restoran · Yevropa',
        imagePath: AppAssets.onboardingThird,
        images: [AppAssets.onboardingThird],
        rating: 4.8,
        reviewsCount: 124,
        address: 'Mustaqillik ko\'chasi 12',
        distance: '1,2 km',
        workingHours: 'Bugun: 11:00 - 23:00',
        priceRange: '~120 ming',
        availableTimeSlots: ['19:00', '19:30', '20:00'],
        description: 'Italyancha haqiqiy taomlar, qulay va romantik muhit.',
      ),
      coordinate: const LatLng(41.314581, 69.237562),
    ),
    MapVenueItem(
      venue: const VenueModel(
        id: '2',
        name: 'Chorsu Osh Markazi',
        category: 'Restoran · Milliy',
        imagePath: AppAssets.onboardingFirst,
        images: [AppAssets.onboardingFirst],
        rating: 4.6,
        reviewsCount: 340,
        address: 'Chorsu maydoni 1',
        distance: '3,4 km',
        workingHours: 'Bugun: 10:00 - 22:00',
        priceRange: '~45 ming',
        availableTimeSlots: ['12:00', '13:00', '18:00'],
        description: 'Milliy taomlar, afsonaviy toshkentcha osh va ajoyib mehmondo\'stlik.',
      ),
      coordinate: const LatLng(41.326581, 69.234562),
    ),
    MapVenueItem(
      venue: const VenueModel(
        id: '3',
        name: 'Besh Qozon',
        category: 'Milliy taomlar',
        imagePath: AppAssets.onboardingSecond,
        images: [AppAssets.onboardingSecond],
        rating: 4.9,
        reviewsCount: 420,
        address: 'Iftixor ko\'chasi 1',
        distance: '2,5 km',
        workingHours: 'Bugun: 10:00 - 22:00',
        priceRange: '~55 ming',
        availableTimeSlots: ['12:30', '13:30', '19:00'],
        description: 'Mashhur toshkentcha to\'y oshi va qazi-karta.',
      ),
      coordinate: const LatLng(41.311081, 69.252562),
    ),
    MapVenueItem(
      venue: const VenueModel(
        id: '4',
        name: 'Level Up Game Club',
        category: 'Geym klub · VIP',
        imagePath: AppAssets.onboardingThird,
        images: [AppAssets.onboardingThird],
        rating: 4.7,
        reviewsCount: 89,
        address: 'Bunyodkor ko\'chasi 15',
        distance: '3,1 km',
        workingHours: '24/7 Ochiq',
        priceRange: '~35 ming',
        availableTimeSlots: ['18:00', '19:00', '20:00'],
        description: 'Eng zamonaviy RTX 4080 o\'yin kompyuterlari va VIP xonalar.',
      ),
      coordinate: const LatLng(41.305081, 69.242562),
    ),
    MapVenueItem(
      venue: const VenueModel(
        id: '5',
        name: 'Barbershop No.1',
        category: 'Sartaroshxona',
        imagePath: AppAssets.onboardingFourth,
        images: [AppAssets.onboardingFourth],
        rating: 4.9,
        reviewsCount: 156,
        address: 'Amir Temur ko\'chasi 28',
        distance: '0,8 km',
        workingHours: 'Bugun: 09:00 - 21:00',
        priceRange: '~80 ming',
        availableTimeSlots: ['14:00', '15:00', '16:00'],
        description: 'Erkaklar uchun professional soch va soqol turmaklash.',
      ),
      coordinate: const LatLng(41.309081, 69.261562),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pageController = PageController(
      viewportFraction: 0.62,
      initialPage: _selectedVenueIndex,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onVenueSelected(int index) {
    if (_selectedVenueIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedVenueIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      _mapController.move(
        _venues[index].coordinate,
        15.5,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_selectedVenueIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedVenueIndex = index;
      });
      _mapController.move(
        _venues[index].coordinate,
        15.5,
      );
    }
  }

  void _openVenueDetail(VenueModel venue) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VenueDetailScreen(venue: venue),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),
              Text(
                'Filterlar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF181A20),
                ),
              ),
              Gap(14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: ['Barchasi', 'Restoranlar', 'Geym klublar', 'Go\'zallik', 'Kafelar']
                    .map((cat) => Chip(
                          label: Text(cat),
                          backgroundColor: const Color(0xFFF9FAFB),
                        ))
                    .toList(),
              ),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2024),
      body: Stack(
        children: [
          // 1. FlutterMap with Satellite Tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _venues.first.coordinate,
              initialZoom: 15.5,
              minZoom: 12.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Satellite Tile Layer (ArcGIS / Satellite Streets)
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.bron.bron_mobile',
                maxZoom: 18,
              ),

              // Markers Layer
              MarkerLayer(
                markers: List.generate(_venues.length, (index) {
                  final item = _venues[index];
                  final isSelected = index == _selectedVenueIndex;

                  return Marker(
                    point: item.coordinate,
                    width: isSelected ? 52.r : 44.r,
                    height: isSelected ? 60.r : 50.r,
                    child: _BronMapPin(
                      isSelected: isSelected,
                      onTap: () => _onVenueSelected(index),
                    ),
                  );
                }),
              ),
            ],
          ),

          // 2. Floating Top Header Capsule (Matching Figma)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bron Brand Logo
                  BronLogo(
                    width: 84.w,
                    height: 32.h,
                    isDarkText: true,
                  ),

                  // Action Icons
                  Row(
                    children: [
                      // Search Button
                      _buildHeaderIconButton(
                        icon: Icons.search_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Qidiruv paneli ochilmoqda...'),
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                      Gap(8.w),

                      // Filter Button with Black Dot Indicator
                      Stack(
                        children: [
                          _buildHeaderIconButton(
                            icon: Icons.tune_rounded,
                            onTap: _showFilterModal,
                          ),
                          Positioned(
                            right: 8.w,
                            top: 8.h,
                            child: Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFF181A20),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(8.w),

                      // Notification Bell Button
                      _buildHeaderIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: _openNotifications,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Floating Venue Cards Carousel
          Positioned(
            left: 0,
            right: 0,
            bottom: 100.h, // Floats right above Liquid Glass Navigation Bar
            child: SizedBox(
              height: 180.h,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _venues.length,
                itemBuilder: (context, index) {
                  final venueItem = _venues[index];
                  final isSelected = index == _selectedVenueIndex;

                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: isSelected ? 0 : 4.h,
                    ),
                    child: GestureDetector(
                      onTap: () => _openVenueDetail(venueItem.venue),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFDC3009)
                                : const Color(0xFFECEFF3),
                            width: isSelected ? 1.5.w : 1.0.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Venue Image
                            SizedBox(
                              height: 105.h,
                              width: double.infinity,
                              child: Image.asset(
                                venueItem.venue.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),

                            // Venue Details Body
                            Padding(
                              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title & Rating
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          venueItem.venue.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF181A20),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: Color(0xFFFF5222),
                                          ),
                                          Gap(2.w),
                                          Text(
                                            venueItem.venue.rating
                                                .toStringAsFixed(1),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF181A20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Gap(2.h),

                                  // Subtitle / Distance
                                  Text(
                                    '${venueItem.venue.distance} · ${venueItem.venue.priceRange}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.r,
          color: const Color(0xFF181A20),
        ),
      ),
    );
  }
}

class _BronMapPin extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;

  const _BronMapPin({
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pinSize = isSelected ? 44.r : 34.r;
    final pinBgColor =
        isSelected ? const Color(0xFFDC3009) : Colors.white;
    final textColor =
        isSelected ? Colors.white : const Color(0xFFDC3009);
    final borderColor =
        isSelected ? Colors.white : const Color(0xFFDC3009);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: pinSize,
            height: pinSize,
            decoration: BoxDecoration(
              color: pinBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.5.w : 2.0.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'B',
                style: GoogleFonts.unbounded(
                  fontSize: isSelected ? 17.sp : 13.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),
          // Pointer Triangle
          ClipPath(
            clipper: _TriangleClipper(),
            child: Container(
              width: isSelected ? 10.w : 8.w,
              height: isSelected ? 6.h : 5.h,
              color: const Color(0xFFDC3009),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
