import 'package:flutter/material.dart';
import '../../../../../core/widgets/glass_liquid_bottom_nav_bar.dart';
import '../../../bookings/presentation/screens/bugun_screen.dart';
import '../../../profile/presentation/screens/staff_profile_screen.dart';
import '../../../waitlist/presentation/screens/staff_navbat_screen.dart';
import '../../../zal/presentation/screens/staff_zal_screen.dart';

/// Xostes ilovasining asosiy qobig'i — Bugun / Zal / Navbat / Profil.
/// Planshet (1194x834) va telefon (402x874) uchun API bir xil, faqat
/// joylashuv farq qiladi (01-kirish.md) — keng ekranda ikki panelli
/// joylashuv qo'shilishi mumkin, hozircha bitta ustunli maket ishlatiladi.
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
    StaffProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: GlassLiquidBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          GlassNavItem(label: 'Bugun', icon: Icons.today_rounded, activeIcon: Icons.today_rounded),
          GlassNavItem(label: 'Zal', icon: Icons.table_bar_outlined, activeIcon: Icons.table_bar_rounded),
          GlassNavItem(label: 'Navbat', icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded),
          GlassNavItem(label: 'Profil', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
        ],
      ),
    );
  }
}
