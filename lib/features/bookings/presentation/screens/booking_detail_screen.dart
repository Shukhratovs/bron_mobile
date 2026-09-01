import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../venue_detail/data/datasources/review_remote_data_source.dart';
import '../../../venue_detail/data/repositories/review_repository_impl.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/models/booking_qr_model.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  final BookingRepository? repository;
  final VenueRepository? venueRepository;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    this.repository,
    this.venueRepository,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late final BookingRepository _repository;
  late final VenueRepository _venueRepository;
  late final ReviewRepository _reviewRepository;

  BookingEntity? _booking;
  VenueEntity? _venue;
  BookingQrModel? _qr;
  Timer? _qrTimer;
  bool _isLoading = true;
  String? _errorMessage;
  bool _reviewSubmitted = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _venueRepository = widget.venueRepository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _reviewRepository = ReviewRepositoryImpl(remoteDataSource: ReviewRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _load();
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _repository.getBookingById(widget.bookingId);
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _booking = data;
          _isLoading = false;
        });
        _venueRepository.getVenueById(data.venueId).then((r) {
          if (!mounted) return;
          if (r case Success(:final data)) setState(() => _venue = data);
        });
        if (data.status == BookingStatus.kutilmoqda || data.status == BookingStatus.kechikmoqda) {
          _loadQr();
        }
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoading = false;
        });
    }
  }

  Future<void> _loadQr() async {
    final result = await _repository.getBookingQr(widget.bookingId);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() => _qr = data);
      _qrTimer?.cancel();
      _qrTimer = Timer(Duration(seconds: data.expiresIn), _loadQr);
    }
  }

  bool get _canCancel =>
      _booking != null &&
      (_booking!.status == BookingStatus.kutilmoqda || _booking!.status == BookingStatus.kechikmoqda);

  void _showCancelSheet() {
    final booking = _booking;
    if (booking == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2.r))),
              Gap(20.h),
              Text('Bronni bekor qilish', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
              Gap(8.h),
              Text(
                _venue?.cancelWindowHours != null
                    ? 'Rostdan ham bronni bekor qilmoqchimisiz? ${_venue!.cancelWindowHours} soat oldin bekor qilsangiz depozit blokdan chiqadi.'
                    : 'Rostdan ham bronni bekor qilmoqchimisiz?',
                style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: const Color(0xFF6B7280), height: 1.4),
                textAlign: TextAlign.center,
              ),
              Gap(24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final result = await _repository.cancelBooking(booking.id);
                    if (!mounted) return;
                    if (result.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bron bekor qilindi'), backgroundColor: Color(0xFFDC3009)),
                      );
                      _load();
                    } else if (result case Failure(:final exception)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message)));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3009),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('Ha, bekor qilish', style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              Gap(10.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Orqaga', style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: const Color(0xFF6B7280))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showChangeTimeSheet() async {
    final booking = _booking;
    if (booking == null) return;
    final localStart = booking.startsAt.toLocal();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: localStart.hour, minute: localStart.minute),
    );
    if (picked == null || !mounted) return;

    final newStart = DateTime(localStart.year, localStart.month, localStart.day, picked.hour, picked.minute);
    final result = await _repository.changeBookingTime(booking.id, newStart);
    if (!mounted) return;
    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vaqt muvaffaqiyatli o\'zgartirildi'), backgroundColor: Color(0xFF12B76A)),
        );
        _load();
      case Failure(:final exception):
        final message = exception.code == 'no_table_available'
            ? 'Bu vaqtga bo\'sh stol yo\'q'
            : exception.message;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
    }
  }

  Future<void> _showReviewSheet() async {
    final booking = _booking;
    if (booking == null) return;
    int selectedRating = 5;
    final textController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2.r))),
                  ),
                  Gap(20.h),
                  Text('Sharh qoldirish', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
                  Gap(16.h),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return IconButton(
                          onPressed: () => setSheetState(() => selectedRating = star),
                          icon: Icon(
                            star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 32.r,
                          ),
                        );
                      }),
                    ),
                  ),
                  Gap(8.h),
                  TextField(
                    controller: textController,
                    maxLength: 1000,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Fikringizni yozing (ixtiyoriy)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  Gap(8.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        final result = await _reviewRepository.createReview(
                          booking.id,
                          rating: selectedRating,
                          text: textController.text.trim().isEmpty ? null : textController.text.trim(),
                        );
                        if (!mounted) return;
                        switch (result) {
                          case Success():
                            setState(() => _reviewSubmitted = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sharhingiz uchun rahmat!'), backgroundColor: Color(0xFF12B76A)),
                            );
                          case Failure(:final exception):
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message), backgroundColor: AppColors.error));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3009),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('Yuborish', style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white, body: DetailScreenSkeleton(heroHeight: 0));
    }
    if (_errorMessage != null || _booking == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(child: Text(_errorMessage ?? 'Bron topilmadi', style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textSecondary))),
      );
    }

    final booking = _booking!;
    final (statusLabel, statusBg, statusColor) = _statusStyle(booking.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftLine, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Bron tafsilotlari', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20))),
        actions: [
          if (_canCancel)
            TextButton(
              onPressed: _showCancelSheet,
              child: Text('Bekor qilish', style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFFDC3009))),
            ),
          Gap(6.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              // 1. Venue Card
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFECEFF3))),
                child: Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12.r)),
                      child: const AppIcon(AppAssets.iconBuilding4Line, color: Color(0xFF9CA3AF), size: 24),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _venue?.name ?? booking.code,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF181A20)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Gap(8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6.r)),
                                child: Text(statusLabel, style: GoogleFonts.plusJakartaSans(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: statusColor)),
                              ),
                            ],
                          ),
                          if (_venue?.address != null) ...[
                            Gap(3.h),
                            Text(_venue!.address!, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap(12.h),

              // 2. QR Code Card
              if (_qr != null || booking.status == BookingStatus.kutilmoqda || booking.status == BookingStatus.kechikmoqda)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: const Color(0xFFECEFF3))),
                  child: Column(
                    children: [
                      _qr == null
                          ? SizedBox(width: 160.r, height: 160.r, child: const Center(child: CircularProgressIndicator(color: AppColors.primary)))
                          : QrImageView(data: _qr!.token, size: 160.r, backgroundColor: Colors.white),
                      Gap(16.h),
                      Text(booking.code, style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: const Color(0xFF181A20))),
                      Gap(4.h),
                      Text('30 soniyada yangilanadi', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              Gap(12.h),

              // 3. Info Details Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFECEFF3))),
                child: Column(
                  children: [
                    _buildDetailRow('Sana', formatDateLong(booking.startsAt.toLocal())),
                    _buildDivider(),
                    _buildDetailRow('Vaqt', formatTime(booking.startsAt.toLocal())),
                    _buildDivider(),
                    _buildDetailRow('Mehmonlar', '${booking.guests} kishi'),
                    _buildDivider(),
                    _buildDetailRow('Stol', booking.tableLabel.isEmpty ? '—' : booking.tableLabel),
                    if (booking.depositAmount != null) _buildDepositBanner(booking),
                  ],
                ),
              ),

              if (booking.events.isNotEmpty) ...[
                Gap(12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFECEFF3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TARIX', style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF), letterSpacing: 0.5)),
                      Gap(10.h),
                      ...booking.events.where((e) => _eventLabel(e.type) != null).map((e) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 6.r, color: const Color(0xFFDC3009)),
                                Gap(8.w),
                                Expanded(child: Text(_eventLabel(e.type)!, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: const Color(0xFF374151)))),
                                if (e.createdAt != null)
                                  Text(formatTime(e.createdAt!.toLocal()), style: GoogleFonts.plusJakartaSans(fontSize: 11.5.sp, color: const Color(0xFF9CA3AF))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              Gap(90.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _canCancel
          ? Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: const Color(0xFFECEFF3)))),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _showChangeTimeSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3009),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text('Vaqtni o\'zgartirish', style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            )
          : (booking.status == BookingStatus.yakunlandi && !_reviewSubmitted)
              ? Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: const Color(0xFFECEFF3)))),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: _showReviewSheet,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC3009),
                          side: const BorderSide(color: Color(0xFFDC3009)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text('Sharh qoldirish', style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildDepositBanner(BookingEntity booking) {
    final (text, color) = switch (booking.depositStatus) {
      DepositStatus.bloklangan => ('${formatSom(booking.depositAmount!)} bloklandi', const Color(0xFF2563EB)),
      DepositStatus.hisobgaOtdi => ('Hisobingizga o\'tdi', const Color(0xFF12B76A)),
      DepositStatus.qaytarildi => ('Blok olib tashlandi', const Color(0xFF6B7280)),
      DepositStatus.ushlabQolindi => ('${formatSom(booking.depositAmount!)} hisobingizdan o\'tdi', const Color(0xFFD92D20)),
      _ => (null, Colors.transparent),
    };
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12.r)),
        child: Row(
          children: [
            AppIcon(AppAssets.iconBankCardLine, size: 16, color: color),
            Gap(6.w),
            Expanded(child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: color))),
          ],
        ),
      ),
    );
  }

  String? _eventLabel(String type) {
    switch (type) {
      case 'yaratildi':
        return 'Bron yaratildi';
      case 'keldi':
        return 'Xostes tomonidan kelgan deb belgilandi';
      case 'kelmadi':
        return 'Kelmadi deb belgilandi';
      case 'bekor':
        return 'Bron bekor qilindi';
      case 'yakunlandi':
        return 'Tashrif yakunlandi';
      case 'vaqt_ozgardi':
        return 'Vaqt o\'zgartirildi';
      default:
        return null;
    }
  }

  (String, Color, Color) _statusStyle(BookingStatus status) {
    switch (status) {
      case BookingStatus.kutilmoqda:
        return ('TASDIQLANDI', const Color(0xFFE6F9F0), const Color(0xFF12B76A));
      case BookingStatus.kechikmoqda:
        return ('KUTILMOQDA', const Color(0xFFFEF3EB), const Color(0xFFF79009));
      case BookingStatus.keldi:
        return ('KELDI', const Color(0xFFE6F9F0), const Color(0xFF12B76A));
      case BookingStatus.kelmadi:
        return ('KELMADI', const Color(0xFFFEE4E2), const Color(0xFFD92D20));
      case BookingStatus.bekor:
        return ('BEKOR QILINGAN', const Color(0xFFFEE4E2), const Color(0xFFD92D20));
      case BookingStatus.yakunlandi:
        return ('YAKUNLANDI', const Color(0xFFF3F4F6), const Color(0xFF6B7280));
      case BookingStatus.unknown:
        return ('—', const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp, color: const Color(0xFF6B7280))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF181A20))),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
}
