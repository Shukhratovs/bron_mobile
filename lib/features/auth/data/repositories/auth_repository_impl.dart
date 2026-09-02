import 'package:flutter/foundation.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/auth_local_storage.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/telegram_login_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalStorage authLocalStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalStorage,
  });

  @override
  bool get isLoggedIn => authLocalStorage.isLoggedIn;

  @override
  ValueListenable<bool> get authStateListenable => authLocalStorage.authStateListenable;

  @override
  Future<ApiResult<TelegramLoginStart>> startTelegramLogin() async {
    try {
      return Success(await remoteDataSource.startTelegramLogin());
    } on NetworkException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<TelegramLoginPollResult>> pollTelegramLogin(String nonce) async {
    try {
      final result = await remoteDataSource.pollTelegramLogin(nonce);
      final tokenModel = result.token;
      if (result.status == TelegramLoginPollStatus.success && tokenModel is AuthTokenModel) {
        await authLocalStorage.saveAuthToken(
          accessToken: tokenModel.accessToken,
          tokenType: tokenModel.tokenType,
          expiresIn: tokenModel.expiresIn,
        );
        if (tokenModel.user is UserModel) {
          await authLocalStorage.saveUser((tokenModel.user as UserModel).toJson());
        }
      }
      return Success(result);
    } on NetworkException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<UserEntity>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      await authLocalStorage.saveUser(userModel.toJson());
      return Success(userModel);
    } on NetworkException catch (e) {
      // Offline fallback: try reading cached user
      final cached = await authLocalStorage.getUser();
      if (cached != null) {
        return Success(UserModel.fromJson(cached));
      }
      return Failure(e);
    } catch (e) {
      return Failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      try {
        await remoteDataSource.logout();
      } catch (_) {
        // Continue clearing local token even if server logout returns error
      }
      await authLocalStorage.clear();
      return const Success(null);
    } on NetworkException catch (e) {
      await authLocalStorage.clear();
      return Failure(e);
    } catch (e) {
      await authLocalStorage.clear();
      return Failure(NetworkException(message: e.toString()));
    }
  }
}
