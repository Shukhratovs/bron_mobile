import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/bron_logo.dart';
import '../../../profile/presentation/screens/notifications_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/models/venue_model.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../venue/venue_kind.dart';
import '../../../venue_detail/presentation/screens/venue_detail_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class MapScreen extends StatefulWidget {
  final VenueRepository? repository;

  const MapScreen({super.key, this.repository});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final VenueRepository _repository;
  late final MapController _mapController;
  late final PageController _pageController;

  List<VenueMapPin> _pins = [];
  final Map<String, VenueEntity> _detailCache = {};
  int _selectedVenueIndex = 0;
  bool _isLoading = true;
  String? _selectedKind;

  static const _fallbackCenter = LatLng(41.314581, 69.237562);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _mapController = MapController();
    _pageController = PageController(viewportFraction: 0.62);
    _loadPins();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPins() async {
    setState(() => _isLoading = true);
    final result = await _repository.getVenuesMap(kind: _selectedKind);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _pins = data;
          _selectedVenueIndex = 0;
          _isLoading = false;
        });
        if (data.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(LatLng(data.first.lat, data.first.lon), 15.5);
          });
          _ensureDetail(data.first.id);
        }
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  Future<void> _ensureDetail(String venueId) async {
    if (_detailCache.containsKey(venueId)) return;
    final result = await _repository.getVenueById(venueId);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() => _detailCache[venueId] = data);
    }
  }

  void _onVenueSelected(int index) {
    if (_selectedVenueIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _selectedVenueIndex = index);
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      _mapController.move(LatLng(_pins[index].lat, _pins[index].lon), 15.5);
      _ensureDetail(_pins[index].id);
    }
  }

  void _onPageChanged(int index) {
    if (_selectedVenueIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _selectedVenueIndex = index);
      _mapController.move(LatLng(_pins[index].lat, _pins[index].lon), 15.5);
      _ensureDetail(_pins[index].id);
    }
  }

  void _openVenueDetail(String venueId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VenueDetailScreen(venueId: venueId)),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
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
                'Yo\'nalish',
                style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20)),
              ),
              Gap(14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ChoiceChip(
                    label: const Text('Barchasi'),
                    selected: _selectedKind == null,
                    onSelected: (_) {
                      Navigator.pop(context);
                      setState(() => _selectedKind = null);
                      _loadPins();
                    },
                  ),
                  ...venueKindOptions.map((k) => ChoiceChip(
                        label: Text(k.$2),
                        selected: _selectedKind == k.$1,
                        onSelected: (_) {
                          Navigator.pop(context);
                          setState(() => _selectedKind = k.$1);
                          _loadPins();
                        },
                      )),
                ],
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pins.isNotEmpty ? LatLng(_pins.first.lat, _pins.first.lon) : _fallbackCenter,
              initialZoom: 15.5,
              minZoom: 12.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.bron.bron_mobile',
                maxZoom: 18,
              ),
              MarkerLayer(
                markers: List.generate(_pins.length, (index) {
                  final pin = _pins[index];
                  final isSelected = index == _selectedVenueIndex;
                  return Marker(
                    point: LatLng(pin.lat, pin.lon),
                    width: isSelected ? 52.r : 44.r,
                    height: isSelected ? 60.r : 50.r,
                    child: _BronMapPin(isSelected: isSelected, onTap: () => _onVenueSelected(index)),
                  );
                }),
              ),
            ],
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // 2. Floating Top Header Capsule
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 70.h, 16.w, 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BronLogo(width: 84.w, height: 32.h, isDarkText: true),
                  Row(
                    children: [
                      _buildHeaderIconButton(icon: Icons.search_rounded, onTap: _openSearch),
                      Gap(8.w),
                      Stack(
                        children: [
                          _buildHeaderIconButton(icon: Icons.tune_rounded, onTap: _showFilterModal),
                          if (_selectedKind != null)
                            Positioned(
                              right: 8.w,
                              top: 8.h,
                              child: Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(color: Color(0xFF181A20), shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      Gap(8.w),
                      _buildHeaderIconButton(icon: Icons.notifications_none_rounded, onTap: _openNotifications),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Floating Venue Cards Carousel
          if (_pins.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 100.h,
              child: SizedBox(
                height: 180.h,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pins.length,
                  itemBuilder: (context, index) {
                    final pin = _pins[index];
                    final detail = _detailCache[pin.id];
                    final isSelected = index == _selectedVenueIndex;

                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: isSelected ? 0 : 4.h),
                      child: GestureDetector(
                        onTap: () => _openVenueDetail(pin.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFDC3009) : const Color(0xFFECEFF3),
                              width: isSelected ? 1.5.w : 1.0.w,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 105.h,
                                width: double.infinity,
                                child: detail?.photoUrl != null
                                    ? Image.network(
                                        detail!.photoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: const Color(0xFFF3F4F6),
                                          child: const AppIcon(AppAssets.iconRestaurant, color: Color(0xFF9CA3AF)),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFFF3F4F6),
                                        child: const AppIcon(AppAssets.iconRestaurant, color: Color(0xFF9CA3AF)),
                                      ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pin.name,
                                            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (pin.rating != null)
                                          Row(
                                            children: [
                                              const AppIcon(AppAssets.iconStar, size: 16, color: Color(0xFFFF5222)),
                                              Gap(2.w),
                                              Text(
                                                pin.rating!.toStringAsFixed(1),
                                                style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20)),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    Gap(2.h),
                                    Text(
                                      [
                                        venueKindLabel(pin.kind),
                                        if (detail?.avgCheck != null) '~${formatSom(detail!.avgCheck!)}',
                                      ].join(' · '),
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: const Color(0xFF6B7280)),
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

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Icon(icon, size: 20.r, color: const Color(0xFF181A20)),
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
    final pinBgColor = isSelected ? const Color(0xFFDC3009) : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFFDC3009);
    final borderColor = isSelected ? Colors.white : const Color(0xFFDC3009);

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
              border: Border.all(color: borderColor, width: isSelected ? 2.5.w : 2.0.w),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Center(
              child: Text(
                'B',
                style: GoogleFonts.unbounded(fontSize: isSelected ? 17.sp : 13.sp, fontWeight: FontWeight.w800, color: textColor),
              ),
            ),
          ),
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
