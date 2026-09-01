import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_result.dart';
import '../../../core/staff_session.dart';
import '../../data/datasources/staff_booking_remote_data_source.dart';
import '../../data/repositories/staff_booking_repository_impl.dart';
import '../../domain/repositories/staff_booking_repository.dart';
import 'manual_search_screen.dart';
import 'staff_booking_detail_screen.dart';
import '../../../../../core/widgets/app_icon.dart';
import '../../../../../core/constants/app_assets.dart';

/// Figma: `QR skanerlash` (`758:20939`), `Bron topildi` (`766:963`).
class QrScanScreen extends StatefulWidget {
  final StaffBookingRepository? repository;

  const QrScanScreen({super.key, this.repository});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late final StaffBookingRepository _repository;
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  String? _errorMessage;

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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    final result = await _repository.scan(code);
    if (!mounted) return;

    switch (result) {
      case Success(:final data):
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StaffBookingDetailScreen(bookingId: data.id, repository: _repository)),
        );
      case Failure(:final exception):
        setState(() {
          _isProcessing = false;
          _errorMessage = exception.code == 'qr_invalid'
              ? 'QR yaroqsiz yoki eskirgan — mehmondan ekranni yangilashni so\'rang'
              : exception.code == 'booking_forbidden'
                  ? 'Bu bron boshqa filialniki'
                  : exception.message;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('QR skanerlash', style: GoogleFonts.unbounded(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 240.w,
              height: 240.w,
              decoration: BoxDecoration(border: Border.all(color: AppColors.primary, width: 3), borderRadius: BorderRadius.circular(20.r)),
            ),
          ),
          if (_errorMessage != null)
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 100.h,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(12.r)),
                child: Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13.sp, color: Colors.white)),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30.h,
            child: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ManualSearchScreen(repository: _repository)),
                ),
                icon: const AppIcon(AppAssets.iconKeyboardLine, color: Colors.white),
                label: Text('Qo\'lda qidirish', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
