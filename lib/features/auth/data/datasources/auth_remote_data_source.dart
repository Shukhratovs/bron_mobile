import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/telegram_login_entity.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TelegramLoginStart> startTelegramLogin();
  Future<TelegramLoginPollResult> pollTelegramLogin(String nonce);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TelegramLoginStart> startTelegramLogin() async {
    final response = await apiClient.post(ApiEndpoints.telegramAuthStart);
    return TelegramLoginStart.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<TelegramLoginPollResult> pollTelegramLogin(String nonce) async {
    try {
      final response = await apiClient.get(ApiEndpoints.telegramAuthStatus(nonce));
      final map = (response as Map).cast<String, dynamic>();
      if (map.containsKey('access_token')) {
        return TelegramLoginPollResult(
          status: TelegramLoginPollStatus.success,
          token: AuthTokenModel.fromJson(map),
        );
      }
      return const TelegramLoginPollResult(status: TelegramLoginPollStatus.pending);
    } on NetworkException catch (e) {
      if (e.code == 'login_expired' || e.statusCode == 404) {
        return const TelegramLoginPollResult(status: TelegramLoginPollStatus.expired);
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.logout);
  }
}
