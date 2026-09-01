import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/bonus_history_entity.dart';
import '../../domain/entities/notification_item_entity.dart';
import '../models/bonus_history_model.dart';
import '../models/favorite_place_model.dart';
import '../models/notification_item_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
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

  @override
  Future<UserProfileModel> getUserProfile() async {
    // `GET /me` token talab qiladi (Bearer yo'q bo'lsa 401) — token
    // yo'q/eskirgan holatda xato tepaga o'tkaziladi, soxta profil
    // "ko'rsatilmaydi" (aks holda ProfileScreen har doim kirilgan
    // deb o'ylaydi). ApiResult.Failure orqali Login ekrani chiqadi.
    final response = await apiClient.get(ApiEndpoints.me);
    return UserProfileModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    final payload = {
      'name': profile.fullName,
      'locale': profile.locale,
    };
    final response = await apiClient.patch(
      ApiEndpoints.me,
      body: payload,
    );
    return UserProfileModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<List<FavoritePlaceModel>> getFavoritePlaces() async {
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
    try {
      final response = await apiClient.get(ApiEndpoints.notifications);
      if (response is Map && response['items'] is List) {
        return (response['items'] as List)
            .map((item) => NotificationItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

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
        title: 'Keshbek hisobingizga tushdi',
        message: 'Besh Qozon tashrifi uchun +15 000 so\'m bonus balansingizga qo\'shildi.',
        time: 'Kecha, 21:30',
        type: NotificationType.bonus,
        isRead: true,
      ),
      NotificationItemModel(
        id: 'notif-3',
        title: 'Yangi aksiya!',
        message: 'Barcha geym klublarida dushanba kunlari 20% chegirma.',
        time: '2 kun oldin',
        type: NotificationType.promo,
        isRead: true,
      ),
    ];
  }

  @override
  Future<List<BonusHistoryModel>> getBonusHistory() async {
    return const [
      BonusHistoryModel(
        id: 'bon-1',
        title: 'Osteria Da Vinci tashrifi',
        date: 'Bugun, 14:20',
        amount: 15000,
        type: BonusTransactionType.earned,
      ),
      BonusHistoryModel(
        id: 'bon-2',
        title: 'Bron chegirmasi uchun',
        date: '22-iyul, 19:45',
        amount: 20000,
        type: BonusTransactionType.spent,
      ),
      BonusHistoryModel(
        id: 'bon-3',
        title: 'Do\'stni taklif qilganlik uchun',
        date: '15-iyul, 12:00',
        amount: 30000,
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
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Continue
    }
    return true;
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Continue
    }
    return true;
  }
}
