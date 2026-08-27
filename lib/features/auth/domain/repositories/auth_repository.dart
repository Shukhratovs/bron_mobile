import 'package:flutter/foundation.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/telegram_auth_request_model.dart';
import '../entities/auth_token_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthTokenEntity>> loginWithTelegram(TelegramAuthRequestModel request);
  Future<ApiResult<UserEntity>> getCurrentUser();
  Future<ApiResult<void>> logout();
  bool get isLoggedIn;
  ValueListenable<bool> get authStateListenable;
}
