class MenuItemModel {
  final String id;
  final String title;
  final String description;
  final String price;
  final String category;
  final String? imagePath;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.imagePath,
  });

  static List<MenuItemModel> get mockMenuItems => const [
        MenuItemModel(
          id: '1',
          title: 'Tagliatelle al tartufo',
          description: 'Qo\'ziqorinli sous, parmezan, trufel yog\'i',
          price: '110 000 so\'m',
          category: 'Mashhur',
        ),
        MenuItemModel(
          id: '2',
          title: 'Beef steak',
          description: 'Marmar mol go\'shti, rozmarinli kartoshka',
          price: '185 000 so\'m',
          category: 'Mashhur',
        ),
        MenuItemModel(
          id: '3',
          title: 'Tiramisu',
          description: 'Maskarpone, espresso, kakao',
          price: '55 000 so\'m',
          category: 'Shirinliklar',
        ),
        MenuItemModel(
          id: '4',
          title: 'Salmone grigliato',
          description: 'Grilda pishirilgan losos, limonli sous',
          price: '175 000 so\'m',
          category: 'Issiq taomlar',
        ),
        MenuItemModel(
          id: '5',
          title: 'Carpaccio di manzo',
          description: 'Yupqa mol go\'shti, rukola, parmezan',
          price: '85 000 so\'m',
          category: 'Salatlar',
        ),
      ];
}
