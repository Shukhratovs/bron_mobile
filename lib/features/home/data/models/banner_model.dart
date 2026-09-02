import '../../../../core/constants/app_assets.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String discount;
  final String? imagePath;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discount,
    this.imagePath,
  });

  static List<BannerModel> get mockBanners => const [
        BannerModel(
          id: '1',
          title: 'Tinch soatlarda chegirma',
          subtitle: 'Kapitalbank bilan · 12 ta joy',
          discount: '-20%',
          imagePath: AppAssets.bannerPromo,
        ),
      ];
}
