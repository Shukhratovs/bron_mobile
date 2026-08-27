import '../../../../core/constants/app_assets.dart';

class VenueModel {
  final String id;
  final String name;
  final String category;
  final String imagePath;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final String address;
  final String distance;
  final String workingHours;
  final String priceRange;
  final List<String> availableTimeSlots;
  final String description;
  final String depositAmount;
  final bool isPopular;
  final bool isAvailableToday;

  const VenueModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    this.images = const [],
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.distance,
    required this.workingHours,
    required this.priceRange,
    required this.availableTimeSlots,
    required this.description,
    this.depositAmount = '150 000 so\'m',
    this.isPopular = false,
    this.isAvailableToday = false,
  });

  static List<VenueModel> get mockVenues => const [
        VenueModel(
          id: '1',
          name: 'Osteria Da Vinci',
          category: 'Restoran',
          imagePath: AppAssets.onboardingFirst,
          images: [
            AppAssets.onboardingFirst,
            AppAssets.onboardingSecond,
            AppAssets.onboardingThird,
          ],
          rating: 4.8,
          reviewsCount: 124,
          address: 'Mustaqillik ko\'chasi 12',
          distance: '1.2 km',
          workingHours: 'Bugun: 11:00 - 23:00',
          priceRange: '100 000 - 150 000 so\'m',
          depositAmount: '150 000 so\'m',
          isPopular: true,
          isAvailableToday: true,
          availableTimeSlots: ['17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00'],
          description:
              'Italyancha haqiqiy taomlar, qulay va romantik muhit. Oila va do\'stlar davrasida kechki ovqat uchun mukammal maskan.',
        ),
        VenueModel(
          id: '2',
          name: 'Besh Qozon Osh Markazi',
          category: 'Restoran',
          imagePath: AppAssets.onboardingSecond,
          images: [
            AppAssets.onboardingSecond,
            AppAssets.onboardingThird,
          ],
          rating: 4.9,
          reviewsCount: 340,
          address: 'Iftixor ko\'chasi 1',
          distance: '2.5 km',
          workingHours: 'Bugun: 10:00 - 22:00',
          priceRange: '60 000 - 90 000 so\'m',
          depositAmount: '100 000 so\'m',
          isPopular: true,
          isAvailableToday: true,
          availableTimeSlots: ['12:00', '12:30', '13:00', '18:00', '19:00', '20:00'],
          description:
              'Milliy taomlar, afsonaviy toshkentcha osh va ajoyib mehmondo\'stlik.',
        ),
        VenueModel(
          id: '3',
          name: 'Cyber Arena',
          category: 'Geym klub',
          imagePath: AppAssets.onboardingThird,
          images: [AppAssets.onboardingThird],
          rating: 4.7,
          reviewsCount: 89,
          address: 'Bunyodkor ko\'chasi 15',
          distance: '3.1 km',
          workingHours: '24/7 Ochiq',
          priceRange: '20 000 - 45 000 so\'m/soat',
          depositAmount: '50 000 so\'m',
          isPopular: true,
          isAvailableToday: true,
          availableTimeSlots: ['18:00', '19:00', '20:00', '21:00', '22:00'],
          description:
              'Eng zamonaviy RTX 4080 o\'yin kompyuterlari, VIP xonalar va tezkor internet.',
        ),
        VenueModel(
          id: '4',
          name: 'Barbershop No.1',
          category: 'Sartaroshxona',
          imagePath: AppAssets.onboardingFourth,
          images: [AppAssets.onboardingFourth],
          rating: 4.9,
          reviewsCount: 156,
          address: 'Amir Temur ko\'chasi 28',
          distance: '0.8 km',
          workingHours: 'Bugun: 09:00 - 21:00',
          priceRange: '80 000 - 200 000 so\'m',
          depositAmount: '50 000 so\'m',
          isPopular: false,
          isAvailableToday: true,
          availableTimeSlots: ['14:00', '15:00', '16:00', '17:30', '19:00'],
          description:
              'Erkaklar uchun professional soch va soqol turmaklash xizmati.',
        ),
        VenueModel(
          id: '5',
          name: 'Lumière Beauty',
          category: 'Go\'zallik saloni',
          imagePath: AppAssets.onboardingFifth,
          images: [AppAssets.onboardingFifth],
          rating: 4.8,
          reviewsCount: 98,
          address: 'Oybek ko\'chasi 45',
          distance: '1.7 km',
          workingHours: 'Bugun: 09:00 - 20:00',
          priceRange: '120 000 - 450 000 so\'m',
          depositAmount: '80 000 so\'m',
          isPopular: true,
          isAvailableToday: false,
          availableTimeSlots: ['11:00', '13:00', '15:30', '17:00'],
          description:
              'Ayollar uchun eksklyuziv kosmetologiya, vizaj va soch parvarishi.',
        ),
      ];
}
