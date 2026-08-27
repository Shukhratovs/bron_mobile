import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/table_ready_bottom_sheet.dart';
import 'booking_detail_screen.dart';
import 'live_queue_scanner_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTabIndex = 0; // 0: Faol, 1: O'tgan
  bool _isLiveQueueActive = true; // Can be toggled with Jonli navbat scanner or Chiqish

  void _openLiveQueueScanner() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const LiveQueueScannerScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        _isLiveQueueActive = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jonli navbatga muvaffaqiyatli qo\'shildingiz!'),
            backgroundColor: Color(0xFF12B76A),
          ),
        );
      }
    }
  }

  void _openTableReadyModal() {
    TableReadyBottomSheet.show(
      context,
      onDismissQueue: () {
        setState(() {
          _isLiveQueueActive = false;
        });
      },
    );
  }

  void _openBookingDetail({
    required String venueName,
    required String bookingId,
    required String date,
    required String time,
    required String guests,
    required String table,
    required String address,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(
          venueName: venueName,
          bookingId: bookingId,
          date: date,
          time: time,
          guests: guests,
          table: table,
          address: address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Title + Jonli navbat)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Bronlarim',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF181A20),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _openLiveQueueScanner,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 18,
                            color: Color(0xFFDC3009),
                          ),
                          Gap(6.w),
                          Text(
                            'Jonli navbat',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC3009),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Gap(16.h),

              // 2. Segmented Tab Switcher (Faol / O'tgan)
              Container(
                height: 44.h,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedTabIndex = 0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: _selectedTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Faol',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: _selectedTabIndex == 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedTabIndex == 0
                                    ? const Color(0xFF181A20)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedTabIndex = 1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: _selectedTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'O\'tgan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: _selectedTabIndex == 1
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedTabIndex == 1
                                    ? const Color(0xFF181A20)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16.h),

              // Tab content
              if (_selectedTabIndex == 0) _buildActiveBookingsView() else _buildPastBookingsView(),

              Gap(90.h), // Clearance for floating liquid glass navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3. Live Queue Card ("NAVBATDASIZ")
        if (_isLiveQueueActive) ...[
          GestureDetector(
            onTap: _openTableReadyModal,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFECEFF3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Pulsing Live Dot + NAVBATDASIZ + Time Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC3009),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Gap(6.w),
                          Text(
                            'NAVBATDASIZ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC3009),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEEE8),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '19:00–20:00',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC3009),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),

                  // Row 2: Venue Info
                  Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 22,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Osteria Da Vinci',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF181A20),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(2.h),
                            Text(
                              'Bugun · 4 kishi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(14.h),

                  // Row 3: Progress Box
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFECEFF3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Sizdan oldin',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              '1 kishi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF181A20),
                              ),
                            ),
                          ],
                        ),
                        Gap(8.h),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 5.h,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Color(0xFFDC3009)),
                          ),
                        ),
                        Gap(8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Taxminiy kutish',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              '~25 daqiqa',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF181A20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Gap(12.h),

                  // Row 4: Notice & Exit Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Xabar kelgach 10 daqiqa vaqtingiz bo\'ladi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Gap(8.w),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLiveQueueActive = false;
                          });
                        },
                        child: Text(
                          'Chiqish',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF181A20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Gap(18.h),
        ],

        // 4. BUGUN Section
        Text(
          'BUGUN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8E8E93),
            letterSpacing: 0.5,
          ),
        ),
        Gap(8.h),

        // Booking 1: Osteria Da Vinci
        _buildBookingItem(
          venueName: 'Osteria Da Vinci',
          bookingId: 'BRN-4821',
          subtitle: '19:00 · 4 kishi',
          status: 'TASDIQLANDI',
          statusType: _BookingStatusType.confirmed,
          icon: Icons.apartment_rounded,
          date: 'Bugun, 27-iyul',
          time: '19:00',
          guests: '4 kishi',
          table: '12 · deraza yonida',
          address: 'Bunyodkor ko\'chasi 12 · 1,2 km',
        ),
        Gap(18.h),

        // 5. KEYINGI KUNLAR Section
        Text(
          'KEYINGI KUNLAR',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8E8E93),
            letterSpacing: 0.5,
          ),
        ),
        Gap(8.h),

        // Booking 2: Chorsu Osh Markazi
        _buildBookingItem(
          venueName: 'Chorsu Osh Markazi',
          bookingId: 'BRN-1024',
          subtitle: '29-iyul · 13:00 · 4 kishi',
          status: 'TASDIQLANDI',
          statusType: _BookingStatusType.confirmed,
          icon: Icons.apartment_rounded,
          date: '29-iyul, seshanba',
          time: '13:00',
          guests: '4 kishi',
          table: '4 · umumiy zal',
          address: 'Chorsu maydoni 1 · 3,4 km',
        ),
        Gap(10.h),

        // Booking 3: Plov Center
        _buildBookingItem(
          venueName: 'Plov Center',
          bookingId: 'BRN-3910',
          subtitle: '2-avgust · 19:00 · 6 kishi',
          status: 'KUTILMOQDA',
          statusType: _BookingStatusType.pending,
          icon: Icons.location_on_outlined,
          date: '2-avgust, shanba',
          time: '19:00',
          guests: '6 kishi',
          table: 'VIP-2 xona',
          address: 'Amir Temur shox ko\'chasi 45 · 2,8 km',
        ),
      ],
    );
  }

  Widget _buildPastBookingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookingItem(
          venueName: 'Level Up Game Club',
          bookingId: 'BRN-2048',
          subtitle: '20-iyul · 20:00 · 5 kishi',
          status: 'YAKUNLANDI',
          statusType: _BookingStatusType.completed,
          icon: Icons.sports_esports_outlined,
          date: '20-iyul, yakshanba',
          time: '20:00',
          guests: '5 kishi',
          table: 'VIP Zal #1',
          address: 'Yunusobod 4-mavze · 4,1 km',
        ),
        Gap(10.h),
        _buildBookingItem(
          venueName: 'Bahor Choyxonasi',
          bookingId: 'BRN-1102',
          subtitle: '15-iyul · 18:30 · 8 kishi',
          status: 'BEKOR QILINGAN',
          statusType: _BookingStatusType.cancelled,
          icon: Icons.apartment_rounded,
          date: '15-iyul, seshanba',
          time: '18:30',
          guests: '8 kishi',
          table: 'Katta so\'ri #3',
          address: 'Chilonzor 9-mavze · 2,8 km',
        ),
      ],
    );
  }

  Widget _buildBookingItem({
    required String venueName,
    required String bookingId,
    required String subtitle,
    required String status,
    required _BookingStatusType statusType,
    required IconData icon,
    required String date,
    required String time,
    required String guests,
    required String table,
    required String address,
  }) {
    final (badgeBg, badgeText) = switch (statusType) {
      _BookingStatusType.confirmed => (const Color(0xFFE6F9F0), const Color(0xFF12B76A)),
      _BookingStatusType.pending => (const Color(0xFFFEF3EB), const Color(0xFFF79009)),
      _BookingStatusType.completed => (const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
      _BookingStatusType.cancelled => (const Color(0xFFFEE4E2), const Color(0xFFD92D20)),
    };

    return GestureDetector(
      onTap: () => _openBookingDetail(
        venueName: venueName,
        bookingId: bookingId,
        date: date,
        time: time,
        guests: guests,
        table: table,
        address: address,
      ),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFECEFF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF9CA3AF),
                size: 22,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venueName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF181A20),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                            color: badgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BookingStatusType {
  confirmed,
  pending,
  completed,
  cancelled,
}
