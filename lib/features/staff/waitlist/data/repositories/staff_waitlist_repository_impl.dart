import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../../../waitlist/data/models/waitlist_model.dart';
import '../../../../waitlist/domain/entities/waitlist_entity.dart';
import '../../domain/repositories/staff_waitlist_repository.dart';
import '../datasources/staff_waitlist_remote_data_source.dart';

class StaffWaitlistRepositoryImpl implements StaffWaitlistRepository {
  final StaffWaitlistRemoteDataSource remoteDataSource;

  StaffWaitlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<WaitlistListResult>> getWaitlist({required String kind}) async {
    try {
      return ApiResult.success(await remoteDataSource.getWaitlist(kind: kind));
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<WaitlistEntity>> add({
    required String guestName,
    required int guests,
    String? guestPhone,
    String? zoneId,
    String? idempotencyKey,
  }) async {
    try {
      return ApiResult.success(await remoteDataSource.add(
        guestName: guestName,
        guests: guests,
        guestPhone: guestPhone,
        zoneId: zoneId,
        idempotencyKey: idempotencyKey,
      ));
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<WaitlistEntity>> call(String id, {String? tableId, String? idempotencyKey}) async {
    try {
      return ApiResult.success(await remoteDataSource.call(id, tableId: tableId, idempotencyKey: idempotencyKey));
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<WaitlistEntity>> seat(String id, String tableId, {String? idempotencyKey}) async {
    try {
      return ApiResult.success(await remoteDataSource.seat(id, tableId, idempotencyKey: idempotencyKey));
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> remove(String id, {String? idempotencyKey}) async {
    try {
      await remoteDataSource.remove(id, idempotencyKey: idempotencyKey);
      return ApiResult.success(true);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}
