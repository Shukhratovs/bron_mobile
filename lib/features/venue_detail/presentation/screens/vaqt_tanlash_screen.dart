import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../bookings/data/datasources/booking_remote_data_source.dart';
import '../../../bookings/data/repositories/booking_repository_impl.dart';
import '../../../bookings/domain/repositories/booking_repository.dart';
import '../../../venue/data/datasources/venue_remote_data_source.dart';
import '../../../venue/data/repositories/venue_repository_impl.dart';
import '../../../venue/domain/entities/availability_entity.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../../booking/presentation/screens/bind_card_screen.dart';
import '../../../booking/presentation/screens/booking_confirmed_screen.dart';
import 'slot_band_boldi_screen.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';

/// Figma: `Vaqt tanlang` (`857:1938`) — mijoz/01-vaqt-tanlash.md,
/// mijoz/02-bron-qilish.md, mijoz/03-depozit.md.
class VaqtTanlashScreen extends StatefulWidget {
  final VenueEntity venue;
  final String? initialTime;
  final VenueRepository? venueRepository;
  final BookingRepository? bookingRepository;

  const VaqtTanlashScreen({
    super.key,
    required this.venue,
    this.initialTime,
    this.venueRepository,
    this.bookingRepository,
  });

  @override
  State<VaqtTanlashScreen> createState() => _VaqtTanlashScreenState();
}

class _VaqtTanlashScreenState extends State<VaqtTanlashScreen> {
  late final VenueRepository _venueRepository;
  late final BookingRepository _bookingRepository;

  List<AvailabilityDay> _days = [];
  AvailabilityResult? _slots;
  bool _isLoadingDays = true;
  bool _isLoadingSlots = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  int _guests = 2;
  late DateTime _selectedDate;
  String? _selectedTime;
  String? _selectedZoneId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _venueRepository = widget.venueRepository ??
        VenueRepositoryImpl(remoteDataSource: VenueRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _bookingRepository = widget.bookingRepository ??
        BookingRepositoryImpl(remoteDataSource: BookingRemoteDataSourceImpl(apiClient: AppSession.apiClient));
    _loadDays();
    _loadSlots();
  }

