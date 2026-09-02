import '../../../../core/network/api_result.dart';
import '../../data/models/notification_item_model.dart';
import '../entities/bonus_history_entity.dart';
import '../entities/favorite_place_entity.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserProfileEntity>> getUserProfile();
  Future<ApiResult<UserProfileEntity>> updateProfile(UserProfileEntity profile);
  Future<ApiResult<List<FavoritePlaceEntity>>> getFavoritePlaces();
  Future<ApiResult<NotificationListResponse>> getNotifications({int limit = 20, int offset = 0, bool unreadOnly = false});
  Future<ApiResult<void>> markNotificationRead(String id);
  Future<ApiResult<void>> markAllNotificationsRead();
  Future<ApiResult<List<BonusHistoryEntity>>> getBonusHistory();
  Future<ApiResult<bool>> submitPartnerApplication({
    required String businessName,
    required String category,
    required String contactPerson,
    required String phone,
    required String address,
  });
  Future<ApiResult<bool>> logout();
  Future<ApiResult<bool>> deleteAccount();
}
