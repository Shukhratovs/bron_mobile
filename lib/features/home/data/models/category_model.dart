import '../../../../core/constants/app_assets.dart';

/// `id` backend `kind` qiymati bilan bir xil (00-boshlash.md §4) — shu
/// bilan to'g'ridan-to'g'ri `GET /venues?kind=` parametriga beriladi.
class CategoryModel {
  final String id;
  final String title;
  final String iconAsset;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.iconAsset,
  });

  static List<CategoryModel> get categories => const [
        CategoryModel(id: 'restoran', title: 'Restoran', iconAsset: AppAssets.iconRestaurantLine),
        CategoryModel(id: 'geym_klub', title: 'Geym klub', iconAsset: AppAssets.iconGamepadLine),
        CategoryModel(id: 'sartaroshxona', title: 'Sartaroshxona', iconAsset: AppAssets.iconScissorsLine),
        CategoryModel(id: 'gozallik_saloni', title: 'Go\'zallik saloni', iconAsset: AppAssets.iconSparklingLine),
      ];
}