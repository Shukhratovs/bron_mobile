import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../main/presentation/screens/main_navigation_screen.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../waitlist/data/datasources/waitlist_remote_data_source.dart';
import '../../../waitlist/data/repositories/waitlist_repository_impl.dart';
import '../../../waitlist/domain/repositories/waitlist_repository.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/constants/app_assets.dart';

/// Figma: `Navbatga yozilish` (`210:1407`) — mijoz/05-navbat.md.
class NavbatgaYozilishScreen extends StatefulWidget {
  final VenueEntity venue;
  final DateTime initialDate;
  final int guests;
  final WaitlistRepository? repository;

  const NavbatgaYozilishScreen({
    super.key,
    required this.venue,
    required this.initialDate,
    required this.guests,
    this.repository,
  });

  @override
  State<NavbatgaYozilishScreen> createState() => _NavbatgaYozilishScreenState();
}

enum _Interval { oneHour, twoHour, anytime }

class _NavbatgaYozilishScreenState extends State<NavbatgaYozilishScreen> {
  late final WaitlistRepository _repository;
  _Interval _selected = _Interval.oneHour;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        WaitlistRepositoryImpl(
          remoteDataSource: WaitlistRemoteDataSourceImpl(apiClient: AppSession.apiClient),
        );
  }

  (DateTime, DateTime) _range() {
    final base = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
      widget.initialDate.hour,
      widget.initialDate.minute,
    );
    switch (_selected) {
      case _Interval.oneHour:
        return (base, base.add(const Duration(hours: 1)));
      case _Interval.twoHour:
        return (base, base.add(const Duration(hours: 2)));
      case _Interval.anytime:
        final dayStart = DateTime(base.year, base.month, base.day, 10);
        final dayEnd = DateTime(base.year, base.month, base.day, 23);
        return (dayStart, dayEnd);
    }
  }

  Future<void> _submit() async {
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;
    setState(() => _isLoading = true);
    final (from, to) = _range();
    final result = await _repository.join(
      venueId: widget.venue.id,
      guests: widget.guests,
      desiredFrom: from,
      desiredTo: to,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navbatga yozildingiz — stol bo\'shashi bilan xabar beramiz'),
            backgroundColor: Color(0xFF12B76A),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen(initialIndex: 2)),
          (route) => false,
        );
      case Failure(:final exception):
        final message = switch (exception.code) {
          'already_in_waitlist' => 'Siz allaqachon shu joyning navbatidasiz',
          'party_too_large' => 'Kompaniyangiz eng katta stoldan katta',
          _ => exception.message,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Navbatga yozilish',
          style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venue.name,
              style: GoogleFonts.unbounded(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Gap(4.h),
            Text(
              '${widget.guests} kishi',
              style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            Gap(24.h),
            Text(
              'QANDAY VAQT MOS KELADI',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            Gap(10.h),
            _intervalTile(_Interval.oneHour, '${_hhmm(widget.initialDate)}–${_hhmm(widget.initialDate.add(const Duration(hours: 1)))}'),
            Gap(8.h),
            _intervalTile(_Interval.twoHour, '${_hhmm(widget.initialDate)}–${_hhmm(widget.initialDate.add(const Duration(hours: 2)))}'),
            Gap(8.h),
            _intervalTile(_Interval.anytime, 'Istalgan vaqt'),
            const Spacer(),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2ED),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Istalgan payt navbatdan chiqishingiz mumkin.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.primary),
              ),
            ),
            Gap(16.h),
            AppButton.primary(text: 'Navbatga yozilish', isLoading: _isLoading, onPressed: _submit),
          ],
        ),
      ),
    );
  }

  String _hhmm(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _intervalTile(_Interval value, String label) {
    final isSelected = value == _selected;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20.r,
            ),
            Gap(10.w),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
