import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../domain/entities/staff_auth_entity.dart';

abstract class StaffAuthRemoteDataSource {
  Future<TelegramLoginStart> start();
  Future<TelegramLoginPollResult> poll(String nonce);
  Future<List<StaffVenueEntity>> getVenues();
}

class StaffAuthRemoteDataSourceImpl implements StaffAuthRemoteDataSource {
  final ApiClient apiClient;

  StaffAuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TelegramLoginStart> start() async {
    final response = await apiClient.post(ApiEndpoints.staffAuthTelegramStart);
    return TelegramLoginStart.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<TelegramLoginPollResult> poll(String nonce) async {
    try {
      final response = await apiClient.get(ApiEndpoints.staffAuthTelegramStatus(nonce));
      final map = (response as Map).cast<String, dynamic>();
      if (map.containsKey('access_token')) {
        return TelegramLoginPollResult(
          status: TelegramLoginPollStatus.success,
          token: StaffTokenOut.fromJson(map),
        );
      }
      return const TelegramLoginPollResult(status: TelegramLoginPollStatus.pending);
    } on NetworkException catch (e) {
      if (e.code == 'login_expired') {
        return const TelegramLoginPollResult(status: TelegramLoginPollStatus.loginExpired);
      }
      if (e.code == 'staff_not_found') {
        return const TelegramLoginPollResult(status: TelegramLoginPollStatus.staffNotFound);
      }
      rethrow;
    }
  }

  @override
  Future<List<StaffVenueEntity>> getVenues() async {
    final response = await apiClient.get(ApiEndpoints.staffVenues);
    if (response is List) {
      return response.map((e) => StaffVenueEntity.fromJson((e as Map).cast<String, dynamic>())).toList();
    }
    return const [];
  }
}
