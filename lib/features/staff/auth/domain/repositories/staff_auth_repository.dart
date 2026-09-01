import '../../../../../core/network/api_result.dart';
import '../entities/staff_auth_entity.dart';

abstract class StaffAuthRepository {
  Future<ApiResult<TelegramLoginStart>> start();
  Future<ApiResult<TelegramLoginPollResult>> poll(String nonce);
  Future<ApiResult<List<StaffVenueEntity>>> getVenues();
}
