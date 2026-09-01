import '../../../../../core/network/api_result.dart';
import '../../../../waitlist/data/models/waitlist_model.dart';
import '../../../../waitlist/domain/entities/waitlist_entity.dart';

abstract class StaffWaitlistRepository {
  Future<ApiResult<WaitlistListResult>> getWaitlist({required String kind});
  Future<ApiResult<WaitlistEntity>> add({
    required String guestName,
    required int guests,
    String? guestPhone,
    String? zoneId,
    String? idempotencyKey,
  });
  Future<ApiResult<WaitlistEntity>> call(String id, {String? tableId, String? idempotencyKey});
  Future<ApiResult<WaitlistEntity>> seat(String id, String tableId, {String? idempotencyKey});
  Future<ApiResult<bool>> remove(String id, {String? idempotencyKey});
}
