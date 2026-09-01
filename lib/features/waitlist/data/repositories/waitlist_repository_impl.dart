import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/waitlist_entity.dart';
import '../../domain/repositories/waitlist_repository.dart';
import '../datasources/waitlist_remote_data_source.dart';

class WaitlistRepositoryImpl implements WaitlistRepository {
  final WaitlistRemoteDataSource remoteDataSource;

  WaitlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<WaitlistEntity>> join({
    required String venueId,
    required int guests,
    required DateTime desiredFrom,
    required DateTime desiredTo,
  }) async {
    try {
      final entry = await remoteDataSource.join(
        venueId: venueId,
        guests: guests,
        desiredFrom: desiredFrom,
        desiredTo: desiredTo,
      );
      return ApiResult.success(entry);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<WaitlistEntity>>> getMine() async {
    try {
      final entries = await remoteDataSource.getMine();
      return ApiResult.success(entries);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<WaitlistEntity>> confirm(String id, {String? tableId}) async {
    try {
      final entry = await remoteDataSource.confirm(id, tableId: tableId);
      return ApiResult.success(entry);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> leave(String id) async {
    try {
      await remoteDataSource.leave(id);
      return ApiResult.success(true);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}
