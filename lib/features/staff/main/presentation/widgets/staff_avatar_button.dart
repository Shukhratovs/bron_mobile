import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../profile/presentation/screens/staff_profile_screen.dart';

/// Header'dagi avatar — bosilganda Profil ekranini ochadi. Figma
/// (`Avatar11`) rasm bilan, lekin `GET /staff/me` fotosuratni
/// qaytarmaydi — shu sabab ismning bosh harflaridan yasalgan doira
/// ishlatiladi (mijoz ilovasidagi `Avatar` bilan bir xil naqsh).
class StaffAvatarButton extends StatelessWidget {
  final String? name;

  const StaffAvatarButton({super.key, this.name});

  String get _initials {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffProfileScreen())),
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: const BoxDecoration(color: Color(0xFFFFF2EF), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFFB12A0B)),
        ),
      ),
    );
  }
}
