import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/bonus_history_entity.dart';
import '../../domain/entities/notification_item_entity.dart';
import '../models/booking_model.dart';
import '../models/bonus_history_model.dart';
import '../models/favorite_place_model.dart';
import '../models/notification_item_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<List<BookingModel>> getMyBookings();
  Future<List<FavoritePlaceModel>> getFavoritePlaces();
  Future<List<NotificationItemModel>> getNotifications();
  Future<List<BonusHistoryModel>> getBonusHistory();
  Future<bool> submitPartnerApplication({
    required String businessName,
    required String category,
    required String contactPerson,
    required String phone,
    required String address,
  });
  Future<bool> logout();
  Future<bool> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  UserProfileModel _currentUser = const UserProfileModel(
    id: 1,
    firstName: 'Aziz',
    lastName: 'Karimov',
    phoneNumber: '+998 90 123-45-67',
    avatarUrl: AppAssets.me,
    birthDate: '15.08.1996',
    gender: 'Erkak',
    bonusBalance: 25000,
  );

  @override
  Future<UserProfileModel> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = profile;
    return _currentUser;
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      BookingModel(
        id: 'BRN-4821',
        venueName: 'Osteria Da Vinci',
        venueCategory: 'Restoran · Yevropa oshxonasi',
        address: 'Bunyodkor ko\'chasi 12, Chilonzor',
        dateTime: 'Bugun, 19:00',
        guestCount: 4,
        qrCode: 'BRN-4821',
        status: BookingStatus.confirmed,
        price: 120000,
      ),
      BookingModel(
        id: 'BRN-3910',
        venueName: 'Level Up Game Club',
        venueCategory: 'Geym klub · VIP zal',
        address: 'Amir Temur shox ko\'chasi 45, Yunusobod',
        dateTime: '28-iyul, 20:00',
        guestCount: 5,
        qrCode: 'BRN-3910',
        status: BookingStatus.pending,
        price: 90000,
      ),
      BookingModel(
        id: 'BRN-1024',
        venueName: 'Chorsu Osh Markazi',
        venueCategory: 'Milliy taomlar',
        address: 'Chorsu maydoni 1, Shayxontohur',
        dateTime: '20-iyul, 13:00',
        guestCount: 6,
        qrCode: 'BRN-1024',
        status: BookingStatus.completed,
        price: 250000,
      ),
    ];
  }

  @override
  Future<List<FavoritePlaceModel>> getFavoritePlaces() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      FavoritePlaceModel(
        id: 'fav-1',
        name: 'Osteria Da Vinci',
        category: 'Yevropa oshxonasi · Chilonzor',
        location: '1.2 km · ~120 000 so\'m',
        rating: 4.8,
        reviewsCount: 124,
        imagePath: AppAssets.onboardingThird,
        averageCheck: '120 000 so\'m',
        isFavorite: true,
      ),
      FavoritePlaceModel(
        id: 'fav-2',
        name: 'Chorsu Osh Markazi',
        category: 'Milliy oshxona · Shayxontohur',
        location: '3.4 km · ~45 000 so\'m',
        rating: 4.6,
        reviewsCount: 89,
        imagePath: AppAssets.onboardingFirst,
        averageCheck: '45 000 so\'m',
        isFavorite: true,
      ),
    ];
  }

  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      NotificationItemModel(
        id: 'notif-1',
        title: 'Bron tasdiqlandi!',
        message: 'Osteria Da Vinci restoraniga 19:00 ga qilgan broningiz muvaffaqiyatli tasdiqlandi.',
        time: '5 daqiqa oldin',
        type: NotificationType.booking,
        isRead: false,
      ),
      NotificationItemModel(
        id: 'notif-2',
        title: '+5 000 Bron Bonusi qo\'shildi',
        message: 'Oxirgi tashrifingiz uchun hisobingizga keshbek bonusi o\'tkazildi.',
        time: 'Kecha, 18:30',
        type: NotificationType.bonus,
        isRead: true,
      ),
      NotificationItemModel(
        id: 'notif-3',
        title: 'Maxsus taklif: 20% chegirma',
        message: 'Dam olish kunlari barcha geym klublarda 20% gacha keshbek oling.',
        time: '2 kun oldin',
        type: NotificationType.promo,
        isRead: true,
      ),
    ];
  }

  @override
  Future<List<BonusHistoryModel>> getBonusHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      BonusHistoryModel(
        id: 'b-1',
        title: 'Osteria Da Vinci tashrifi',
        date: '27-iyul, 2026',
        amount: 5000,
        type: BonusTransactionType.earned,
      ),
      BonusHistoryModel(
        id: 'b-2',
        title: 'Level Up Game bron to\'lovi',
        date: '22-iyul, 2026',
        amount: 10000,
        type: BonusTransactionType.spent,
      ),
      BonusHistoryModel(
        id: 'b-3',
        title: 'Ro\'yxatdan o\'tish sovg\'asi',
        date: '15-iyul, 2026',
        amount: 20000,
        type: BonusTransactionType.earned,
      ),
    ];
  }

  @override
  Future<bool> submitPartnerApplication({
    required String businessName,
    required String category,
    required String contactPerson,
    required String phone,
    required String address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  @override
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
