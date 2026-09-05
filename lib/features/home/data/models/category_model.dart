import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';

/// `id` backend `kind` qiymati bilan bir xil (00-boshlash.md §4) — shu
/// bilan to'g'ridan-to'g'ri `GET /venues?kind=` parametriga beriladi.
class CategoryModel {
  final String id;
  final String _titleKey;
  final String iconAsset;
  final bool comingSoon;

  const CategoryModel({
    required this.id,
    required String titleKey,
    required this.iconAsset,
    this.comingSoon = false,
  }) : _titleKey = titleKey;

  String get title => AppStrings.tr(_titleKey);

  static List<CategoryModel> get categories => const [
        CategoryModel(id: 'restoran', titleKey: 'category_restoran', iconAsset: AppAssets.iconRestaurantLine),
        CategoryModel(id: 'geym_klub', titleKey: 'category_geym_klub', iconAsset: AppAssets.iconGamepadLine),
        CategoryModel(
          id: 'sartaroshxona',
          titleKey: 'category_sartaroshxona',
          iconAsset: AppAssets.iconScissorsLine,
          comingSoon: true,
        ),
        CategoryModel(
          id: 'gozallik_saloni',
          titleKey: 'category_gozallik_saloni',
          iconAsset: AppAssets.iconSparklingLine,
          comingSoon: true,
        ),
      ];
}