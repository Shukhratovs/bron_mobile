import 'package:flutter/material.dart';

/// `id` backend `kind` qiymati bilan bir xil (00-boshlash.md §4) — shu
/// bilan to'g'ridan-to'g'ri `GET /venues?kind=` parametriga beriladi.
class CategoryModel {
  final String id;
  final String title;
  final IconData icon;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
  });

  static List<CategoryModel> get categories => const [
        CategoryModel(id: 'restoran', title: 'Restoran', icon: Icons.restaurant_rounded),
        CategoryModel(id: 'geym_klub', title: 'Geym klub', icon: Icons.sports_esports_rounded),
        CategoryModel(id: 'sartaroshxona', title: 'Sartaroshxona', icon: Icons.content_cut_rounded),
        CategoryModel(id: 'gozallik_saloni', title: 'Go\'zallik saloni', icon: Icons.face_retouching_natural_rounded),
      ];
}
