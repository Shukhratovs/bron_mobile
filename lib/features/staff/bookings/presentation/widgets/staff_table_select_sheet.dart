import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';
import '../../../core/staff_session.dart';
import '../../../zal/data/datasources/staff_zal_remote_data_source.dart';

/// Stol berish/almashtirish — 02-bugun-va-qr.md §5.
/// `GET /staff/zal/availability?date=&guests=` dan bo'sh stollarni oladi,
/// bronning **joriy** stollarini ham (band bo'lsa ham) ro'yxatga
/// qo'shadi — aks holda mehmon allaqachon o'tirgan stolni tanlab
/// bo'lmaydi. Natija — tanlangan `table_ids` ro'yxati, chaqiruvchi
/// `PATCH .../tables`ni o'zi yuboradi.
class StaffTableSelectSheet extends StatefulWidget {
  final BookingEntity booking;

  const StaffTableSelectSheet({super.key, required this.booking});

  static Future<List<String>?> show(BuildContext context, BookingEntity booking) {
    return showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StaffTableSelectSheet(booking: booking),
    );
  }

  @override
  State<StaffTableSelectSheet> createState() => _StaffTableSelectSheetState();
}

class _StaffTableSelectSheetState extends State<StaffTableSelectSheet> {
  late final StaffZalRemoteDataSource _dataSource;
  List<ZalTable> _options = [];
  final Set<String> _selected = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = StaffZalRemoteDataSourceImpl(apiClient: StaffSession.apiClient);
    _selected.addAll(widget.booking.tables.map((t) => t.id));
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final starts = widget.booking.startsAt.toLocal();
      final dateStr = '${starts.year}-${starts.month.toString().padLeft(2, '0')}-${starts.day.toString().padLeft(2, '0')}';
      final free = await _dataSource.getAvailability(date: dateStr, guests: widget.booking.guests);

      // Bronning joriy stollari band bo'lgani uchun `availability`da
      // chiqmaydi — ularni ro'yxatga qo'lda qo'shamiz, aks holda
      // mehmon allaqachon o'tirgan stolni ko'rsatib bo'lmaydi.
      final merged = <String, ZalTable>{for (final t in free) t.id: t};
      for (final t in widget.booking.tables) {
        merged.putIfAbsent(
          t.id,
          () => ZalTable(id: t.id, number: t.number, seats: t.seats, description: t.description, bookableInApp: true, state: TableState.bosh),
        );
      }
      if (!mounted) return;
      setState(() => _options = merged.values.toList()..sort((a, b) => a.number.compareTo(b.number)));
    } catch (_) {
      // Bo'sh ro'yxat bilan qoldiramiz — pastda xabar ko'rsatiladi.
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stolni berish/almashtirish', style: GoogleFonts.unbounded(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Gap(4.h),
            Text(
              '${widget.booking.guests} kishilik bron uchun bo\'sh stollar. Bir nechtasini tanlash mumkin.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary),
            ),
            Gap(16.h),
            if (_isLoading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
            else if (_options.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text('Bu vaqtga bo\'sh stol yo\'q', style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
              )
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _options.map((t) {
                  final isSelected = _selected.contains(t.id);
                  final isCurrent = widget.booking.tables.any((bt) => bt.id == t.id);
                  return ChoiceChip(
                    label: Text('Stol ${t.number} · ${t.seats} o\'rin${isCurrent ? ' (joriy)' : ''}'),
                    selected: isSelected,
                    onSelected: (_) => _toggle(t.id),
                  );
                }).toList(),
              ),
            Gap(20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.toList()),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                child: Text('Tasdiqlash', style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
