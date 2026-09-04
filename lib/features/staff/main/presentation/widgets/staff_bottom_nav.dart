import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_assets.dart';

/// Xostes pastki navigatsiyasi — Figma `Navigatsiya` komponenti
/// (i8FGYLF28h8GYXQgd1Pczf, masalan node 286:310): Bugun / Zal / [Skaner
/// FAB] / Navbat / Yakun. Profil bu panelda yo'q — u har ekran sarlavhasidagi
/// avatar orqali ochiladi (`StaffAvatarButton`).
class StaffBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScanTap;

  const StaffBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
  });

  static const _items = [
    (AppAssets.navStaffBugun, 'Bugun'),
    (AppAssets.navStaffZal, 'Zal'),
    (AppAssets.navStaffNavbat, 'Navbat'),
    (AppAssets.navStaffYakun, 'Yakun'),
  ];

  static const _activeColor = Color(0xFFB12A0B);
  static const _activeBg = Color(0xFFFFF2EF);
  static const _inactiveColor = Color(0xFFA3A3A3);

  @override
  Widget build(BuildContext context) {
    // 3 tugmali Android navigatsiyasida butun ilova (`MaterialApp.builder`,
    // main_staff.dart) allaqachon `SafeArea(bottom: true)` bilan yuqoriga
    // suriladi — bu yerda tizim insetini qayta qo'shish panelni keraksiz
    // baland "ko'tarib" qo'yadi.
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: const [BoxShadow(color: Color(0x230D0D0F), blurRadius: 12, offset: Offset(0, 8))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tab(0),
                _gap(),
                _tab(1),
                _gap(),
                SizedBox(width: 56.w), // "Joy" — Skaner FAB shu joyni bosib turadi
                _gap(),
                _tab(2),
                _gap(),
                _tab(3),
              ],
            ),
          ),
          Positioned(
            top: -5.h,
            child: GestureDetector(
              onTap: onScanTap,
              child: Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFB4B23),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.iconQrScan2Line,
                    width: 28.r,
                    height: 28.r,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _gap() => SizedBox(width: 4.w);

  Widget _tab(int index) {
    final (icon, label) = _items[index];
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 61.w,
        height: 52.h,
        decoration: BoxDecoration(
          color: isSelected ? _activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 24.r,
              height: 24.r,
              colorFilter: ColorFilter.mode(isSelected ? _activeColor : _inactiveColor, BlendMode.srcIn),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: isSelected ? _activeColor : _inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
