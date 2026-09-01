import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';
import '../../../core/staff_session.dart';
import '../../data/datasources/staff_booking_remote_data_source.dart';
import '../../data/repositories/staff_booking_repository_impl.dart';
import '../../domain/repositories/staff_booking_repository.dart';
import 'staff_booking_detail_screen.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';

/// Figma: `Qo'lda qidirish` (`772:972`) — QR bo'lmaganda telefon yoki
/// BRN- kodi bo'yicha.
class ManualSearchScreen extends StatefulWidget {
  final StaffBookingRepository? repository;

  const ManualSearchScreen({super.key, this.repository});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  late final StaffBookingRepository _repository;
  final TextEditingController _controller = TextEditingController();
  List<BookingEntity> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        StaffBookingRepositoryImpl(remoteDataSource: StaffBookingRemoteDataSourceImpl(apiClient: StaffSession.apiClient));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() => _isLoading = true);
    final result = await _repository.getBookings(q: q);
    if (!mounted) return;
    setState(() {
      _results = result.dataOrNull ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Qo\'lda qidirish', style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Telefon yoki BRN- kodi',
                prefixIcon: const AppIcon(AppAssets.iconSearch),
                suffixIcon: IconButton(icon: const AppIcon(AppAssets.iconArrowRightLine), onPressed: _search),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _results.length,
              separatorBuilder: (context, index) => Gap(10.h),
              itemBuilder: (context, index) {
                final b = _results[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: b.id, repository: _repository))),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: const Color(0xFFECEFF3))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.guestName, style: GoogleFonts.plusJakartaSans(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              Text('${b.code} · ${formatTime(b.startsAt.toLocal())} · ${b.guests} kishi', style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        AppIcon(AppAssets.iconArrowRightSLine, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
