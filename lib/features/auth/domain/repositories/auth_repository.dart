import 'package:flutter/foundation.dart';
import '../../../../core/network/api_result.dart';
import '../entities/telegram_login_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<TelegramLoginStart>> startTelegramLogin();
  Future<ApiResult<TelegramLoginPollResult>> pollTelegramLogin(String nonce);
  Future<ApiResult<UserEntity>> getCurrentUser();
  Future<ApiResult<void>> logout();
  bool get isLoggedIn;
  ValueListenable<bool> get authStateListenable;
}
