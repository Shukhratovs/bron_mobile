import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/utils/uz_phone_formatter.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../waitlist/data/models/waitlist_model.dart';
import '../../../../waitlist/domain/entities/waitlist_entity.dart';
import '../../../bookings/presentation/screens/staff_booking_detail_screen.dart';
import '../../../core/staff_session.dart';
import '../../../zal/data/datasources/staff_zal_remote_data_source.dart';
import '../../data/datasources/staff_waitlist_remote_data_source.dart';
import '../../data/repositories/staff_waitlist_repository_impl.dart';
import '../../domain/repositories/staff_waitlist_repository.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../../core/widgets/app_toast.dart';

/// Figma: `Navbat` (`305:488`), `Navbat · buyurtma` (`1167:1703`),
/// `Navbatga qo'shish` (`785:1078`), `Mehmonni chaqirish` (`785:1154`).
class StaffNavbatScreen extends StatefulWidget {
  final StaffWaitlistRepository? repository;

  const StaffNavbatScreen({super.key, this.repository});

  @override
  State<StaffNavbatScreen> createState() => _StaffNavbatScreenState();
}

class _StaffNavbatScreenState extends State<StaffNavbatScreen> {
  late final StaffWaitlistRepository _repository;
  late final StaffZalRemoteDataSource _zalDataSource;
  int _tab = 0; // 0 jonli, 1 buyurtma
  WaitlistListResult _result = const WaitlistListResult(items: []);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        StaffWaitlistRepositoryImpl(remoteDataSource: StaffWaitlistRemoteDataSourceImpl(apiClient: StaffSession.apiClient));
    _zalDataSource = StaffZalRemoteDataSourceImpl(apiClient: StaffSession.apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _repository.getWaitlist(kind: _tab == 0 ? 'jonli' : 'buyurtma');
    if (!mounted) return;
    if (result case Success(:final data)) setState(() => _result = data);
    setState(() => _isLoading = false);
  }

  void _addGuest() {
    if (_tab != 0) return; // faqat jonli navbatga qo'shish mumkin
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    int guests = 2;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Navbatga qo\'shish', style: GoogleFonts.unbounded(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Gap(14.h),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Ism')),
              Gap(10.h),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  UzPhoneInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Telefon (ixtiyoriy)',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Center(widthFactor: 1, child: Text('+998')),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
              Gap(10.h),
              Row(
                children: List.generate(6, (i) {
                  final count = i + 1;
                  final selected = count == guests;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => guests = count),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(color: selected ? AppColors.primary : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8.r)),
                        child: Center(child: Text(count == 6 ? '6+' : '$count', style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  );
                }),
              ),
              Gap(16.h),
              AppButton.primary(
                text: 'Qo\'shish',
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await _repository.add(
                    guestName: nameController.text.trim().isEmpty ? 'Mehmon' : nameController.text.trim(),
                    guests: guests,
                    guestPhone: uzPhoneToE164(phoneController.text.trim()),
                    idempotencyKey: newIdempotencyKey(),
                  );
                  if (!mounted) return;
                  if (result case Failure(:final exception)) {
                    AppToast.error(context, exception.message);
                  }
                  _load();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _call(WaitlistEntity entry) async {
    final result = await _repository.call(entry.id, idempotencyKey: newIdempotencyKey());
    if (!mounted) return;
    if (result case Failure(:final exception)) {
      AppToast.error(context, exception.message);
    }
    _load();
  }

  Future<void> _remove(WaitlistEntity entry) async {
    final result = await _repository.remove(entry.id, idempotencyKey: newIdempotencyKey());
    if (!mounted) return;
    if (result case Failure(:final exception)) {
      AppToast.error(context, exception.message);
    }
    _load();
  }

  Future<void> _seatPrompt(WaitlistEntity entry) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    List<ZalTable> tables;
    try {
      tables = await _zalDataSource.getAvailability(date: dateStr, guests: entry.guests);
    } catch (_) {
      tables = const [];
    }
    if (!mounted) return;

    final tableId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qaysi stolga joylashtirasiz?', style: GoogleFonts.unbounded(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Gap(14.h),
              if (tables.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text('Bo\'sh stol topilmadi', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                )
              else
                ...tables.map((t) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const AppIcon(AppAssets.iconTableLine, color: AppColors.primary),
                      title: Text('Stol ${t.number}'),
                      subtitle: Text('${t.seats} o\'rin'),
                      onTap: () => Navigator.pop(context, t.id),
                    )),
            ],
          ),
        ),
      ),
    );
    if (tableId == null || tableId.isEmpty || !mounted) return;
    final result = await _repository.seat(entry.id, tableId, idempotencyKey: newIdempotencyKey());
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        if (data.bookingId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: data.bookingId!)));
        }
        _load();
      case Failure(:final exception):
        AppToast.error(context, exception.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(child: Text('Navbat', style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  if (_tab == 0) IconButton(onPressed: _addGuest, icon: const AppIcon(AppAssets.iconAddCircleLine, color: AppColors.primary)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(child: _tabButton('Jonli navbat', 0)),
                  Gap(8.w),
                  Expanded(child: _tabButton('Buyurtma', 1)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Text('Navbatda · ${_result.waiting ?? _result.items.length}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary)),
                  if (_result.averageWaitMinutes != null) ...[
                    Gap(12.w),
                    Text('O\'rtacha kutish · ~${_result.averageWaitMinutes} daq', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 5))
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      itemCount: _result.items.length,
                      separatorBuilder: (context, index) => Gap(10.h),
                      itemBuilder: (context, index) => _waitlistCard(_result.items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () {
        if (_tab == index) return;
        setState(() => _tab = index);
        _load();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB))),
        child: Center(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textPrimary))),
      ),
    );
  }

  Widget _waitlistCard(WaitlistEntity entry) {
    final isCalled = entry.status == WaitlistStatus.chaqirilgan;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: const Color(0xFFECEFF3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                child: Text('${entry.position}', style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, fontWeight: FontWeight.w700)),
              ),
              Gap(10.w),
              Expanded(
                child: Text(entry.guestName ?? 'Mehmon', style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              Text('${entry.guests} kishi', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary)),
            ],
          ),
          Gap(6.h),
          Text(
            isCalled ? 'Chaqirilgan · ${entry.offeredTable ?? ''}' : '${entry.waitingMinutes} daq kutmoqda · ~${entry.estimatedWaitMinutes} daq',
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary),
          ),
          Gap(10.h),
          Row(
            children: [
              if (!isCalled)
                Expanded(child: OutlinedButton(onPressed: () => _call(entry), child: const Text('Chaqirish')))
              else
                Expanded(child: ElevatedButton(onPressed: () => _seatPrompt(entry), child: const Text('Joylashtirish'))),
              Gap(8.w),
              IconButton(onPressed: () => _remove(entry), icon: const AppIcon(AppAssets.iconCloseLine, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
