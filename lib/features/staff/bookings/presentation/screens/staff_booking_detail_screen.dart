import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';
import '../../../core/staff_session.dart';
import '../../data/datasources/staff_booking_remote_data_source.dart' show StaffBookingRemoteDataSourceImpl, newIdempotencyKey;
import '../../data/repositories/staff_booking_repository_impl.dart';
import '../../domain/repositories/staff_booking_repository.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';

/// Figma: `Bron detali` (`292:468`), `Mehmon kelmadi` (`787:1132`).
class StaffBookingDetailScreen extends StatefulWidget {
  final String bookingId;
  final StaffBookingRepository? repository;

  const StaffBookingDetailScreen({super.key, required this.bookingId, this.repository});

  @override
  State<StaffBookingDetailScreen> createState() => _StaffBookingDetailScreenState();
}

class _StaffBookingDetailScreenState extends State<StaffBookingDetailScreen> {
  late final StaffBookingRepository _repository;
  BookingEntity? _booking;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Set<BookingStatus> _allowed = {};

  static const _defaultTransitions = {
    BookingStatus.kutilmoqda: {BookingStatus.keldi, BookingStatus.kechikmoqda, BookingStatus.kelmadi, BookingStatus.bekor},
    BookingStatus.kechikmoqda: {BookingStatus.keldi, BookingStatus.kelmadi, BookingStatus.bekor},
    BookingStatus.keldi: {BookingStatus.yakunlandi},
  };

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        StaffBookingRepositoryImpl(remoteDataSource: StaffBookingRemoteDataSourceImpl(apiClient: StaffSession.apiClient));
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await _repository.getBookingById(widget.bookingId);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        _booking = data;
        _allowed = _defaultTransitions[data.status] ?? {};
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runAction(Future<ApiResult<BookingEntity>> Function() action) async {
    setState(() => _isSubmitting = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success(:final data):
        setState(() {
          _booking = data;
          _allowed = _defaultTransitions[data.status] ?? {};
        });
      case Failure(:final exception):
        if (exception.code == 'invalid_transition') {
          final allowedRaw = (exception.body?['allowed'] as List?)?.map((e) => e.toString()).toSet() ?? {};
          setState(() => _allowed = allowedRaw.map(BookingEntity.parseStatus).toSet());
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message), backgroundColor: AppColors.error));
    }
  }

  Future<void> _onArrive() async {
    final booking = _booking;
    if (booking == null) return;
    // Docs: "1 kishi kelmadi — stol 4 kishilik qoladi" — kelgan mehmonlar
    // soni bron qilingandan farq qilishi mumkin.
    var arrivedGuests = booking.guests;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nechchi kishi keldi?'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: arrivedGuests > 1 ? () => setDialogState(() => arrivedGuests--) : null,
                icon: const AppIcon(AppAssets.iconIndeterminateCircleLine),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$arrivedGuests', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                onPressed: arrivedGuests < booking.guests
                    ? () => setDialogState(() => arrivedGuests++)
                    : null,
                icon: const AppIcon(AppAssets.iconAddCircleLine),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tasdiqlash')),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    _runAction(() => _repository.arrive(widget.bookingId, arrivedGuests: arrivedGuests, idempotencyKey: newIdempotencyKey()));
  }

  void _onLate() => _runAction(() => _repository.late(widget.bookingId, idempotencyKey: newIdempotencyKey()));

  void _onNoShow() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _reasonSheet(
        title: 'Mehmon kelmadi',
        reasons: const [('mehmon_soradi', 'Mehmon o\'zi bekor qildi'), ('muassasa_sababli', 'Muassasa sababli'), ('kelmadi', 'Kelmadi')],
        onSelected: (reason) => _runAction(() => _repository.noShow(widget.bookingId, reason: reason, idempotencyKey: newIdempotencyKey())),
      ),
    );
  }

  void _onCancel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _reasonSheet(
        title: 'Bronni bekor qilish',
        reasons: const [('mehmon_soradi', 'Mehmon o\'zi bekor qildi'), ('muassasa_sababli', 'Muassasa sababli'), ('kelmadi', 'Kelmadi')],
        onSelected: (reason) => _runAction(() => _repository.cancel(widget.bookingId, reason: reason, idempotencyKey: newIdempotencyKey())),
      ),
    );
  }

  Widget _reasonSheet({required String title, required List<(String, String)> reasons, required void Function(String) onSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.unbounded(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Gap(14.h),
            ...reasons.map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.$2, style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, color: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(r.$1);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white, body: DetailScreenSkeleton(heroHeight: 0));
    }
    final booking = _booking;
    if (booking == null) {
      return Scaffold(backgroundColor: Colors.white, appBar: AppBar(), body: const Center(child: Text('Bron topilmadi')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(booking.code, style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFECEFF3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.guestName, style: GoogleFonts.unbounded(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (booking.guestPhone != null) ...[Gap(4.h), Text(booking.guestPhone!, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: AppColors.textSecondary))],
                  Gap(12.h),
                  _detailRow('Vaqt', '${formatDateShort(booking.startsAt.toLocal())} · ${formatTime(booking.startsAt.toLocal())}'),
                  _detailRow('Mehmonlar', '${booking.guests} kishi'),
                  _detailRow('Stol', booking.tableLabel.isEmpty ? '—' : booking.tableLabel),
                  _detailRow('Manba', booking.source),
                  if (booking.guestNote != null) _detailRow('Mehmon izohi', booking.guestNote!),
                  if (booking.staffNote != null) _detailRow('Ichki izoh', booking.staffNote!),
                ],
              ),
            ),
            Gap(14.h),
            _actionButtons(booking),
            if (booking.events.isNotEmpty) ...[
              Gap(14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFECEFF3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARIX', style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
                    Gap(10.h),
                    ...booking.events.map((e) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Icon(Icons.circle, size: 6.r, color: AppColors.primary),
                              Gap(8.w),
                              Expanded(child: Text('${e.type} · ${e.actorType}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textPrimary))),
                              if (e.createdAt != null) Text(formatTime(e.createdAt!.toLocal()), style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: AppColors.textMuted)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _actionButtons(BookingEntity booking) {
    if (_allowed.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        if (_allowed.contains(BookingStatus.keldi)) _actionChip('Mehmon keldi', const Color(0xFF12B76A), _isSubmitting ? null : _onArrive),
        if (_allowed.contains(BookingStatus.kechikmoqda)) _actionChip('Kechikmoqda', const Color(0xFFF79009), _isSubmitting ? null : _onLate),
        if (_allowed.contains(BookingStatus.kelmadi)) _actionChip('Kelmadi', const Color(0xFFD92D20), _isSubmitting ? null : _onNoShow),
        if (_allowed.contains(BookingStatus.bekor)) _actionChip('Bekor qilish', const Color(0xFF6B7280), _isSubmitting ? null : _onCancel),
        // `keldi -> yakunlandi` uchun alohida yozuv endpointi hujjatlarda
        // yo'q — ehtimol avtomatik (ends_at o'tgach) hisoblanadi.
      ],
    );
  }

  Widget _actionChip(String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12.r)),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
