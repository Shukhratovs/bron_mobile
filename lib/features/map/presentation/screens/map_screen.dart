import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_icon.dart';
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

class MapScreen extends StatefulWidget {
  final VenueRepository? repository;

  const MapScreen({super.key, this.repository});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final VenueRepository _repository;
  late final PageController _pageController;
  YandexMapController? _mapController;

  List<VenueMapPin> _pins = [];
  final Map<String, VenueEntity> _detailCache = {};
  int _selectedVenueIndex = 0;
  bool _isLoading = true;
  bool _mapReady = false;
  bool _mapError = false;
  String? _selectedKind;

  // Pin image caches
  Uint8List? _pinNormal;
  Uint8List? _pinSelected;
  Uint8List? _userLocationIcon;

  // Tashkent center
  static const _fallbackCenter = Point(latitude: 41.314581, longitude: 69.237562);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _pageController = PageController(viewportFraction: 0.62);
    _preparePinImages();
    _loadPins();
    // Delay map creation slightly to avoid OpenGL init crash
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _mapReady = true);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Pin image generation ──────────────────────────────────────────

  Future<void> _preparePinImages() async {
    _pinNormal = await _renderPinImage(false);
    _pinSelected = await _renderPinImage(true);
    _userLocationIcon = await _renderUserDot();
    if (mounted) setState(() {});
  }

  Future<Uint8List> _renderPinImage(bool isSelected) async {
    final double circleSize = isSelected ? 52.0 : 40.0;
    final double totalW = circleSize;
    final double triangleH = 8.0;
    final double totalH = circleSize + triangleH;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, totalW, totalH));

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(totalW / 2, circleSize / 2 + 2), circleSize / 2 - 2, shadowPaint);

    // Circle fill
    final fillPaint = Paint()..color = isSelected ? const Color(0xFFDC3009) : Colors.white;
    canvas.drawCircle(Offset(totalW / 2, circleSize / 2), circleSize / 2 - 1, fillPaint);

    // Circle border
    final borderPaint = Paint()
      ..color = isSelected ? Colors.white : const Color(0xFFDC3009)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 2.5;
    canvas.drawCircle(Offset(totalW / 2, circleSize / 2), circleSize / 2 - 2, borderPaint);

    // "B" text
    final textColor = isSelected ? Colors.white : const Color(0xFFDC3009);
    final fontSize = isSelected ? 22.0 : 17.0;
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
    ))
      ..pushStyle(ui.TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: fontSize))
      ..addText('B');
    final paragraph = paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: totalW));
    canvas.drawParagraph(paragraph, Offset(0, (circleSize - paragraph.height) / 2));

    // Triangle pointer
    final triPaint = Paint()..color = const Color(0xFFDC3009);
    final triPath = Path()
      ..moveTo(totalW / 2 - 6, circleSize - 2)
      ..lineTo(totalW / 2 + 6, circleSize - 2)
      ..lineTo(totalW / 2, circleSize + triangleH - 1)
      ..close();
    canvas.drawPath(triPath, triPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(totalW.toInt(), totalH.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _renderUserDot() async {
    const double size = 32.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

    // Outer glow
    final glowPaint = Paint()..color = const Color(0xFFDC3009).withValues(alpha: 0.2);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, glowPaint);

    // White ring
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(size / 2, size / 2), 8, whitePaint);

    // Blue dot
    final dotPaint = Paint()..color = const Color(0xFFDC3009);
    canvas.drawCircle(const Offset(size / 2, size / 2), 6, dotPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ─── Location ──────────────────────────────────────────────────────

  Future<void> _goToUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: position.latitude, longitude: position.longitude),
            zoom: 15.5,
          ),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.8),
      );
    } catch (_) {
      // Location unavailable — stay at current position
    }
  }

  // ─── Data loading ──────────────────────────────────────────────────

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
            _mapController?.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: Point(latitude: data.first.lat, longitude: data.first.lon), zoom: 15.5),
              ),
              animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
            );
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

  // ─── Interactions ──────────────────────────────────────────────────

  void _onVenueSelected(int index) {
    if (_selectedVenueIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _selectedVenueIndex = index);
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: Point(latitude: _pins[index].lat, longitude: _pins[index].lon), zoom: 15.5),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.4),
      );
      _ensureDetail(_pins[index].id);
    }
  }

  void _onPageChanged(int index) {
    if (_selectedVenueIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _selectedVenueIndex = index);
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: Point(latitude: _pins[index].lat, longitude: _pins[index].lon), zoom: 15.5),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.4),
      );
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

  // ─── Map objects ───────────────────────────────────────────────────

  List<MapObject> get _mapObjects {
    if (_pinNormal == null || _pinSelected == null) return [];

    return _pins.asMap().entries.map((entry) {
      final index = entry.key;
      final pin = entry.value;
      final isSelected = index == _selectedVenueIndex;

      return PlacemarkMapObject(
        mapId: MapObjectId('venue_${pin.id}'),
        point: Point(latitude: pin.lat, longitude: pin.lon),
        opacity: 1.0,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromBytes(isSelected ? _pinSelected! : _pinNormal!),
            scale: isSelected ? 1.0 : 0.85,
            anchor: const Offset(0.5, 1.0),
          ),
        ),
        zIndex: isSelected ? 10 : 1,
        onTap: (_, __) => _onVenueSelected(index),
      );
    }).toList();
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2024),
      body: Stack(
        children: [
          // Yandex Map
          if (_mapReady && !_mapError)
            YandexMap(
              mapType: MapType.vector,
              logoPadding: const MapPadding(horizontal: 80, vertical: 100),
              onMapCreated: (controller) {
                _mapController = controller;

                // Enable user location layer
                try {
                  controller.toggleUserLayer(
                    visible: true,
                    autoZoomEnabled: false,
                  );
                } catch (_) {}

                // Move to Tashkent initially, then try user location
                controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _fallbackCenter, zoom: 13.0),
                  ),
                );

                // Try to move to user location
                _goToUserLocation();
              },
              mapObjects: _mapObjects,
              onUserLocationAdded: (view) async {
                if (_userLocationIcon != null) {
                  return view.copyWith(
                    pin: view.pin.copyWith(
                      icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                          image: BitmapDescriptor.fromBytes(_userLocationIcon!),
                          scale: 1.0,
                        ),
                      ),
                    ),
                    arrow: view.arrow.copyWith(
                      icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                          image: BitmapDescriptor.fromBytes(_userLocationIcon!),
                          scale: 1.0,
                        ),
                      ),
                    ),
                    accuracyCircle: view.accuracyCircle.copyWith(
                      fillColor: const Color(0xFFDC3009).withValues(alpha: 0.1),
                      strokeColor: const Color(0xFFDC3009).withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  );
                }
                return view;
              },
            )
          else if (_mapError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 56.r, color: const Color(0xFF9CA3AF)),
                  Gap(12.h),
                  Text(
                    'Xarita yuklanmadi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                  ),
                  Gap(8.h),
                  TextButton(
                    onPressed: () => setState(() { _mapError = false; _mapReady = true; }),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // Loading indicator
          if (_isLoading && _mapReady)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // Floating top header capsule
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
                      _HeaderIconButton(
                        icon: AppAssets.iconSearch2Line,
                        onTap: _openSearch,
                      ),
                      Gap(8.w),
                      Stack(
                        children: [
                          _HeaderIconButton(
                            icon: AppAssets.iconEqualizer2Line,
                            onTap: _showFilterModal,
                          ),
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
                      _HeaderIconButton(
                        icon: AppAssets.iconNotification3Line,
                        onTap: _openNotifications,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // My location FAB
          Positioned(
            right: 16.w,
            bottom: 290.h,
            child: GestureDetector(
              onTap: _goToUserLocation,
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(Icons.my_location_rounded, size: 22.r, color: const Color(0xFF181A20)),
              ),
            ),
          ),

          // Bottom venue cards carousel
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
                                        errorBuilder: (_, _, _) => _venueImagePlaceholder(),
                                      )
                                    : _venueImagePlaceholder(),
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
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF181A20),
                                            ),
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

  Widget _venueImagePlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Center(child: AppIcon(AppAssets.iconRestaurant, color: Color(0xFF9CA3AF))),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(child: AppIcon(icon, size: 20.r, color: const Color(0xFF181A20))),
      ),
    );
  }
}