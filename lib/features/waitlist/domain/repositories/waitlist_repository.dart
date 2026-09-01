import '../../../../core/network/api_result.dart';
import '../entities/waitlist_entity.dart';

abstract class WaitlistRepository {
  Future<ApiResult<WaitlistEntity>> join({
    required String venueId,
    required int guests,
    required DateTime desiredFrom,
    required DateTime desiredTo,
  });
  Future<ApiResult<List<WaitlistEntity>>> getMine();
  Future<ApiResult<WaitlistEntity>> confirm(String id, {String? tableId});
  Future<ApiResult<bool>> leave(String id);
}