  String get _dateParam =>
      '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadDays() async {
    setState(() => _isLoadingDays = true);
    final result = await _venueRepository.getAvailabilityDays(widget.venue.id, guests: _guests, days: 7);
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
      widget.venue.id,
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
          if (widget.initialTime != null &&
              _selectedTime == null &&
              data.slots.any((s) => s.time == widget.initialTime && s.available)) {
            _selectedTime = widget.initialTime;
          }
        });
      case Failure(:final exception):
        setState(() {
          _errorMessage = exception.code == 'venue_not_found' ? 'Muassasa topilmadi' : exception.message;
          _isLoadingSlots = false;
        });
    }
  }

  void _onGuestsChanged(int value) {
    setState(() {
      _guests = value;
      _selectedZoneId = null;
    });
    _loadDays();
    _loadSlots();
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _loadSlots();
  }

  void _onZoneChanged(String? zoneId) {
    setState(() => _selectedZoneId = zoneId);
    _loadSlots();
  }

  Future<void> _pickFromCalendar() async {
    final advanceDays = _slots?.settings.advanceDays ?? 30;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: advanceDays)),
    );
    if (picked != null) _onDateChanged(picked);
  }

  void _onSlotTap(AvailabilitySlot slot) {
    if (!slot.available) {
      final (h, m) = _parseTime(slot.time);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotBandBoldiScreen(
            venue: widget.venue,
            date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, m),
            time: slot.time,
            guests: _guests,
          ),
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedTime = slot.time);
  }

  (int, int) _parseTime(String time) {
    final parts = time.split(':');
    return (int.tryParse(parts[0]) ?? 0, int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  Future<void> _confirmBooking({String? cardId}) async {
    final time = _selectedTime;
    if (time == null) return;
    if (cardId == null && !await ensureLoggedIn(context)) return;
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    final (h, m) = _parseTime(time);
    final startsAt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, m);

    final result = await _bookingRepository.createBooking(
      venueId: widget.venue.id,
      startsAt: startsAt,
      guests: _guests,
      zoneId: _selectedZoneId,
      cardId: cardId,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success(:final data):
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmedScreen(
              booking: data,
              venueName: widget.venue.name,
              venueAddress: widget.venue.address,
            ),
          ),
        );
      case Failure(:final exception):
        if (exception.code == 'no_table_available') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SlotBandBoldiScreen(
                venue: widget.venue,
                date: startsAt,
                time: time,
                guests: _guests,
              ),
            ),
          );
        } else if (exception.code == 'card_required') {
          final newCardId = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const BindCardScreen()),
          );
          if (newCardId != null && mounted) {
            _confirmBooking(cardId: newCardId);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(exception.message), backgroundColor: AppColors.error),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = _slots;
    final maxSeatsExceeded = slots?.maxSeats != null && _guests > slots!.maxSeats!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const AppIcon(AppAssets.iconArrowLeftSLine, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vaqt tanlang',
          style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venue.name,
              style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Gap(18.h),

            // Days ribbon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QAYSI KUN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: _pickFromCalendar,
                  child: Text(
                    'Taqvim',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            Gap(8.h),
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
                                  _dayLabel(day.date, index),
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
            Gap(18.h),

            // Zone chips (faqat slotlar kelgach — zones shu javobdan keladi)
            if (slots != null && slots.zones.isNotEmpty) ...[
              Text(
                'QAYSI JOYDA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Gap(8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _zoneChip(null, 'Farqi yo\'q'),
                    ...([...slots.zones]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
                        .map((z) => _zoneChip(z.id, z.name)),
                  ],
                ),
              ),
              Gap(18.h),
            ],

            // Guest count
            Text(
              'MEHMONLAR SONI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            Gap(8.h),
            Row(
              children: List.generate(6, (index) {
                final count = index + 1;
                final isSelected = count == _guests;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onGuestsChanged(count),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
                      ),
                      child: Center(
                        child: Text(
                          count == 6 ? '6+' : '$count',
                          style: GoogleFonts.unbounded(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Gap(18.h),

            // Slots
            Text(
              'BO\'SH VAQTLAR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            Gap(8.h),
            _buildSlotsArea(maxSeatsExceeded),

            if (slots != null && slots.deposit.required && !maxSeatsExceeded && !(slots.closed)) ...[
              Gap(14.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: const Color(0xFFFFF2ED), borderRadius: BorderRadius.circular(12.r)),
                child: Row(
                  children: [
                    AppIcon(AppAssets.iconShieldCheckLine, color: AppColors.primary, size: 18.r),
                    Gap(8.w),
                    Expanded(
                      child: Text(
                        'Bu vaqtlarda depozit kartada bloklanadi${slots.deposit.amount != null ? ' — ${formatSom(slots.deposit.amount!)}' : ''}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Gap(20.h),
            AppButton.primary(
              text: _selectedTime != null
                  ? '${formatDateShort(_selectedDate)} $_selectedTime • $_guests kishi - davom etish'
                  : 'Vaqtni tanlang',
              isLoading: _isSubmitting,
              onPressed: _selectedTime == null || maxSeatsExceeded ? null : () => _confirmBooking(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsArea(bool maxSeatsExceeded) {
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
    final slots = _slots;
    if (slots == null) return const SizedBox.shrink();
    if (slots.closed) {
      return _infoBox('Bu kuni yopiq', Icons.event_busy_outlined);
    }
    if (maxSeatsExceeded) {
      return _infoBox(
        'Eng katta stol — ${slots.maxSeats} kishi · katta kompaniya uchun zal bor',
        Icons.groups_outlined,
      );
    }
    if (slots.slots.isEmpty) {
      return _infoBox('Bo\'sh vaqt yo\'q', Icons.schedule_outlined);
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: slots.slots.map((slot) {
        final isSelected = slot.time == _selectedTime;
        return GestureDetector(
          onTap: () => _onSlotTap(slot),
          child: Container(
            width: 78.w,
            padding: EdgeInsets.symmetric(vertical: 9.h),
            decoration: BoxDecoration(
              color: !slot.available
                  ? const Color(0xFFF3F4F6)
                  : isSelected
                      ? AppColors.primary
                      : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: !slot.available
                    ? const Color(0xFFE5E7EB)
                    : isSelected
                        ? AppColors.primary
                        : const Color(0xFFE5E7EB),
              ),
            ),
            child: Center(
              child: Text(
                slot.time,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: !slot.available
                      ? AppColors.textMuted
                      : isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                  decoration: slot.available ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoBox(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20.r),
          Gap(10.w),
          Expanded(child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _zoneChip(String? id, String label) {
    final isSelected = id == _selectedZoneId;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
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
      ),
    );
  }

  String _dayLabel(DateTime date, int index) {
    if (index == 0) return 'Bugun';
    if (index == 1) return 'Erta';
    return weekdayShort(date);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
