import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_token_model.dart';
import '../models/telegram_auth_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> loginWithTelegram(TelegramAuthRequestModel request);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthTokenModel> loginWithTelegram(TelegramAuthRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.telegramAuth,
      body: request.toJson(),
    );
    return AuthTokenModel.fromJson(response as Map<String, dynamic>);
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
