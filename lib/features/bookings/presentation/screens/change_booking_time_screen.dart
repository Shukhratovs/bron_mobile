import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/availability_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

/// Figma: `Vaqtni o'zgartirish` (`105:722` oqimidagi ekran) — mavjud bron
/// uchun yangi vaqt tanlashda ham (avvalgi `showTimePicker` kabi) haqiqiy
/// bo'sh/band slotlarni ko'rsatadi, depozit talab qilinsa har bir chipda
/// belgi qo'yadi (mijoz/01-vaqt-tanlash.md §"Depozit": `required: true`
/// bo'lsa hamma chipga belgi qo'yiladi, slot darajasida emas).
class ChangeBookingTimeScreen extends StatefulWidget {
  final BookingEntity booking;
  final String venueId;
  final VenueRepository? venueRepository;
  final BookingRepository? bookingRepository;

  const ChangeBookingTimeScreen({
    super.key,
    required this.booking,
    required this.venueId,
    this.venueRepository,
    this.bookingRepository,
  });

  @override
  State<ChangeBookingTimeScreen> createState() => _ChangeBookingTimeScreenState();
}

class _ChangeBookingTimeScreenState extends State<ChangeBookingTimeScreen> {
  late final VenueRepository _venueRepository;
  late final BookingRepository _bookingRepository;

  List<AvailabilityDay> _days = [];
  AvailabilityResult? _slots;
  bool _isLoadingDays = true;
  bool _isLoadingSlots = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  late DateTime _selectedDate;
  String? _selectedTime;
  String? _selectedZoneId;

  @override
  void initState() {
    super.initState();
    final localStart = widget.booking.startsAt.toLocal();
    _selectedDate = DateTime(localStart.year, localStart.month, localStart.day);
    _selectedZoneId = widget.booking.zoneId;
    _venueRepository = widget.venueRepository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _bookingRepository = widget.bookingRepository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _loadDays();
    _loadSlots();
  }

  int get _guests => widget.booking.guests;

