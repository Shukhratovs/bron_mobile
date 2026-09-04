import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../bookings/data/datasources/booking_remote_data_source.dart';
import '../../../bookings/data/models/booking_qr_model.dart';
import '../../../bookings/data/repositories/booking_repository_impl.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/domain/repositories/booking_repository.dart';
import '../../../main/presentation/screens/main_navigation_screen.dart';
import '../../../../core/widgets/app_toast.dart';

class BookingConfirmedScreen extends StatefulWidget {
  final BookingEntity booking;
  final String venueName;
  final String? venueAddress;
  final BookingRepository? repository;

  const BookingConfirmedScreen({
    super.key,
    required this.booking,
    required this.venueName,
    this.venueAddress,
    this.repository,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  late final BookingRepository _repository;
  BookingQrModel? _qr;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        BookingRepositoryImpl(
          remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
    _loadQr();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQr() async {
    final result = await _repository.getBookingQr(widget.booking.id);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() => _qr = data);
      _refreshTimer?.cancel();
      _refreshTimer = Timer(Duration(seconds: data.expiresIn), _loadQr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Gap(20.h),
              // Success Icon Circle
              Container(
                width: 68.r,
                height: 68.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38.r,
                  ),
                ),
              ),
              Gap(16.h),

              // Title & Subtitle
              Text(
                'Bron tasdiqlandi',
                style: GoogleFonts.unbounded(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(6.h),
              Text(
                'Kelganingizda QR kodni xodimga ko\'rsating',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Gap(24.h),

              // QR Code Box
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_qr == null)
                      SizedBox(
                        width: 160.r,
                        height: 160.r,
                        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      )
                    else
                      QrImageView(
                        data: _qr!.token,
                        size: 160.r,
                        backgroundColor: Colors.white,
                      ),
                    Gap(8.h),
                    Text(
                      booking.code,
                      style: GoogleFonts.unbounded(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      '30 soniyada yangilanadi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(20.h),

              // Details Summary Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Restoran', widget.venueName),
                    const Divider(color: Color(0xFFF0F0F0), height: 20),
                    _buildInfoRow(
                      'Sana va vaqt',
                      '${formatDateLong(booking.startsAt.toLocal())} • ${formatTime(booking.startsAt.toLocal())}',
                    ),
                    const Divider(color: Color(0xFFF0F0F0), height: 20),
                    _buildInfoRow('Mehmonlar', '${booking.guests} kishi'),
                    const Divider(color: Color(0xFFF0F0F0), height: 20),
                    _buildInfoRow('Stol', booking.tableLabel.isEmpty ? '—' : booking.tableLabel),
                    if (booking.depositAmount != null) ...[
                      const Divider(color: Color(0xFFF0F0F0), height: 20),
                      _buildInfoRow('Depozit', formatSom(booking.depositAmount!)),
                    ],
                  ],
                ),
              ),
              Gap(16.h),

              // Quick Actions (Kalendarga, Xaritada, Ulashish)
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.calendar_today_rounded,
                    label: 'Kalendarga',
                    onTap: () {
                      AppToast.success(context, 'Taqvimga muvaffaqiyatli saqlandi');
                    },
                  ),
                  Gap(10.w),
                  _buildActionButton(
                    icon: Icons.map_outlined,
                    label: 'Xaritada',
                    onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                  Gap(10.w),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Ulashish',
                    onTap: () {
                      Clipboard.setData(ClipboardData(
                        text: '${widget.venueName} • ${booking.code} • ${formatDateLong(booking.startsAt.toLocal())} ${formatTime(booking.startsAt.toLocal())}',
                      ));
                      AppToast.info(context, 'Havola nusxalandi');
                    },
                  ),
                ],
              ),
              Gap(28.h),

              // Done Button
              AppButton.primary(
                text: 'Tayyor',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20.r),
              Gap(4.h),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
