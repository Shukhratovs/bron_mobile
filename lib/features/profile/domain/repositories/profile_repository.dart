import '../../../../core/network/api_result.dart';
import '../entities/booking_entity.dart';
import '../entities/bonus_history_entity.dart';
import '../entities/favorite_place_entity.dart';
import '../entities/notification_item_entity.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserProfileEntity>> getUserProfile();
  Future<ApiResult<UserProfileEntity>> updateProfile(UserProfileEntity profile);
  Future<ApiResult<List<BookingEntity>>> getMyBookings();
  Future<ApiResult<List<FavoritePlaceEntity>>> getFavoritePlaces();
  Future<ApiResult<List<NotificationItemEntity>>> getNotifications();
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
