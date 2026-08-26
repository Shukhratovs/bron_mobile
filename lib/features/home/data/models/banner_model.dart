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
          title: 'Tinch va sokin kechki ovqat',
          subtitle: 'Romantik va sokin muhitdagi restoranlar',
          discount: '-20%',
          imagePath: 'assets/images/onboarding_second.png',
        ),
      ];
}
