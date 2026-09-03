import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../bookings/data/datasources/staff_booking_remote_data_source.dart' show StaffBookingRemoteDataSourceImpl, newIdempotencyKey;
import '../../../bookings/data/repositories/staff_booking_repository_impl.dart';
import '../../../bookings/domain/repositories/staff_booking_repository.dart';
import '../../../bookings/presentation/screens/staff_booking_detail_screen.dart';
import '../../../core/staff_session.dart';
import '../../../waitlist/presentation/screens/staff_navbat_screen.dart';
import '../../data/datasources/staff_zal_remote_data_source.dart';
import '../../../../../core/widgets/app_toast.dart';

/// "Bo'sh stol" varag'i — Figma i8FGYLF28h8GYXQgd1Pczf, node 788:1138.
/// Uchta amal: ko'chadan joylashtirish (`POST /staff/bookings` +
/// `PATCH .../tables` + `POST .../arrive` — zanjir, 02-bugun-va-qr.md
/// §5,§7), telefon broni (§7, `source: qongiroq`), navbatdan chaqirish
/// (Navbat tabiga o'tkazadi — 03-navbat.md).
class StaffEmptyTableSheet extends StatefulWidget {
  final ZalTable table;
  final VoidCallback onChanged;

  const StaffEmptyTableSheet({super.key, required this.table, required this.onChanged});

  static Future<void> show(BuildContext context, ZalTable table, VoidCallback onChanged) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StaffEmptyTableSheet(table: table, onChanged: onChanged),
    );
  }

  @override
  State<StaffEmptyTableSheet> createState() => _StaffEmptyTableSheetState();
}

class _StaffEmptyTableSheetState extends State<StaffEmptyTableSheet> {
  late final StaffBookingRepository _repository;
  int _guests = 2;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = StaffBookingRepositoryImpl(remoteDataSource: StaffBookingRemoteDataSourceImpl(apiClient: StaffSession.apiClient));
  }

  String? get _nextBookingLabel {
    final next = widget.table.nextBookingAt;
    if (next == null) return null;
    final local = next.toLocal();
    final freeMinutes = local.difference(DateTime.now()).inMinutes;
    final h = freeMinutes ~/ 60;
    final m = freeMinutes % 60;
    final freeText = h > 0 ? '$h soat${m > 0 ? ' $m daqiqa' : ''}' : '$m daqiqa';
    return 'Keyingi bron ${formatTime(local)} da · $freeText bo\'sh';
  }

  Future<void> _seatWalkIn() async {
    final venueId = StaffSession.localStorage.selectedVenueId;
    if (venueId == null) return;
    setState(() => _isSubmitting = true);

    final createResult = await _repository.createBooking(
      venueId: venueId,
      startsAt: DateTime.now(),
      guests: _guests,
      guestName: 'Ko\'chadan mehmon',
      source: 'xostes',
      idempotencyKey: newIdempotencyKey(),
    );

    if (createResult case Failure(:final exception)) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.error(context, exception.message);
      return;
    }
    final booking = (createResult as Success).data;

    await _repository.setTables(booking.id, [widget.table.id], idempotencyKey: newIdempotencyKey());
    final arriveResult = await _repository.arrive(booking.id, arrivedGuests: _guests, idempotencyKey: newIdempotencyKey());
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    widget.onChanged();

    if (arriveResult case Success()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: booking.id)));
    }
  }

  void _openNavbat() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffNavbatScreen()));
  }

  Future<void> _phoneBooking() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Telefon broni'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Mehmon ismi')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefon (+998...)'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yaratish')),
        ],
      ),
    );
    if (result != true || nameController.text.trim().isEmpty) return;
    final venueId = StaffSession.localStorage.selectedVenueId;
    if (venueId == null) return;

    setState(() => _isSubmitting = true);
    final createResult = await _repository.createBooking(
      venueId: venueId,
      startsAt: DateTime.now(),
      guests: _guests,
      guestName: nameController.text.trim(),
      guestPhone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      source: 'qongiroq',
      idempotencyKey: newIdempotencyKey(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (createResult) {
      case Success(:final data):
        await _repository.setTables(data.id, [widget.table.id], idempotencyKey: newIdempotencyKey());
        if (!mounted) return;
        Navigator.pop(context);
        widget.onChanged();
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: data.id)));
      case Failure(:final exception):
        AppToast.error(context, exception.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextLabel = _nextBookingLabel;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(999.r)))),
            Gap(16.h),
            Row(
              children: [
                Expanded(child: Text('Stol ${widget.table.number}', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717)))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(color: const Color(0xFFE3F7EC), borderRadius: BorderRadius.circular(999.r)),
                  child: Text('Bo\'sh', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF0B4627))),
                ),
              ],
            ),
            Gap(4.h),
            Text(
              [if (widget.table.zoneName != null) widget.table.zoneName!, '${widget.table.seats} o\'rin', if (widget.table.description != null) widget.table.description!].join(' · '),
              style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF5C5C5C)),
            ),
            if (nextLabel != null) ...[
              Gap(14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12.r)),
                child: Row(
                  children: [
                    SvgPicture.asset(AppAssets.iconCalendarCheckLine, width: 18.r, height: 18.r),
                    Gap(10.w),
                    Expanded(child: Text(nextLabel, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF5C5C5C)))),
                  ],
                ),
              ),
            ],
            Gap(16.h),
            Row(
              children: [
                Expanded(child: Text('Nechta mehmon', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717)))),
                Text('stol ${widget.table.seats} o\'rinli', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFFA3A3A3))),
              ],
            ),
            Gap(8.h),
            Row(
              children: [1, 2, 3, 4, 5].map((n) {
                final isMax = n == 5;
                final isSelected = isMax ? _guests >= 5 : _guests == n;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: n == 5 ? 0 : 8.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _guests = n),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF2EF) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: isSelected ? const Color(0xFFDC3009) : const Color(0xFFEBEBEB), width: isSelected ? 1.5.w : 1.w),
                        ),
                        child: Text(
                          isMax ? '5+' : '$n',
                          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFFB12A0B) : const Color(0xFF171717)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Gap(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _seatWalkIn,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF171717), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16.h), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Ko\'chadan joylashtirish', style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              ),
            ),
            Gap(10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _phoneBooking,
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h), side: const BorderSide(color: Color(0xFFEBEBEB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                    child: Text('Telefon broni', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717))),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _openNavbat,
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h), side: const BorderSide(color: Color(0xFFEBEBEB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                    child: Text('Navbatdan chaqirish', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
