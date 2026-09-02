import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/shimmer_skeleton.dart';
import '../../../auth/presentation/screens/staff_login_screen.dart';
import '../../../core/staff_session.dart';

/// `GET /staff/me` bilan qisman (01-boshlash.md — "Profil ✅ qisman").
class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  Map<String, dynamic>? _me;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final response = await StaffSession.apiClient.get(ApiEndpoints.staffMe);
      if (mounted && response is Map) setState(() => _me = response.cast<String, dynamic>());
    } catch (_) {
      // ko'rsatilmaydi
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final storage = StaffSession.localStorage;
    await StaffSession.pushService.unregisterToken();
    await storage.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StaffLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = StaffSession.localStorage;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: _isLoading
            ? Padding(padding: EdgeInsets.all(16.w), child: const ListRowSkeletonGroup(count: 3))
            : ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  Text('Profil', style: GoogleFonts.unbounded(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Gap(16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: const Color(0xFFECEFF3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row('Ism', _me?['name']?.toString() ?? '—'),
                        _row('Rol', storage.role ?? '—'),
                        _row('Tashkilot', storage.organizationId ?? '—'),
                      ],
                    ),
                  ),
                  Gap(20.h),
                  OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                    child: const Text('Chiqish'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
