import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';
import '../../../core/staff_session.dart';
import '../../../zal/data/datasources/staff_zal_remote_data_source.dart';
import '../../data/datasources/staff_booking_remote_data_source.dart';
import '../../data/repositories/staff_booking_repository_impl.dart';
import '../../domain/repositories/staff_booking_repository.dart';
import 'qr_scan_screen.dart';
import 'staff_booking_detail_screen.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';

/// Figma: `Bugun` (`286:244`) — xostes/02-bugun-va-qr.md.
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        StaffBookingRepositoryImpl(remoteDataSource: StaffBookingRemoteDataSourceImpl(apiClient: StaffSession.apiClient));
    _zalDataSource = StaffZalRemoteDataSourceImpl(apiClient: StaffSession.apiClient);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _repository.getBookings(q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim());
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        _bookings = [...data]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      });
    }
    try {
      final zal = await _zalDataSource.getZal();
      if (mounted) setState(() => _freeTables = zal.freeNow);
    } catch (_) {
      // Zal endpoint hozircha kengaytiriladi.
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _openDetail(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: id, repository: _repository)))
        .then((_) => _load());
  }

  void _openScan() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => QrScanScreen(repository: _repository)))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hozir = <BookingEntity>[];
    final keyingi = <BookingEntity>[];
    for (final b in _bookings) {
      final diff = b.startsAt.toLocal().difference(now).inMinutes.abs();
      (diff <= 30 ? hozir : keyingi).add(b);
    }
    final kutilmoqda = _bookings.where((b) => b.status == BookingStatus.kutilmoqda).length;
    final keldi = _bookings.where((b) => b.status == BookingStatus.keldi).length;
    final kechikmoqda = _bookings.where((b) => b.status == BookingStatus.kechikmoqda).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Bugun', style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    IconButton(
                      onPressed: _openScan,
                      icon: const AppIcon(AppAssets.iconQrScan2Line, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Ism, telefon yoki BRN- kodi',
                    prefixIcon: const AppIcon(AppAssets.iconSearch),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                ),
              ),
              Gap(12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    _statTile('Kutilmoqda', kutilmoqda, const Color(0xFF2563EB)),
                    _statTile('Keldi', keldi, const Color(0xFF12B76A)),
                    _statTile('Kechikmoqda', kechikmoqda, const Color(0xFFF79009)),
                    _statTile('Bo\'sh stol', _freeTables, const Color(0xFF6B7280)),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 5))
                    : ListView(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                        children: [
                          if (hozir.isNotEmpty) ...[
                            _sectionLabel('HOZIR'),
                            Gap(8.h),
                            ...hozir.map((b) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: _bookingCard(b))),
                          ],
                          if (keyingi.isNotEmpty) ...[
                            Gap(hozir.isNotEmpty ? 10.h : 0),
                            _sectionLabel('KEYINGI'),
                            Gap(8.h),
                            ...keyingi.map((b) => Padding(padding: EdgeInsets.only(bottom: 10.h), child: _bookingCard(b))),
                          ],
                          if (_bookings.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Center(child: Text('Bugun bron yo\'q', style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textSecondary))),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFFECEFF3))),
        child: Column(
          children: [
            Text('$value', style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: color)),
            Gap(2.h),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 9.5.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) =>
      Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5));

  Widget _bookingCard(BookingEntity b) {
    final (bg, color, label) = _statusStyle(b.status);
    return GestureDetector(
      onTap: () => _openDetail(b.id),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: const Color(0xFFECEFF3))),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10.r)),
              child: Text(formatTime(b.startsAt.toLocal()), style: GoogleFonts.plusJakartaSans(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(b.guestName, style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6.r)),
                        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                  Gap(3.h),
                  Text('${b.guests} kishi${b.tableLabel.isNotEmpty ? ' · ${b.tableLabel}' : ''}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary)),
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
        return (const Color(0xFFDBEAFE), const Color(0xFF2563EB), 'KUTILMOQDA');
      case BookingStatus.kechikmoqda:
        return (const Color(0xFFFEF3EB), const Color(0xFFF79009), 'KECHIKMOQDA');
      case BookingStatus.keldi:
        return (const Color(0xFFE6F9F0), const Color(0xFF12B76A), 'KELDI');
      case BookingStatus.kelmadi:
        return (const Color(0xFFFEE4E2), const Color(0xFFD92D20), 'KELMADI');
      case BookingStatus.bekor:
        return (const Color(0xFFFEE4E2), const Color(0xFFD92D20), 'BEKOR');
      case BookingStatus.yakunlandi:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280), 'YAKUNLANDI');
      case BookingStatus.unknown:
        return (const Color(0xFFF3F4F6), const Color(0xFF6B7280), '—');
    }
  }
}
