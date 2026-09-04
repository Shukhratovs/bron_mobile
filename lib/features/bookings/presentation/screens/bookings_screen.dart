import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_state_view.dart';
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
import '../../../main/presentation/widgets/custom_bottom_nav_bar.dart';

class BookingsScreen extends StatefulWidget {
  final BookingRepository? repository;
  final WaitlistRepository? waitlistRepository;
  final VenueRepository? venueRepository;

  const BookingsScreen({super.key, this.repository, this.waitlistRepository, this.venueRepository});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late final BookingRepository _repository;
  late final WaitlistRepository _waitlistRepository;
  late final VenueRepository _venueRepository;
  late final TabController _tabController;

  final Map<String, String> _venueNames = {};

  // Har bir tab o'z holatini alohida saqlaydi — shu tufayli swipe qilib
  // o'tishda ikkinchi tab qayta yuklanishini kutish shart emas (ikkalasi
  // ham bir vaqtda, mustaqil yuklanadi).
  bool _isActiveLoading = true;
  List<BookingEntity> _activeBookings = [];
  List<WaitlistEntity> _waitlist = [];

  bool _isHistoryLoading = true;
  List<BookingEntity> _historyBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = widget.repository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _waitlistRepository = widget.waitlistRepository ??
        WaitlistRepositoryImpl(remoteDataSource: WaitlistRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _venueRepository = widget.venueRepository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _loadActive();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActive() async {
    setState(() => _isActiveLoading = true);
    final bookingsResult = await _repository.getBookings(tab: 'faol');
    final waitlistResult = await _waitlistRepository.getMine();
    if (!mounted) return;

    if (bookingsResult case Success(:final data)) {
      setState(() => _activeBookings = data);
      for (final b in _activeBookings) {
        _resolveVenueName(b.venueId);
      }
    } else {
      setState(() => _activeBookings = []);
    }
    if (waitlistResult case Success(:final data)) {
      setState(() => _waitlist = data.where((w) => w.status != WaitlistStatus.chiqarildi).toList());
    } else {
      setState(() => _waitlist = []);
    }
    setState(() => _isActiveLoading = false);
  }

  Future<void> _loadHistory() async {
    setState(() => _isHistoryLoading = true);
    final result = await _repository.getBookings(tab: 'otgan');
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _historyBookings = data;
          _isHistoryLoading = false;
        });
        for (final b in _historyBookings) {
          _resolveVenueName(b.venueId);
        }
      case Failure():
        setState(() {
          _historyBookings = [];
          _isHistoryLoading = false;
        });
    }
  }

  Future<void> _reloadCurrentTab() {
    return _tabController.index == 0 ? _loadActive() : _loadHistory();
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
    ).then((_) => _reloadCurrentTab());
  }

  void _openStolBoshadi(WaitlistEntity entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StolBoshadiScreen(
          entry: entry,
          venueName: AppStrings.genericVenueName,
          repository: _waitlistRepository,
        ),
      ),
    ).then((_) => _loadActive());
  }

  Future<void> _leaveWaitlist(WaitlistEntity entry) async {
    final result = await _waitlistRepository.leave(entry.id);
    if (!mounted) return;
    if (result.isSuccess) _loadActive();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Text(
                    AppStrings.myBookings,
                    style: GoogleFonts.plusJakartaSans(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF181A20)),
                  ),
                ),
                Gap(16.h),

                // Segmented Tab Switcher (Faol / O'tgan) — bosish ham, tanani
                // (body) chapga/o'ngga surish (swipe) ham bir xil silliq
                // suriluvchi pill bilan boshqariladi: pill TabController'ning
                // uzluksiz animatsiya qiymatiga (`animation!.value`) bog'langan,
                // shuning uchun barmoq bilan yarim yo'lgacha surilganda ham
                // pill xuddi shu darajada suriladi — bosish va swipe bir xil
                // "og'irlik"da his qilinadi. Butun ekranni emas, faqat shu
                // kichik widgetni qayta chizadi (`setState` yo'q).
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    height: 44.h,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tabWidth = (constraints.maxWidth - 8.w) / 2;
                        return AnimatedBuilder(
                          animation: _tabController.animation!,
                          builder: (context, _) {
                            final animValue = _tabController.animation!.value.clamp(0.0, 1.0);
                            return Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14.r)),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: animValue * tabWidth,
                                    top: 0,
                                    bottom: 0,
                                    width: tabWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.r),
                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(child: _tabButton(AppStrings.activeTab, 0)),
                                      Expanded(child: _tabButton(AppStrings.historyTab, 1)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Gap(16.h),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveTabBody(),
                      _buildHistoryTabBody(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTabBody() {
    return RefreshIndicator.adaptive(
      onRefresh: _loadActive,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isActiveLoading)
              const ListRowSkeletonGroup(count: 4)
            else ...[
              ..._waitlist.map((entry) => Padding(padding: EdgeInsets.only(bottom: 12.h), child: _buildWaitlistCard(entry))),
              if (_activeBookings.isEmpty && _waitlist.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: AppStateView.empty(icon: Icons.event_busy_outlined, title: AppStrings.noBookingsFound),
                )
              else
                ..._buildBookingGroups(_activeBookings, isActiveTab: true),
            ],
            Gap(CustomBottomNavBar.reservedBottomSpace(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTabBody() {
    return RefreshIndicator.adaptive(
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isHistoryLoading)
              const ListRowSkeletonGroup(count: 4)
            else if (_historyBookings.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: AppStateView.empty(icon: Icons.event_busy_outlined, title: AppStrings.noBookingsFound),
              )
            else
              ..._buildBookingGroups(_historyBookings, isActiveTab: false),
            Gap(CustomBottomNavBar.reservedBottomSpace(context)),
          ],
        ),
      ),
    );
  }

  // Diqqat: bu widget endi o'z fonini chizmaydi — suriluvchi pill uning
  // orqasida, alohida `Positioned` sifatida chiziladi (yuqoridagi
  // `AnimatedBuilder`). Bu yerda faqat matn va bosishni ushlash bor.
  Widget _tabButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_tabController.index == index) return;
        HapticFeedback.lightImpact();
        _tabController.animateTo(index);
      },
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
                      isCalled ? AppStrings.waitlistReadyBadge : AppStrings.waitlistWaitingBadge,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFFDC3009), letterSpacing: 0.5),
                    ),
                  ],
                ),
                if (!isCalled)
                  GestureDetector(
                    onTap: () => _leaveWaitlist(entry),
                    child: Text(AppStrings.leaveQueueAction, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF181A20))),
                  ),
              ],
            ),
            Gap(10.h),
            if (!isCalled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.peopleAheadLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                  Text('${entry.position > 0 ? entry.position - 1 : 0} ${AppStrings.persons}', style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
                ],
              ),
              Gap(6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.estimatedWaitLabel, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                  Text('~${entry.estimatedWaitMinutes} ${AppStrings.waitMinutesSuffix}', style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
                ],
              ),
            ] else
              Text(
                AppStrings.confirmTimerRunningNote,
                style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBookingGroups(List<BookingEntity> bookings, {required bool isActiveTab}) {
    if (bookings.isEmpty) return [];
    final now = DateTime.now();
    final today = <BookingEntity>[];
    final upcoming = <BookingEntity>[];
    for (final b in bookings) {
      final local = b.startsAt.toLocal();
      if (local.year == now.year && local.month == now.month && local.day == now.day) {
        today.add(b);
      } else {
        upcoming.add(b);
      }
    }

    final widgets = <Widget>[];
    if (today.isNotEmpty) {
      widgets.add(_sectionLabel(isActiveTab ? AppStrings.todaySectionLabel : AppStrings.upcomingSectionLabel));
      widgets.add(Gap(8.h));
      widgets.addAll(_intersperse(today.map(_buildBookingItem).toList(), Gap(10.h)));
      if (upcoming.isNotEmpty) widgets.add(Gap(18.h));
    }
    if (upcoming.isNotEmpty) {
      widgets.add(_sectionLabel(isActiveTab ? AppStrings.nextDaysSectionLabel : AppStrings.pastBookingsSectionLabel));
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
                    '${formatDateShort(local)} · ${formatTime(local)} · ${booking.guests} ${AppStrings.persons}',
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
        return (const Color(0xFFE6F9F0), const Color(0xFF12B76A), AppStrings.bookingBadgeConfirmed);
      case BookingStatus.kechikmoqda:
        return (const Color(0xFFFEF3EB), const Color(0xFFF79009), AppStrings.bookingBadgePending);
      case BookingStatus.keldi:
        return (const Color(0xFFE6F9F0), const Color(0xFF12B76A), AppStrings.bookingBadgeArrived);
      case BookingStatus.kelmadi:
        return (const Color(0xFFFEE4E2), const Color(0xFFD92D20), AppStrings.bookingBadgeNoShow);
      case BookingStatus.bekor:
        return (const Color(0xFFFEE4E2), const Color(0xFFD92D20), AppStrings.bookingBadgeCancelled);
      case BookingStatus.yakunlandi:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280), AppStrings.bookingBadgeCompleted);
      case BookingStatus.unknown:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280), '—');
    }
  }
}
