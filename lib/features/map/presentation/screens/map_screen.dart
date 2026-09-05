import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/widgets/app_state_view.dart';
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
  bool _pinsLoadFailed = false;
  bool _pinsOffline = false;
  String? _selectedKind;

  // Pin image caches
  Uint8List? _pinNormal;
  Uint8List? _pinSelected;
  Uint8List? _userLocationIcon;

  // Tashkent center
  static const _fallbackCenter = Point(latitude: 41.314581, longitude: 69.237562);

  // O'zbekiston chegarasi (soddalashtirilgan, 54 nuqta) — faqat vizual
  // chegara chizig'i va xaritani mamlakat hududi bilan cheklash uchun.
  static const _uzbekistanBorder = <Point>[
    Point(latitude: 37.362784, longitude: 66.518607),
    Point(latitude: 37.974685, longitude: 66.54615),
    Point(latitude: 38.402695, longitude: 65.215999),
    Point(latitude: 38.892407, longitude: 64.170223),
    Point(latitude: 39.363257, longitude: 63.518015),
    Point(latitude: 40.053886, longitude: 62.37426),
    Point(latitude: 41.084857, longitude: 61.882714),
    Point(latitude: 41.26637, longitude: 61.547179),
    Point(latitude: 41.220327, longitude: 60.465953),
    Point(latitude: 41.425146, longitude: 60.083341),
    Point(latitude: 42.223082, longitude: 59.976422),
    Point(latitude: 42.751551, longitude: 58.629011),
    Point(latitude: 42.170553, longitude: 57.78653),
    Point(latitude: 41.826026, longitude: 56.932215),
    Point(latitude: 41.32231, longitude: 57.096391),
    Point(latitude: 41.308642, longitude: 55.968191),
    Point(latitude: 44.995858, longitude: 55.928917),
    Point(latitude: 45.586804, longitude: 58.503127),
    Point(latitude: 45.500014, longitude: 58.689989),
    Point(latitude: 44.784037, longitude: 60.239972),
    Point(latitude: 44.405817, longitude: 61.05832),
    Point(latitude: 43.504477, longitude: 62.0133),
    Point(latitude: 43.650075, longitude: 63.185787),
    Point(latitude: 43.728081, longitude: 64.900824),
    Point(latitude: 42.99766, longitude: 66.098012),
    Point(latitude: 41.994646, longitude: 66.023392),
    Point(latitude: 41.987644, longitude: 66.510649),
    Point(latitude: 41.168444, longitude: 66.714047),
    Point(latitude: 41.135991, longitude: 67.985856),
    Point(latitude: 40.662325, longitude: 68.259896),
    Point(latitude: 40.668681, longitude: 68.632483),
    Point(latitude: 41.384244, longitude: 69.070027),
    Point(latitude: 42.081308, longitude: 70.388965),
    Point(latitude: 42.266154, longitude: 70.962315),
    Point(latitude: 42.167711, longitude: 71.259248),
    Point(latitude: 41.519998, longitude: 70.420022),
    Point(latitude: 41.143587, longitude: 71.157859),
    Point(latitude: 41.3929, longitude: 71.870115),
    Point(latitude: 40.866033, longitude: 73.055417),
    Point(latitude: 40.145844, longitude: 71.774875),
    Point(latitude: 40.244366, longitude: 71.014198),
    Point(latitude: 40.218527, longitude: 70.601407),
    Point(latitude: 40.496495, longitude: 70.45816),
    Point(latitude: 40.960213, longitude: 70.666622),
    Point(latitude: 40.727824, longitude: 69.329495),
    Point(latitude: 40.086158, longitude: 69.011633),
    Point(latitude: 39.533453, longitude: 68.536416),
    Point(latitude: 39.580478, longitude: 67.701429),
    Point(latitude: 39.140144, longitude: 67.44222),
    Point(latitude: 38.901553, longitude: 68.176025),
    Point(latitude: 38.157025, longitude: 68.392033),
    Point(latitude: 37.144994, longitude: 67.83),
    Point(latitude: 37.356144, longitude: 67.075782),
    Point(latitude: 37.362784, longitude: 66.518607),
  ];

  // Chegaradan biroz kengroq — foydalanuvchi panorama qilganda hudud
  // qirg'og'ida "devorga urilib qolgandek" tuyulmasligi uchun bir oz
  // bo'sh joy qoldiriladi.
  static const _uzbekistanBounds = BoundingBox(
    northEast: Point(latitude: 46.3, longitude: 73.8),
    southWest: Point(latitude: 36.4, longitude: 55.2),
  );

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

  // Foydalanuvchi joylashuvi belgisi ataylab muassasa pinlaridan (qizil
  // "B" belgisi) butunlay boshqacha uslubda — havorang, soyali "joriy
  // joylashuv" nuqtasi (Google/Apple xaritalaridagi kabi), aralashtirib
  // yubormaslik uchun.
  static const _userDotColor = Color(0xFF2F80ED);

  Future<Uint8List> _renderUserDot() async {
    const double size = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));
    const center = Offset(size / 2, size / 2);

    // Outer glow
    final glowPaint = Paint()..color = _userDotColor.withValues(alpha: 0.18);
    canvas.drawCircle(center, size / 2, glowPaint);

    // Soft shadow under the ring
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 1), 10, shadowPaint);

    // White ring
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 10, whitePaint);

    // Blue core dot
    final dotPaint = Paint()..color = _userDotColor;
    canvas.drawCircle(center, 7, dotPaint);

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
    setState(() {
      _isLoading = true;
      _pinsLoadFailed = false;
      _pinsOffline = false;
    });
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
      case Failure(:final exception):
        setState(() {
          _isLoading = false;
          _pinsLoadFailed = true;
          _pinsOffline = exception is NoInternetException;
        });
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
                AppStrings.categoryLabel,
                style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20)),
              ),
              Gap(14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ChoiceChip(
                    label: Text(AppStrings.filterAll),
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

  static const _uzbekistanBorderPolygon = PolygonMapObject(
    mapId: MapObjectId('uzbekistan_border'),
    polygon: Polygon(
      outerRing: LinearRing(points: _uzbekistanBorder),
      innerRings: [],
    ),
    fillColor: Colors.transparent,
    strokeColor: Color(0x33181A20),
    strokeWidth: 1.5,
    zIndex: 0,
    consumeTapEvents: false,
  );

  List<MapObject> get _mapObjects {
    if (_pinNormal == null || _pinSelected == null) return [_uzbekistanBorderPolygon];

    final venuePins = _pins.asMap().entries.map((entry) {
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
    });

    return [_uzbekistanBorderPolygon, ...venuePins];
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2024),
      body: Stack(
        children: [
          // Yandex Map
          if (_mapReady && !_mapError)
            YandexMap(
              mapType: MapType.vector,
              logoPadding:  MapPadding(horizontal: 80, vertical: (MediaQuery.of(context).size.height * 3).toInt()),
              // Xarita faqat O'zbekiston hududi bilan cheklanadi — boshqa
              // davlatlarga panorama qilib chiqib ketib bo'lmaydi, zoom
              // qilib uzoqlashtirish ham butun mamlakatni ko'rsatadigan
              // darajadan pastga (kichikroq zoom qiymatiga) tushmaydi.
              cameraBounds: const CameraBounds(
                minZoom: 5.2,
                maxZoom: 18,
                latLngBounds: _uzbekistanBounds,
              ),
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
                      fillColor: _userDotColor.withValues(alpha: 0.1),
                      strokeColor: _userDotColor.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  );
                }
                return view;
              },
            )
          else if (_mapError)
            Container(
              color: Colors.white,
              child: AppStateView.error(
                title: AppStrings.mapLoadFailed,
                onRetry: () => setState(() { _mapError = false; _mapReady = true; }),
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
            bottom: 200.h,
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
            )
          else if (_pinsLoadFailed && !_isLoading)
            // Xarita o'zi ishlayapti, faqat muassasalar ro'yxati
            // kelmadi — xaritani to'sib qo'ymaslik uchun pastda ixcham
            // karta, to'liq ekran holatida emas.
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 100.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Icon(
                      _pinsOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                      size: 20.r,
                      color: _pinsOffline ? AppColors.warning : AppColors.error,
                    ),
                    Gap(10.w),
                    Expanded(
                      child: Text(
                        _pinsOffline ? AppStrings.noInternetTitle : AppStrings.somethingWentWrong,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF181A20)),
                      ),
                    ),
                    Gap(8.w),
                    TextButton(
                      onPressed: _loadPins,
                      child: Text(AppStrings.retry, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
      },
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