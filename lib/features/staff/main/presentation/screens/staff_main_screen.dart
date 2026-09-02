import 'package:flutter/material.dart';
import '../../../bookings/presentation/screens/bugun_screen.dart';
import '../../../bookings/presentation/screens/qr_scan_screen.dart';
import '../../../shift/presentation/screens/staff_shift_summary_screen.dart';
import '../../../waitlist/presentation/screens/staff_navbat_screen.dart';
import '../../../zal/presentation/screens/staff_zal_screen.dart';
import '../widgets/staff_bottom_nav.dart';

/// Xostes ilovasining asosiy qobig'i — Bugun / Zal / Navbat / Yakun,
/// markazda Skaner FAB (Figma: i8FGYLF28h8GYXQgd1Pczf, "Navigatsiya").
/// Profil bu panelda yo'q — har ekran sarlavhasidagi avatar orqali ochiladi.
/// Planshet (1194x834) va telefon (402x874) uchun API bir xil, faqat
/// joylashuv farq qiladi (01-kirish.md) — hozircha bitta ustunli maket.
class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int _index = 0;

  final _screens = const [
    BugunScreen(),
    StaffZalScreen(),
    StaffNavbatScreen(),
    StaffShiftSummaryScreen(),
  ];

  void _openScanner() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScanScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: StaffBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onScanTap: _openScanner,
      ),
    );
  }
}
