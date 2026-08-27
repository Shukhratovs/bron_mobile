import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_qr_widget.dart';

class BookingDetailScreen extends StatefulWidget {
  final String venueName;
  final String bookingId;
  final String date;
  final String time;
  final String guests;
  final String table;
  final String address;

  const BookingDetailScreen({
    super.key,
    this.venueName = 'Osteria Da Vinci',
    this.bookingId = 'BRN-4821',
    this.date = '27-iyul, yakshanba',
    this.time = '19:00',
    this.guests = '4 kishi',
    this.table = '12 · deraza yonida',
    this.address = 'Bunyodkor ko\'chasi 12 · 1,2 km',
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _hasArrived = false;

  void _showCancelDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(20.h),
              Text(
                'Bronni bekor qilish',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF181A20),
                ),
              ),
              Gap(8.h),
              Text(
                'Rostdan ham bronni bekor qilmoqchimisiz? Bloklangan 150 000 so\'m depozit to\'liq hisobingizga qaytariladi.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bron muvaffaqiyatli bekor qilindi'),
                        backgroundColor: Color(0xFFDC3009),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3009),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Ha, bekor qilish',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Gap(10.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Orqaga',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeTimeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),
              Text(
                'Vaqtni o\'zgartirish',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF181A20),
                ),
              ),
              Gap(14.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: ['19:30', '20:00', '20:30', '21:00'].map((slot) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vaqt $slot ga o\'zgartirildi'),
                          backgroundColor: const Color(0xFF12B76A),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFECEFF3)),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF181A20),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _onArrivalTap() {
    HapticFeedback.mediumImpact();
    setState(() {
      _hasArrived = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xostesga yetib kelganingiz ma\'lum qilindi!'),
        backgroundColor: Color(0xFF12B76A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181A20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bron tafsilotlari',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF181A20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showCancelDialog,
            child: Text(
              'Bronni bekor qilish',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDC3009),
              ),
            ),
          ),
          Gap(6.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  // 1. Venue Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFECEFF3)),
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
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 24,
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.venueName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF181A20),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Gap(8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F9F0),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'TASDIQLANDI',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF12B76A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gap(3.h),
                              Text(
                                widget.address,
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
                  Gap(12.h),

                  // 2. QR Code Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFECEFF3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomQrWidget(
                          data: widget.bookingId,
                          size: 160.r,
                          color: const Color(0xFF181A20),
                        ),
                        Gap(16.h),
                        Text(
                          widget.bookingId,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: const Color(0xFF181A20),
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '30 soniyada yangilanadi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(12.h),

                  // 3. Info Details Card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFECEFF3)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Sana', widget.date),
                        _buildDivider(),
                        _buildDetailRow('Vaqt', widget.time),
                        _buildDivider(),
                        _buildDetailRow('Mehmonlar', widget.guests),
                        _buildDivider(),
                        _buildDetailRow('Stol', widget.table),
                        Gap(14.h),

                        // Deposit Banner
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDEEE8),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.credit_card_rounded,
                                    size: 16,
                                    color: Color(0xFFDC3009),
                                  ),
                                  Gap(6.w),
                                  Expanded(
                                    child: Text(
                                      '150 000 so\'m bloklangan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFDC3009),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gap(4.h),
                              Text(
                                'Restoranda hisobingizga o\'tadi. 27-iyul 13:30 gacha bepul bekor qilish mumkin',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  color: const Color(0xFFDC3009).withValues(alpha: 0.8),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),
                ],
              ),
            ),
          ),

          // 4. Sticky Bottom Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFECEFF3))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Button 1: Change Time
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _showChangeTimeModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3009),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Vaqtni o\'zgartirish',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Gap(10.h),

                  // Button 2: I'm Here
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: _hasArrived ? null : _onArrivalTap,
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Color(0xFFDC3009),
                      ),
                      label: Text(
                        _hasArrived ? 'Yetib kelganingiz qayd etildi' : 'Men shu yerdaman',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC3009),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDEEE8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                  Gap(8.h),

                  // Footnote
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      Gap(4.w),
                      Flexible(
                        child: Text(
                          'Xostesga xabar beriladi · 120 m qoldi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF181A20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F4F6),
    );
  }
}
