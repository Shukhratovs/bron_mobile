import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../core/staff_session.dart';
import '../../data/models/shift_summary_model.dart';

/// Xostes — Smena yakuni tab'i. Figma: i8FGYLF28h8GYXQgd1Pczf, "6 · YAKUN"
/// (node 352:716). `GET /staff/shift/summary` — faqat o'qish, hech narsani
/// o'zgartirmaydi (xostes/04-smena-yakuni.md §4).
///
/// Figma dizaynida "Stol aylanmasi", "Bo'sh o'tgan stol-soat" va
/// "O'rtacha kutish" ko'rsatkichlari bor, lekin backend javobida bunday
/// maydonlar yo'q — 00-boshlash.md §2 qoidasiga ko'ra ular `0` emas,
/// **"—"** deb ko'rsatiladi. "Walk-in" o'rniga backend berayotgan
/// `guests` (kelgan mehmonlar soni) ko'rsatiladi — manba bo'yicha
/// taqsimot hozircha API'da yo'q.
class StaffShiftSummaryScreen extends StatefulWidget {
  const StaffShiftSummaryScreen({super.key});

  @override
  State<StaffShiftSummaryScreen> createState() => _StaffShiftSummaryScreenState();
}

class _StaffShiftSummaryScreenState extends State<StaffShiftSummaryScreen> {
  DateTime? _selectedDate;
  ShiftSummaryModel? _summary;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final date = _selectedDate;
      final url = date == null
          ? ApiEndpoints.staffShiftSummary
          : '${ApiEndpoints.staffShiftSummary}?date=${_isoDate(date)}';
      final response = await StaffSession.apiClient.get(url);
      if (!mounted) return;
      setState(() => _summary = ShiftSummaryModel.fromJson((response as Map).cast<String, dynamic>()));
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    _load();
  }

  Future<void> _onCloseShift() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smenani yopish'),
        // Figma matni "hisobot administratorga yuboriladi" deydi, lekin
        // bu amal hozircha hech qanday API'ga ulanmagan — 04-smena-yakuni.md
        // §4: "Smenani yopish amali — bu hali yozilmagan ... faqat ilova
        // ichida ishlaydi". Xodimni chalg'itmaslik uchun rost matn yozilgan.
        content: const Text('Bu tugma hozircha faqat ilova ichida ishlaydi — serverga hech narsa yuborilmaydi va hech qanday holat o\'zgarmaydi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tushunarli')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Smena yopildi (faqat shu qurilmada)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFB4B23)))
                : _hasError
                    ? _buildError()
                    : _summary == null
                        ? const SizedBox.shrink()
                        : RefreshIndicator(onRefresh: _load, child: _buildBody(_summary!)),
            // "Smenani yopish" CTA — nav pill ustida suzadi (extendBody
            // orqali IndexedStack butun ekranni egallaydi).
            Positioned(left: 0, right: 0, bottom: 0, child: _buildCta()),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ma\'lumotni yuklab bo\'lmadi', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF5C5C5C)), textAlign: TextAlign.center),
            Gap(12.h),
            OutlinedButton(onPressed: _load, child: const Text('Qayta urinish')),
          ],
        ),
      ),
    );
  }

  Widget _buildCta() {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // 24.h nav-margin + ~64.h pill balandligi + tizim inseti — StaffBottomNav
    // bilan bir xil hisob (custom_bottom_nav_bar.dart'dagi naqsh).
    final navClearance = 24.h + bottomInset + 64.h;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, navClearance),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0xF2FFFFFF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onCloseShift,
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
              label: Text('Smenani yopish', style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB3748),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ),
          Gap(8.h),
          Text(
            'Bu amal faqat shu qurilmada ko\'rinadi, serverga saqlanmaydi',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, color: const Color(0xFFA3A3A3)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ShiftSummaryModel s) {
    return ListView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 220.h),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
          child: Text('Smena yakuni', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717))),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(s),
              Gap(14.h),
              _statsGrid(s),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TAFSILOT', style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFFA3A3A3))),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14.r, color: const Color(0xFFFB4B23)),
                        Gap(4.w),
                        Text(
                          _selectedDate != null ? formatDateShort(_selectedDate!) : 'Bugun',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFFFB4B23)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(8.h),
              _detailsCard(s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroCard(ShiftSummaryModel s) {
    final isToday = _selectedDate == null;
    final statusLabel = s.isClosed ? 'YOPIQ KUN' : (isToday ? 'SMENA DAVOM ETMOQDA' : 'SMENA TUGADI');
    final rangeLabel = s.isClosed ? '—' : '${s.opensAt ?? '—'} — ${isToday ? 'hozir' : (s.closesAt ?? '—')}';
    final durationLabel = _durationLabel(s, isToday);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF17171A), Color(0xFF331208)]),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8.r, height: 8.r, decoration: const BoxDecoration(color: Color(0xFFFB4B23), shape: BoxShape.circle)),
              Gap(8.w),
              Expanded(
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.72), letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          Gap(8.h),
          Text(rangeLabel, style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          Gap(4.h),
          Text(
            [
              formatDateShort(_selectedDate ?? DateTime.now()),
              if (StaffSession.localStorage.selectedVenueName != null) StaffSession.localStorage.selectedVenueName!,
              if (durationLabel != null) durationLabel,
            ].join(' · '),
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.66)),
          ),
        ],
      ),
    );
  }

  String? _durationLabel(ShiftSummaryModel s, bool isToday) {
    final opens = _parseHm(s.opensAt);
    if (opens == null || s.isClosed) return null;
    final endMinutes = isToday ? (DateTime.now().hour * 60 + DateTime.now().minute) : _parseHm(s.closesAt);
    if (endMinutes == null) return null;
    var diff = endMinutes - opens;
    if (diff < 0) diff += 24 * 60; // yarim tundan keyingi smena — 00-boshlash.md
    final h = diff ~/ 60;
    final m = diff % 60;
    if (h == 0) return '$m daqiqa';
    if (m == 0) return '$h soat';
    return '$h soat $m daqiqa';
  }

  int? _parseHm(String? hm) {
    if (hm == null) return null;
    final parts = hm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  Widget _statsGrid(ShiftSummaryModel s) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _statTile(AppAssets.iconCalendarCheckLine, s.bookingsTotal.toString(), 'Bronlar', const Color(0xFFF7F7F7), const Color(0xFF171717)),
        _statTile(AppAssets.iconCheckDoubleLine, (s.bookings['keldi'] ?? 0).toString(), 'Keldi', const Color(0xFFE3F7EC), const Color(0xFF171717)),
        _statTile(AppAssets.iconCloseLine, (s.bookings['kelmadi'] ?? 0).toString(), 'Kelmadi', const Color(0xFFFFEBEC), const Color(0xFF171717)),
        _statTile(AppAssets.iconGroupLine, s.guests.toString(), 'Mehmonlar', const Color(0xFFF7F7F7), const Color(0xFF171717)),
      ],
    );
  }

  Widget _statTile(String icon, String value, String label, Color iconBg, Color valueColor) {
    return Container(
      width: 180.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r), boxShadow: const [BoxShadow(color: Color(0x080A0D14), blurRadius: 2, offset: Offset(0, 1))]),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(child: SvgPicture.asset(icon, width: 24.r, height: 24.r)),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w600, color: valueColor)),
                Text(label, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF5C5C5C))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(ShiftSummaryModel s) {
    final noShowRatio = s.bookingsTotal > 0 ? '${((s.bookings['kelmadi'] ?? 0) / s.bookingsTotal * 100).round()}%' : '—';
    final rows = [
      ('Navbatdan joylashtirildi', s.seatedFromWaitlist.toString()),
      // Backend `/staff/shift/summary` bu uch ko'rsatkichni qaytarmaydi —
      // 00-boshlash.md §2: `null` "—" deb ko'rsatiladi, `0` emas.
      ('O\'rtacha kutish', '—'),
      ('Stol aylanmasi', '—'),
      ('Bo\'sh o\'tgan stol-soat', '—'),
      ('Kelmaslik ulushi', noShowRatio),
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: const [BoxShadow(color: Color(0x080A0D14), blurRadius: 2, offset: Offset(0, 1))]),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rows[i].$1, style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF5C5C5C))),
                  Text(rows[i].$2, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF171717))),
                ],
              ),
            ),
            if (i != rows.length - 1) Container(height: 1, margin: EdgeInsets.symmetric(horizontal: 16.w), color: const Color(0xFFEBEBEB)),
          ],
        ],
      ),
    );
  }
}
