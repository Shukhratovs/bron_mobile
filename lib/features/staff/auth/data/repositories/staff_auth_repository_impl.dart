import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../domain/entities/staff_auth_entity.dart';
import '../../domain/repositories/staff_auth_repository.dart';
import '../datasources/staff_auth_remote_data_source.dart';

class StaffAuthRepositoryImpl implements StaffAuthRepository {
  final StaffAuthRemoteDataSource remoteDataSource;

  StaffAuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<TelegramLoginStart>> start() async {
    try {
      return ApiResult.success(await remoteDataSource.start());
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<TelegramLoginPollResult>> poll(String nonce) async {
    try {
      return ApiResult.success(await remoteDataSource.poll(nonce));
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<StaffVenueEntity>>> getVenues() async {
    try {
      return ApiResult.success(await remoteDataSource.getVenues());
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}
