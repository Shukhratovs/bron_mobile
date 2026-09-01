import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/telegram_auth_request_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthController({required this.authRepository}) {
    _init();
  }

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> _init() async {
    if (authRepository.isLoggedIn) {
      _status = AuthStatus.loading;
      notifyListeners();

      final result = await authRepository.getCurrentUser();
      result.when(
        onSuccess: (user) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
        },
        onFailure: (_) {
          _status = AuthStatus.unauthenticated;
        },
      );
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> loginWithTelegram(TelegramAuthRequestModel request) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.loginWithTelegram(request);
    return result.when(
      onSuccess: (tokenEntity) {
        _currentUser = tokenEntity.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
      onFailure: (exception) {
        _errorMessage = exception.message;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await authRepository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