  String get _dateParam =>
      '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isCurrentSlot(String time) {
    final localStart = widget.booking.startsAt.toLocal();
    return _isSameDay(_selectedDate, localStart) && time == formatTime(localStart);
  }

  Future<void> _loadDays() async {
    setState(() => _isLoadingDays = true);
    final result = await _venueRepository.getAvailabilityDays(widget.venueId, guests: _guests, days: 7);
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        _days = data;
        _isLoadingDays = false;
      });
    } else {
      setState(() => _isLoadingDays = false);
    }
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _errorMessage = null;
      _selectedTime = null;
    });
    final result = await _venueRepository.getAvailability(
      widget.venueId,
      date: _dateParam,
      guests: _guests,
      zoneId: _selectedZoneId,
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        setState(() {
          _slots = data;
          _isLoadingSlots = false;
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.message;
          _isLoadingSlots = false;
        });
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _loadSlots();
  }

  void _onZoneChanged(String? zoneId) {
    setState(() => _selectedZoneId = zoneId);
    _loadSlots();
  }

  void _onSlotTap(AvailabilitySlot slot) {
    if (!slot.available || _isCurrentSlot(slot.time)) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedTime = slot.time);
  }

  (int, int) _parseTime(String time) {
    final parts = time.split(':');
    return (int.tryParse(parts[0]) ?? 0, int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  Future<void> _submit() async {
    final time = _selectedTime;
    if (time == null) return;
    setState(() => _isSubmitting = true);
    final (h, m) = _parseTime(time);
    final newStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, m);

    final result = await _bookingRepository.changeBookingTime(widget.booking.id, newStart);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        Navigator.pop(context, true);
      case Failure(:final exception):
        final message = exception.code == 'no_table_available' ? AppStrings.noFreeSlots : exception.message;
        AppToast.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = _slots;
    final canSubmit = _selectedTime != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.changeTimeTitle,
          style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _currentBookingCard(),
            Gap(14.h),
            _newTimeCard(slots),
            if (slots != null && slots.zones.isNotEmpty) ...[
              Gap(14.h),
              _zoneCard(slots),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: AppButton.primary(
            text: _selectedTime != null
                ? '${_dayLabel(_selectedDate)} $_selectedTime ${AppStrings.changeToTimeButton}'
                : AppStrings.selectTimeSlot,
            isLoading: _isSubmitting,
            onPressed: canSubmit ? _submit : null,
          ),
        ),
      ),
    );
  }

  Widget _currentBookingCard() {
    final localStart = widget.booking.startsAt.toLocal();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.event_outlined, color: AppColors.textSecondary, size: 20.r),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentBookingLabel,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: AppColors.textMuted),
                ),
                Gap(2.h),
                Text(
                  '${formatDateShort(localStart)}, ${formatTime(localStart)} · $_guests ${AppStrings.persons}'
                  '${widget.booking.tableLabel.isEmpty ? '' : ' · ${widget.booking.tableLabel}'}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _newTimeCard(AvailabilityResult? slots) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectNewTime,
            style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          Gap(12.h),
          _isLoadingDays
              ? SizedBox(
                  height: 62.h,
                  child: AppShimmer(
                    child: Row(
                      children: List.generate(
                        5,
                        (i) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: const ShimmerBox(width: 56, height: 62, radius: 14),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 62.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    separatorBuilder: (context, index) => Gap(8.w),
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final isSelected = _isSameDay(day.date, _selectedDate);
                      return GestureDetector(
                        onTap: () => _onDateChanged(day.date),
                        child: Container(
                          width: 58.w,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _dayLabel(day.date, index: index),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : day.hasFreeSlots
                                          ? AppColors.textSecondary
                                          : AppColors.textMuted,
                                ),
                              ),
                              Gap(2.h),
                              Text(
                                '${day.date.day}',
                                style: GoogleFonts.unbounded(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : day.hasFreeSlots
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          Gap(14.h),
          _buildSlotsArea(slots),
          if (slots != null && slots.deposit.required && !_isLoadingSlots) ...[
            Gap(12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12.r)),
              child: Row(
                children: [
                  AppIcon(AppAssets.iconWallet3Line, color: AppColors.primary, size: 16.r),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      '${AppStrings.depositBlocked}${slots.deposit.amount != null ? ' — ${formatSom(slots.deposit.amount!)}' : ''}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _zoneCard(AvailabilityResult slots) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.whichZone,
            style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
          ),
          Gap(10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _zoneChip(null, AppStrings.anyZone),
              ...([...slots.zones]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder))).map((z) => _zoneChip(z.id, z.name)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoneChip(String? id, String label) {
    final isSelected = id == _selectedZoneId;
    return GestureDetector(
      onTap: () => _onZoneChanged(id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsArea(AvailabilityResult? slots) {
    if (_isLoadingSlots) {
      return SizedBox(
        height: 80.h,
        child: AppShimmer(
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(6, (i) => const ShimmerBox.pill(width: 74, height: 38)),
          ),
        ),
      );
    }
    if (_errorMessage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(_errorMessage!, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.error)),
      );
    }
    if (slots == null) return const SizedBox.shrink();
    if (slots.closed) {
      return _infoBox(AppStrings.closedToday);
    }
    if (slots.slots.isEmpty) {
      return _infoBox(AppStrings.noFreeSlots);
    }
    final showDepositMark = slots.deposit.required;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: slots.slots.map((slot) {
        final isCurrent = _isCurrentSlot(slot.time);
        final isSelected = slot.time == _selectedTime;
        final isDisabled = !slot.available || isCurrent;
        return GestureDetector(
          onTap: () => _onSlotTap(slot),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: isDisabled
                  ? const Color(0xFFF3F4F6)
                  : isSelected
                      ? AppColors.primary
                      : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDisabled
                    ? const Color(0xFFE5E7EB)
                    : isSelected
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDepositMark && !isDisabled) ...[
                  AppIcon(
                    AppAssets.iconWallet3Line,
                    size: 12.r,
                    color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppColors.primary,
                  ),
                  Gap(4.w),
                ],
                Text(
                  slot.time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isDisabled
                        ? AppColors.textMuted
                        : isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                    decoration: !slot.available ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, color: AppColors.textSecondary, size: 20.r),
          Gap(10.w),
          Expanded(child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date, {int? index}) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return AppStrings.today;
    if (_isSameDay(date, now.add(const Duration(days: 1)))) return AppStrings.tomorrow;
    return weekdayShort(date);
  }
}
