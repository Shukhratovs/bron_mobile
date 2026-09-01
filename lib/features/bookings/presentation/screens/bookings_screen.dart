import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../waitlist/data/datasources/waitlist_remote_data_source.dart';
import '../../../waitlist/data/repositories/waitlist_repository_impl.dart';
import '../../../waitlist/domain/entities/waitlist_entity.dart';
import '../../../waitlist/domain/repositories/waitlist_repository.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_detail_screen.dart';
import 'stol_boshadi_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class BookingsScreen extends StatefulWidget {
  final BookingRepository? repository;
  final WaitlistRepository? waitlistRepository;
  final VenueRepository? venueRepository;

  const BookingsScreen({super.key, this.repository, this.waitlistRepository, this.venueRepository});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late final BookingRepository _repository;
  late final WaitlistRepository _waitlistRepository;
  late final VenueRepository _venueRepository;

  int _selectedTabIndex = 0; // 0: Faol, 1: O'tgan
  bool _isLoading = true;
  List<BookingEntity> _bookings = [];
  List<WaitlistEntity> _waitlist = [];
  final Map<String, String> _venueNames = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _waitlistRepository = widget.waitlistRepository ??
        WaitlistRepositoryImpl(remoteDataSource: WaitlistRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _venueRepository = widget.venueRepository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final tab = _selectedTabIndex == 0 ? 'faol' : 'otgan';
    final bookingsResult = await _repository.getBookings(tab: tab);
    final waitlistResult =
        _selectedTabIndex == 0 ? await _waitlistRepository.getMine() : ApiResult<List<WaitlistEntity>>.success(const []);
    if (!mounted) return;

    if (bookingsResult case Success(:final data)) {
      setState(() => _bookings = data);
      for (final b in _bookings) {
        _resolveVenueName(b.venueId);
      }
    } else {
      setState(() => _bookings = []);
    }
    if (waitlistResult case Success(:final data)) {
      setState(() => _waitlist = data.where((w) => w.status != WaitlistStatus.chiqarildi).toList());
    } else {
      setState(() => _waitlist = []);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _resolveVenueName(String venueId) async {
    if (_venueNames.containsKey(venueId)) return;
    final result = await _venueRepository.getVenueById(venueId);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() => _venueNames[venueId] = data.name);
    }
  }

  void _openBookingDetail(String bookingId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: bookingId)),
    ).then((_) => _load());
  }

  void _openStolBoshadi(WaitlistEntity entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StolBoshadiScreen(
          entry: entry,
          venueName: 'Muassasa',
          repository: _waitlistRepository,
        ),
      ),
    ).then((_) => _load());
  }

  Future<void> _leaveWaitlist(WaitlistEntity entry) async {
    final result = await _waitlistRepository.leave(entry.id);
    if (!mounted) return;
    if (result.isSuccess) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bronlarim',
                  style: GoogleFonts.plusJakartaSans(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF181A20)),
                ),
                Gap(16.h),

                // Segmented Tab Switcher (Faol / O'tgan)
                Container(
                  height: 44.h,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14.r)),
                  child: Row(
                    children: [
                      Expanded(child: _tabButton('Faol', 0)),
                      Expanded(child: _tabButton('O\'tgan', 1)),
                    ],
                  ),
                ),
                Gap(16.h),

                if (_isLoading)
                  const ListRowSkeletonGroup(count: 4)
                else ...[
                  ..._waitlist.map((entry) => Padding(padding: EdgeInsets.only(bottom: 12.h), child: _buildWaitlistCard(entry))),
                  if (_bookings.isEmpty && _waitlist.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Center(
                        child: Text(
                          _selectedTabIndex == 0 ? 'Faol broningiz yo\'q' : 'O\'tgan bronlar yo\'q',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  else
                    ..._buildBookingGroups(),
                ],

                Gap(90.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTabIndex == index) return;
        HapticFeedback.lightImpact();
        setState(() => _selectedTabIndex = index);
        _load();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF181A20) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitlistCard(WaitlistEntity entry) {
    final isCalled = entry.status == WaitlistStatus.chaqirilgan;
    return GestureDetector(
      onTap: isCalled ? () => _openStolBoshadi(entry) : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: isCalled ? const Color(0xFFDC3009) : const Color(0xFFECEFF3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8.r, height: 8.r, decoration: const BoxDecoration(color: Color(0xFFDC3009), shape: BoxShape.circle)),
                    Gap(6.w),
                    Text(
                      isCalled ? 'STOL BO\'SHADI' : 'NAVBATDASIZ',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFFDC3009), letterSpacing: 0.5),
                    ),
                  ],
                ),
                if (!isCalled)
                  GestureDetector(
                    onTap: () => _leaveWaitlist(entry),
                    child: Text('Chiqish', style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF181A20))),
                  ),
              ],
            ),
            Gap(10.h),
            if (!isCalled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sizdan oldin', style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                  Text('${entry.position > 0 ? entry.position - 1 : 0} kishi', style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
                ],
              ),
              Gap(6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Taxminiy kutish', style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                  Text('~${entry.estimatedWaitMinutes} daqiqa', style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
                ],
              ),
            ] else
              Text(
                'Tasdiqlash uchun taymer ishlamoqda — kartaga bosing',
                style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBookingGroups() {
    if (_bookings.isEmpty) return [];
    final now = DateTime.now();
    final today = <BookingEntity>[];
    final upcoming = <BookingEntity>[];
    for (final b in _bookings) {
      final local = b.startsAt.toLocal();
      if (local.year == now.year && local.month == now.month && local.day == now.day) {
        today.add(b);
      } else {
        upcoming.add(b);
      }
    }

    final widgets = <Widget>[];
    if (today.isNotEmpty) {
      widgets.add(_sectionLabel(_selectedTabIndex == 0 ? 'BUGUN' : 'YAQINDA'));
      widgets.add(Gap(8.h));
      widgets.addAll(_intersperse(today.map(_buildBookingItem).toList(), Gap(10.h)));
      if (upcoming.isNotEmpty) widgets.add(Gap(18.h));
    }
    if (upcoming.isNotEmpty) {
      widgets.add(_sectionLabel(_selectedTabIndex == 0 ? 'KEYINGI KUNLAR' : 'AVVALGI BRONLAR'));
      widgets.add(Gap(8.h));
      widgets.addAll(_intersperse(upcoming.map(_buildBookingItem).toList(), Gap(10.h)));
    }
    return widgets;
  }

  List<Widget> _intersperse(List<Widget> items, Widget separator) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) result.add(separator);
    }
    return result;
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF8E8E93), letterSpacing: 0.5),
      );

  Widget _buildBookingItem(BookingEntity booking) {
    final (badgeBg, badgeText, status) = _statusBadge(booking.status);
    final local = booking.startsAt.toLocal();

    return GestureDetector(
      onTap: () => _openBookingDetail(booking.id),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFECEFF3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12.r)),
              child: const AppIcon(AppAssets.iconBuilding4Line, color: Color(0xFF9CA3AF), size: 22),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _venueNames[booking.venueId] ?? booking.code,
                          style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6.r)),
                        child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: badgeText)),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Text(
                    '${formatDateShort(local)} · ${formatTime(local)} · ${booking.guests} kishi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String) _statusBadge(BookingStatus status) {
    switch (status) {
      case BookingStatus.kutilmoqda:
        return (const Color(0xFFE6F9F0), const Color(0xFF12B76A), 'TASDIQLANDI');
      case BookingStatus.kechikmoqda:
        return (const Color(0xFFFEF3EB), const Color(0xFFF79009), 'KUTILMOQDA');
      case BookingStatus.keldi:
        return (const Color(0xFFE6F9F0), const Color(0xFF12B76A), 'KELDI');
      case BookingStatus.kelmadi:
        return (const Color(0xFFFEE4E2), const Color(0xFFD92D20), 'KELMADI');
      case BookingStatus.bekor:
        return (const Color(0xFFFEE4E2), const Color(0xFFD92D20), 'BEKOR QILINGAN');
      case BookingStatus.yakunlandi:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280), 'YAKUNLANDI');
      case BookingStatus.unknown:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280), '—');
    }
  }
}
