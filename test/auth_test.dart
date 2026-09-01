import 'package:bron_mobile/core/network/api_result.dart';
import 'package:bron_mobile/core/network/auth_local_storage.dart';
import 'package:bron_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bron_mobile/features/auth/data/models/auth_token_model.dart';
import 'package:bron_mobile/features/auth/data/models/telegram_auth_request_model.dart';
import 'package:bron_mobile/features/auth/data/models/user_model.dart';
import 'package:bron_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bron_mobile/features/auth/domain/entities/auth_token_entity.dart';
import 'package:bron_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Model & Serialization Tests', () {
    test('UserModel serializes and deserializes correctly from OpenAPI UserOut', () {
      final json = {
        'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'phone': '+998901234567',
        'name': 'Aziz Karimov',
        'telegram_id': 123456789,
        'locale': 'uz',
        'visits_count': 3,
        'no_show_count': 0,
        'blocked_until': null,
        'created_at': '2026-08-27T14:42:03.407Z',
        'is_blocked': false,
      };

      final user = UserModel.fromJson(json);
      expect(user.id, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(user.phone, '+998901234567');
      expect(user.name, 'Aziz Karimov');
      expect(user.telegramId, 123456789);
      expect(user.locale, 'uz');
      expect(user.visitsCount, 3);
      expect(user.isBlocked, false);
    });

    test('AuthTokenModel serializes and deserializes correctly from OpenAPI TokenOut', () {
      final json = {
        'access_token': 'test_jwt_access_token_123',
        'token_type': 'bearer',
        'expires_in': 2592000,
        'is_new_user': false,
        'user': {
          'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          'phone': '+998901234567',
          'name': 'Aziz Karimov',
          'telegram_id': 123456789,
          'locale': 'uz',
          'visits_count': 0,
          'no_show_count': 0,
          'blocked_until': null,
          'created_at': '2026-08-27T14:42:03.407Z',
          'is_blocked': false,
        },
      };

      final tokenModel = AuthTokenModel.fromJson(json);
      expect(tokenModel.accessToken, 'test_jwt_access_token_123');
      expect(tokenModel.tokenType, 'bearer');
      expect(tokenModel.expiresIn, 2592000);
      expect(tokenModel.isNewUser, false);
      expect(tokenModel.user.name, 'Aziz Karimov');
    });

    test('TelegramAuthRequestModel builds valid JSON', () {
      const req = TelegramAuthRequestModel(
        id: 123456789,
        firstName: 'Aziz',
        lastName: 'Karimov',
        username: 'aziz_karimov',
        phone: '+998901234567',
        hash: 'hash123',
      );

      final map = req.toJson();
      expect(map['id'], 123456789);
      expect(map['first_name'], 'Aziz');
      expect(map['last_name'], 'Karimov');
      expect(map['phone'], '+998901234567');
      expect(map['hash'], 'hash123');
    });
  });

  group('AuthRepository Tests', () {
    late FakeAuthRemoteDataSource fakeRemoteDataSource;
    late MemoryAuthLocalStorage memoryAuthLocalStorage;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      fakeRemoteDataSource = FakeAuthRemoteDataSource();
      memoryAuthLocalStorage = MemoryAuthLocalStorage();
      authRepository = AuthRepositoryImpl(
        remoteDataSource: fakeRemoteDataSource,
        authLocalStorage: memoryAuthLocalStorage,
      );
    });

    test('loginWithTelegram saves token to storage and returns Success', () async {
      const req = TelegramAuthRequestModel(id: 123456789, phone: '+998901234567');
      final result = await authRepository.loginWithTelegram(req);

      expect(result, isA<Success<AuthTokenEntity>>());
      expect(memoryAuthLocalStorage.storedToken, 'mock_token_abc');
      expect(authRepository.isLoggedIn, true);
    });

    test('logout clears local storage', () async {
      await memoryAuthLocalStorage.saveAuthToken(
        accessToken: 'initial_token',
        tokenType: 'bearer',
        expiresIn: 3600,
      );
      expect(authRepository.isLoggedIn, true);

      final logoutResult = await authRepository.logout();
      expect(logoutResult, isA<Success<void>>());
      expect(authRepository.isLoggedIn, false);
      expect(memoryAuthLocalStorage.storedToken, isNull);
    });
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders logo, buttons and inputs', (tester) async {
      final fakeRemote = FakeAuthRemoteDataSource();
      final memStorage = MemoryAuthLocalStorage();
      final repo = AuthRepositoryImpl(
        remoteDataSource: fakeRemote,
        authLocalStorage: memStorage,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return MaterialApp(
              home: LoginScreen(authRepository: repo),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Telegram orqali kirish'), findsOneWidget);
      expect(find.text('Davom etish'), findsOneWidget);
      expect(find.text('Ism va familiya'), findsOneWidget);
      expect(find.text('Telefon raqam'), findsOneWidget);
    });
  });
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthTokenModel> loginWithTelegram(TelegramAuthRequestModel request) async {
    return const AuthTokenModel(
      accessToken: 'mock_token_abc',
      expiresIn: 3600,
      isNewUser: false,
      user: UserModel(
        id: 'user_1',
        phone: '+998901234567',
        name: 'Aziz Karimov',
        createdAt: '2026-08-27T00:00:00Z',
      ),
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    return const UserModel(
      id: 'user_1',
      phone: '+998901234567',
      name: 'Aziz Karimov',
      createdAt: '2026-08-27T00:00:00Z',
    );
  }

  @override
  Future<void> logout() async {}
}

class MemoryAuthLocalStorage implements AuthLocalStorage {
  String? storedToken;
  String? storedTokenType;
  int? storedExpiresIn;
  Map<String, dynamic>? storedUser;
  final ValueNotifier<bool> _notifier = ValueNotifier(false);

  @override
  ValueListenable<bool> get authStateListenable => _notifier;

  @override
  bool get isLoggedIn => storedToken != null;

  @override
  Future<void> clear() async {
    storedToken = null;
    storedTokenType = null;
    storedExpiresIn = null;
    storedUser = null;
    _notifier.value = false;
  }

  @override
  Future<String?> getAccessToken() async => storedToken;

  @override
  Future<String?> getTokenType() async => storedTokenType;

  @override
  Future<Map<String, dynamic>?> getUser() async => storedUser;

  @override
  Future<void> saveAuthToken({required String accessToken, required String tokenType, required int expiresIn}) async {
    storedToken = accessToken;
    storedTokenType = tokenType;
    storedExpiresIn = expiresIn;
    _notifier.value = true;
  }

  @override
  Future<void> saveUser(Map<String, dynamic> userMap) async {
    storedUser = userMap;
  }
}
