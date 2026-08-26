import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final String? iconSvgPath;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    this.iconSvgPath,
  });

  static List<CategoryModel> get mockCategories => const [
        CategoryModel(
          id: 'restaurant',
          title: 'Restoran',
          icon: Icons.restaurant_rounded,
        ),
        CategoryModel(
          id: 'game_club',
          title: 'Geym klub',
          icon: Icons.sports_esports_rounded,
        ),
        CategoryModel(
          id: 'barber',
          title: 'Sartaroshxona',
          icon: Icons.content_cut_rounded,
        ),
        CategoryModel(
          id: 'beauty',
          title: 'Go\'zallik saloni',
          icon: Icons.face_retouching_natural_rounded,
        ),
        CategoryModel(
          id: 'sport',
          title: 'Sport',
          icon: Icons.fitness_center_rounded,
        ),
        CategoryModel(
          id: 'coworking',
          title: 'Kovorking',
          icon: Icons.laptop_mac_rounded,
        ),
      ];
}
