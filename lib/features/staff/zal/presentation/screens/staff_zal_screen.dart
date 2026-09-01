import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';
import '../../../core/staff_session.dart';
import '../../data/datasources/staff_zal_remote_data_source.dart';

/// Zal ekrani veb-admin bilan bir xil API'dan foydalanadi
/// (`docs/frontend/veb-admin/02-zal-done.md`), lekin bu hujjat repoda
/// hozircha yo'q — shu sabab minimal, mavjud maydonlarga tayangan holda
/// ko'rsatiladi (`GET /staff/zal`, `GET /staff/zal/availability`).
class StaffZalScreen extends StatefulWidget {
  final StaffZalRemoteDataSource? dataSource;

  const StaffZalScreen({super.key, this.dataSource});

  @override
  State<StaffZalScreen> createState() => _StaffZalScreenState();
}

class _StaffZalScreenState extends State<StaffZalScreen> {
  late final StaffZalRemoteDataSource _dataSource;
  ZalSummary? _summary;
  List<Map<String, dynamic>> _tables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? StaffZalRemoteDataSourceImpl(apiClient: StaffSession.apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _dataSource.getZal();
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final tables = await _dataSource.getAvailability(date: dateStr, guests: 2);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _tables = tables;
      });
    } catch (_) {
      // Kutilmoqda.
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _isLoading
              ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 6))
              : ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    Text('Zal', style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Gap(6.h),
                    Text('Bo\'sh stollar: ${_summary?.freeNow ?? '—'}', style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, color: AppColors.textSecondary)),
                    Gap(16.h),
                    if (_tables.isEmpty)
                      Text('Stollar ma\'lumoti yo\'q', style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: AppColors.textMuted))
                    else
                      ..._tables.map((t) => Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFFECEFF3))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Stol ${t['number'] ?? t['id'] ?? '—'}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                Text('${t['seats'] ?? ''} o\'rin', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                              ],
                            ),
                          )),
                  ],
                ),
        ),
      ),
    );
  }
}
