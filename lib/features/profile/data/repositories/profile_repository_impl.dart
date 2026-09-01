import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/bonus_history_entity.dart';
import '../../domain/entities/favorite_place_entity.dart';
import '../../domain/entities/notification_item_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<UserProfileEntity>> getUserProfile() async {
    try {
      final user = await remoteDataSource.getUserProfile();
      return ApiResult.success(user);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<UserProfileEntity>> updateProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final updated = await remoteDataSource.updateProfile(model);
      return ApiResult.success(updated);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<FavoritePlaceEntity>>> getFavoritePlaces() async {
    try {
      final favorites = await remoteDataSource.getFavoritePlaces();
      return ApiResult.success(favorites);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<NotificationItemEntity>>> getNotifications() async {
    try {
      final notifications = await remoteDataSource.getNotifications();
      return ApiResult.success(notifications);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<BonusHistoryEntity>>> getBonusHistory() async {
    try {
      final history = await remoteDataSource.getBonusHistory();
      return ApiResult.success(history);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> submitPartnerApplication({
    required String businessName,
    required String category,
    required String contactPerson,
    required String phone,
    required String address,
  }) async {
    try {
      final result = await remoteDataSource.submitPartnerApplication(
        businessName: businessName,
        category: category,
        contactPerson: contactPerson,
        phone: phone,
        address: address,
      );
      return ApiResult.success(result);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> logout() async {
    try {
      final result = await remoteDataSource.logout();
      return ApiResult.success(result);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> deleteAccount() async {
    try {
      final result = await remoteDataSource.deleteAccount();
      return ApiResult.success(result);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}
