import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';
import '../../../bookings/presentation/screens/staff_booking_detail_screen.dart';
import '../../../core/staff_session.dart';
import '../../../main/presentation/widgets/staff_avatar_button.dart';
import '../../data/datasources/staff_zal_remote_data_source.dart';
import '../widgets/staff_empty_table_sheet.dart';

/// Figma: i8FGYLF28h8GYXQgd1Pczf, "3 · ZAL" (`288:373`). API:
/// `GET /staff/zal` (`ZalOut` — zonalar/stollar/xulosa bitta so'rovda,
/// `/openapi/staff.json`dan tasdiqlangan sxema).
class StaffZalScreen extends StatefulWidget {
  final StaffZalRemoteDataSource? dataSource;

  const StaffZalScreen({super.key, this.dataSource});

  @override
  State<StaffZalScreen> createState() => _StaffZalScreenState();
}

class _StaffZalScreenState extends State<StaffZalScreen> {
  late final StaffZalRemoteDataSource _dataSource;
  ZalState? _state;
  String? _selectedZoneId;
  bool _isLoading = true;
  String? _staffName;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? StaffZalRemoteDataSourceImpl(apiClient: StaffSession.apiClient);
    _loadMe();
    _load();
  }

  Future<void> _loadMe() async {
    try {
      final response = await StaffSession.apiClient.get(ApiEndpoints.staffMe);
      if (mounted && response is Map) setState(() => _staffName = response['name']?.toString());
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final state = await _dataSource.getZal(zoneId: _selectedZoneId);
      if (mounted) setState(() => _state = state);
    } catch (_) {
      // Pastda xato holati ko'rsatiladi.
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _selectZone(String? zoneId) {
    setState(() => _selectedZoneId = zoneId);
    _load();
  }

  void _onTableTap(ZalTable table) {
    switch (table.state) {
      case TableState.bosh:
        StaffEmptyTableSheet.show(context, table, _load);
      case TableState.bronlangan:
      case TableState.band:
        final bookingId = table.currentBooking?.id;
        if (bookingId == null) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: bookingId))).then((_) => _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              if (_isLoading)
                SliverPadding(padding: EdgeInsets.all(16.w), sliver: const SliverToBoxAdapter(child: ListRowSkeletonGroup(count: 6)))
              else if (_state == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Center(child: Text('Zal ma\'lumotini yuklab bo\'lmadi', style: GoogleFonts.inter(color: const Color(0xFF5C5C5C)))),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 220.h),
                  sliver: SliverToBoxAdapter(child: _tableGrid(_state!.tables)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final zones = _state?.zones ?? const <ZalZone>[];
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Zal', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717)))),
              StaffAvatarButton(name: _staffName),
            ],
          ),
          if (zones.isNotEmpty) ...[
            Gap(14.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _zoneChip('Barchasi', _selectedZoneId == null, () => _selectZone(null)),
                  Gap(8.w),
                  ...zones.map((z) => Padding(padding: EdgeInsets.only(right: 8.w), child: _zoneChip(z.name, _selectedZoneId == z.id, () => _selectZone(z.id)))),
                ],
              ),
            ),
          ],
          Gap(12.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _legend('Bo\'sh', Colors.white, const Color(0xFFEBEBEB)),
              _legend('Bronlangan', const Color(0xFFFFF2EF), const Color(0xFFFFCDC2)),
              _legend('Band', const Color(0xFF171717), const Color(0xFF171717)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoneChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF171717) : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: isSelected ? const Color(0xFF171717) : const Color(0xFFEBEBEB)),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF171717))),
      ),
    );
  }

  Widget _legend(String label, Color fill, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12.r, height: 12.r, decoration: BoxDecoration(color: fill, border: Border.all(color: border), borderRadius: BorderRadius.circular(4.r))),
        Gap(7.w),
        Text(label, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF5C5C5C))),
      ],
    );
  }

  Widget _tableGrid(List<ZalTable> tables) {
    if (tables.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(child: Text('Bu zonada stol yo\'q', style: GoogleFonts.inter(color: const Color(0xFFA3A3A3)))),
      );
    }
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: tables.map(_tableTile).toList(),
    );
  }

  Widget _tableTile(ZalTable t) {
    final (bg, border, textColor, subColor) = switch (t.state) {
      TableState.bosh => (Colors.white, const Color(0xFFEBEBEB), const Color(0xFF171717), const Color(0xFF5C5C5C)),
      TableState.bronlangan => (const Color(0xFFFFF2EF), const Color(0xFFFFCDC2), const Color(0xFFB12A0B), const Color(0xFFB12A0B)),
      TableState.band => (const Color(0xFF171717), const Color(0xFF171717), Colors.white, const Color(0xFFA3A3A3)),
    };
    final stateLabel = switch (t.state) {
      TableState.bosh => 'Bo\'sh',
      TableState.bronlangan => t.currentBooking != null ? 'Bron - ${_hm(t.currentBooking!.startsAt)}' : 'Bronlangan',
      TableState.band => 'Band',
    };

    return GestureDetector(
      onTap: () => _onTableTap(t),
      child: Container(
        width: 114.w,
        height: 88.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.number, style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w500, color: textColor)),
            Text('${t.seats} o\'rin', style: GoogleFonts.inter(fontSize: 12.sp, color: subColor.withValues(alpha: 0.85))),
            Text(stateLabel, style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500, color: subColor)),
          ],
        ),
      ),
    );
  }

  String _hm(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
