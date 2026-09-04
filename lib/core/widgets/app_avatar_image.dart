import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// Profil rasmini har qanday manbadan (bundled asset, tarmoq URL'i yoki
/// qurilmada mahalliy saqlangan fayl yo'li) to'g'ri chizadigan doiraviy
/// avatar. `avatarPath` qiymati uchta shakldan biri bo'lishi mumkin:
/// - `http(s)://...` — tarmoq rasmi (`Image.network`)
/// - mutlaq fayl yo'li (masalan `.../app_flutter/profile_avatar.jpg`,
///   `image_picker`dan keyin nusxalab saqlangan) — `Image.file`
/// - aks holda — bundled asset (`Image.asset`, masalan `AppAssets.me`)
class AppAvatarImage extends StatelessWidget {
  final String? avatarPath;
  final double size;
  final Widget? fallback;

  const AppAvatarImage({
    super.key,
    required this.avatarPath,
    required this.size,
    this.fallback,
  });

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return fallback ??
        Container(
          color: const Color(0xFFF3F4F6),
          child: Icon(Icons.person_rounded, size: size * 0.55, color: const Color(0xFF9EA3AE)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    final errorBuilder = _errorBuilder;

    Widget image;
    if (path == null || path.isEmpty) {
      image = Image.asset(AppAssets.me, fit: BoxFit.cover, errorBuilder: errorBuilder);
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      image = Image.network(path, fit: BoxFit.cover, errorBuilder: errorBuilder);
    } else if (path.startsWith('assets/')) {
      image = Image.asset(path, fit: BoxFit.cover, errorBuilder: errorBuilder);
    } else {
      // Mahalliy fayl yo'li (image_picker orqali tanlangan/olingan rasm).
      image = Image.file(File(path), fit: BoxFit.cover, errorBuilder: errorBuilder);
    }

    return SizedBox(width: size, height: size, child: ClipOval(child: image));
  }
}
