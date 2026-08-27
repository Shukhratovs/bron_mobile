import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class MyBookingsScreen extends StatefulWidget {
  final ProfileRepository repository;

  const MyBookingsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<BookingEntity> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final result = await widget.repository.getMyBookings();
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        setState(() {
          _bookings = data;
          _isLoading = false;
        });
      case Failure():
        setState(() => _isLoading = false);
    }
  }

  void _showQrCodeDialog(BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                booking.venueName,
                style: GoogleFonts.unbounded(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(8.h),
              Text(
                booking.dateTime,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Gap(20.h),
              Container(
                width: 180.r,
                height: 180.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 140.r,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Gap(12.h),
              Text(
                booking.qrCode,
                style: GoogleFonts.unbounded(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Gap(20.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Yopish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: AppStrings.myBookings,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.surfaceLight,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: AppStrings.activeTab),
                Tab(text: AppStrings.historyTab),
                Tab(text: AppStrings.cancelledTab),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(
                        _bookings.where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending).toList(),
                      ),
                      _buildBookingsList(
                        _bookings.where((b) => b.status == BookingStatus.completed).toList(),
                      ),
                      _buildBookingsList(
                        _bookings.where((b) => b.status == BookingStatus.cancelled).toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<BookingEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 64.r, color: AppColors.textMuted),
            Gap(12.h),
            Text(
              AppStrings.noBookingsFound,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: items.length,
      separatorBuilder: (context, index) => Gap(12.h),
      itemBuilder: (context, index) {
        final booking = items[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(BookingEntity booking) {
    final (statusColor, statusBg, statusText) = switch (booking.status) {
      BookingStatus.confirmed => (AppColors.success, AppColors.successSoft, AppStrings.statusConfirmed),
      BookingStatus.pending => (AppColors.warning, AppColors.warningSoft, AppStrings.statusPending),
      BookingStatus.completed => (AppColors.info, AppColors.infoSoft, AppStrings.statusCompleted),
      BookingStatus.cancelled => (AppColors.error, AppColors.errorSoft, AppStrings.statusCancelled),
    };

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.venueName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Gap(4.h),
          Text(
            booking.venueCategory,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Gap(12.h),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16.r, color: AppColors.textMuted),
              Gap(6.w),
              Text(
                booking.dateTime,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Gap(16.w),
              Icon(Icons.people_outline_rounded, size: 16.r, color: AppColors.textMuted),
              Gap(6.w),
              Text(
                '${booking.guestCount} kishi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQrCodeDialog(booking),
                  icon: Icon(Icons.qr_code_rounded, size: 18.r),
                  label: Text(AppStrings.showQrCode),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    minimumSize: Size(double.infinity, 42.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
