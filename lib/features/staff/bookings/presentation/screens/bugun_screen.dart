import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';
import '../../../core/staff_session.dart';
import '../../../main/presentation/widgets/staff_avatar_button.dart';
import '../../../zal/data/datasources/staff_zal_remote_data_source.dart';
import '../../data/datasources/staff_booking_remote_data_source.dart';
import '../../data/repositories/staff_booking_repository_impl.dart';
import '../../domain/repositories/staff_booking_repository.dart';
import 'staff_booking_detail_screen.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';

/// Figma: i8FGYLF28h8GYXQgd1Pczf, "2 · BUGUN" (`286:244`) —
/// xostes/02-bugun-va-qr.md.
class BugunScreen extends StatefulWidget {
  final StaffBookingRepository? repository;

  const BugunScreen({super.key, this.repository});

  @override
  State<BugunScreen> createState() => _BugunScreenState();
}

class _BugunScreenState extends State<BugunScreen> {
  late final StaffBookingRepository _repository;
  late final StaffZalRemoteDataSource _zalDataSource;

  List<BookingEntity> _bookings = [];
  int _freeTables = 0;
  bool _isLoading = true;
  String? _staffName;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        StaffBookingRepositoryImpl(remoteDataSource: StaffBookingRemoteDataSourceImpl(apiClient: StaffSession.apiClient));
    _zalDataSource = StaffZalRemoteDataSourceImpl(apiClient: StaffSession.apiClient);
    _loadMe();
    _load();
  }

  Future<void> _loadMe() async {
    try {
      final response = await StaffSession.apiClient.get(ApiEndpoints.staffMe);
      if (mounted && response is Map) setState(() => _staffName = response['name']?.toString());
    } catch (_) {
      // Avatar harflari bo'sh qoladi — kritik emas.
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _repository.getBookings();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        _bookings = [...data]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      });
    }
    try {
      final zal = await _zalDataSource.getZal();
      if (mounted) setState(() => _freeTables = zal.summary.freeNow);
    } catch (_) {
      // Zal endpoint hozircha kengaytiriladi.
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _openDetail(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: id, repository: _repository)))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hozir = <BookingEntity>[];
    final keyingi = <BookingEntity>[];
    for (final b in _bookings) {
      final diff = b.startsAt.toLocal().difference(now).inMinutes;
      (diff >= -30 && diff <= 30 ? hozir : keyingi).add(b);
    }
    final kutilmoqda = _bookings.where((b) => b.status == BookingStatus.kutilmoqda).length;
    final keldi = _bookings.where((b) => b.status == BookingStatus.keldi).length;
    final kechikmoqda = _bookings.where((b) => b.status == BookingStatus.kechikmoqda).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(kutilmoqda, keldi, kechikmoqda)),
              if (_isLoading)
                SliverPadding(padding: EdgeInsets.all(16.w), sliver: const SliverToBoxAdapter(child: ListRowSkeletonGroup(count: 5)))
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 220.h),
                  sliver: SliverList.list(children: [
                    if (hozir.isNotEmpty) ...[
                      _sectionLabel('HOZIR${_rangeLabel(hozir)}'),
                      Gap(8.h),
                      ...hozir.map((b) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: _bookingCard(b))),
                      Gap(14.h),
                    ],
                    if (keyingi.isNotEmpty) ...[
                      _sectionLabel('KEYINGI'),
                      Gap(8.h),
                      ...keyingi.map((b) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: _bookingCard(b))),
                    ],
                    if (_bookings.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Center(child: Text('Bugun bron yo\'q', style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: const Color(0xFF5C5C5C)))),
                      ),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _rangeLabel(List<BookingEntity> hozir) {
    if (hozir.length < 2) return hozir.isEmpty ? '' : ' · ${formatTime(hozir.first.startsAt.toLocal())}';
    final first = formatTime(hozir.first.startsAt.toLocal());
    final last = formatTime(hozir.last.startsAt.toLocal());
    return ' · $first–$last';
  }

  Widget _header(int kutilmoqda, int keldi, int kechikmoqda) {
    final venue = StaffSession.localStorage.selectedVenueName;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bugun', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717))),
                    Text(
                      [formatDateLong(DateTime.now()), if (venue != null) venue].join(' · '),
                      style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF5C5C5C)),
                    ),
                  ],
                ),
              ),
              StaffAvatarButton(name: _staffName),
            ],
          ),
          Gap(14.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _statTile(AppAssets.iconTimeLine, kutilmoqda.toString(), 'Kutilmoqda', const Color(0xFFF7F7F7), false),
              _statTile(AppAssets.iconCheckDoubleLine, keldi.toString(), 'Keldi', const Color(0xFFE3F7EC), false),
              _statTile(AppAssets.iconTimerLine, kechikmoqda.toString(), 'Kechikmoqda', Colors.white, true),
              _statTile(AppAssets.iconLayoutGridLine, _freeTables.toString(), 'Bo\'sh stol', const Color(0xFFF7F7F7), false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String icon, String value, String label, Color iconBg, bool isWarning) {
    return Container(
      width: 176.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF2EF) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isWarning ? const Color(0xFFFFCDC2) : const Color(0xFFEBEBEB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 24.r,
                height: 24.r,
                colorFilter: isWarning ? const ColorFilter.mode(Color(0xFFB12A0B), BlendMode.srcIn) : null,
              ),
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w600, color: isWarning ? const Color(0xFFB12A0B) : const Color(0xFF171717))),
                Text(label, style: GoogleFonts.inter(fontSize: 12.sp, color: isWarning ? const Color(0xFFB12A0B) : const Color(0xFF5C5C5C))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) =>
      Text(text, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFFA3A3A3), letterSpacing: 0.5));

  Widget _bookingCard(BookingEntity b) {
    final (bg, color, label) = _statusStyle(b.status);
    final initials = b.guestName.trim().isEmpty
        ? '?'
        : b.guestName.trim().split(RegExp(r'\s+')).take(2).map((p) => p.substring(0, 1)).join().toUpperCase();
    return GestureDetector(
      onTap: () => _openDetail(b.id),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: const [BoxShadow(color: Color(0x080A0D14), blurRadius: 1, offset: Offset(0, 1))]),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFFFF2EF), shape: BoxShape.circle),
              child: Text(initials, style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFFB12A0B))),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(b.guestName, style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Gap(8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999.r)),
                        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.2)),
                      ),
                    ],
                  ),
                  Gap(6.h),
                  Text(
                    '${formatTime(b.startsAt.toLocal())} · ${b.guests} kishi${b.tableLabel.isNotEmpty ? ' · ${b.tableLabel}' : ''}',
                    style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF5C5C5C)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String) _statusStyle(BookingStatus status) {
    switch (status) {
      case BookingStatus.kutilmoqda:
        return (const Color(0xFFEBEBEB), const Color(0xFF262626), 'KUTILMOQDA');
      case BookingStatus.kechikmoqda:
        return (const Color(0xFFFFD9C0), const Color(0xFF71330A), 'KECHIKMOQDA');
      case BookingStatus.keldi:
        return (const Color(0xFFE3F7EC), const Color(0xFF0D7A3F), 'KELDI');
      case BookingStatus.kelmadi:
        return (const Color(0xFFFFEBEC), const Color(0xFFB3261E), 'KELMADI');
      case BookingStatus.bekor:
        return (const Color(0xFFFFEBEC), const Color(0xFFB3261E), 'BEKOR');
      case BookingStatus.yakunlandi:
        return (const Color(0xFFEBEBEB), const Color(0xFF262626), 'YAKUNLANDI');
      case BookingStatus.unknown:
        return (const Color(0xFFEBEBEB), const Color(0xFF262626), '—');
    }
  }
}
