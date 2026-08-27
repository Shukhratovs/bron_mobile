import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveQueueScannerScreen extends StatefulWidget {
  const LiveQueueScannerScreen({super.key});

  @override
  State<LiveQueueScannerScreen> createState() => _LiveQueueScannerScreenState();
}

class _LiveQueueScannerScreenState extends State<LiveQueueScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanAnimationController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _onSuccessScan() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(true);
  }

  void _showManualCodeDialog() {
    final controller = TextEditingController(text: 'BRN-4821');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Kodni qo\'lda kiritish',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Masalan: BRN-4821',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF9CA3AF),
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: const Color(0xFF2B2D33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Bekor qilish',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onSuccessScan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3009),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(
              'Qo\'shilish',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Gap(12.h),

                  // Top Close Button Row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26282E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Gap(24.h),

                  // Title & Subtitle
                  Text(
                    'QR kodni skanerlang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(8.h),
                  Text(
                    'Stol ustidagi, kirish eshigidagi yoki xostes planshetidagi kodni kameraga tuting — navbatga avtomatik qo\'shilasiz',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(36.h),

                  // Scanner Frame Viewport
                  GestureDetector(
                    onTap: _onSuccessScan,
                    child: SizedBox(
                      width: 250.w,
                      height: 250.w,
                      child: Stack(
                        children: [
                          // Scanner Dark Area
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2024),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),

                          // Animated Scanning Laser Line
                          AnimatedBuilder(
                            animation: _scanAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: _scanAnimation.value * 230.w + 10.w,
                                left: 14.w,
                                right: 14.w,
                                child: Container(
                                  height: 2.5.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFDC3009).withValues(alpha: 0.0),
                                        const Color(0xFFDC3009),
                                        const Color(0xFFDC3009).withValues(alpha: 0.0),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDC3009).withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // 4 Orange Corner Brackets
                          CustomPaint(
                            size: Size(250.w, 250.w),
                            painter: _ScannerCornersPainter(
                              cornerColor: const Color(0xFFDC3009),
                              cornerLength: 32.w,
                              strokeWidth: 3.5.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20.h),

                  // Notice Chip
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26282E),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Kod topilmadi kamerani yaqinroq tuting',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD1D5DB),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Manual Code Entry Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _showManualCodeDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2D33),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Kodni qo\'lda kiritish',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'Masalan: BRN-4821',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Gap(20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCornersPainter extends CustomPainter {
  final Color cornerColor;
  final double cornerLength;
  final double strokeWidth;

  _ScannerCornersPainter({
    required this.cornerColor,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-Left
    canvas.drawLine(Offset(0, cornerLength), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);

    // Top-Right
    canvas.drawLine(Offset(w - cornerLength, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, h - cornerLength), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);

    // Bottom-Right
    canvas.drawLine(Offset(w - cornerLength, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
