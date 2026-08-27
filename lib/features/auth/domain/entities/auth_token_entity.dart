import 'user_entity.dart';

class AuthTokenEntity {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final bool isNewUser;
  final UserEntity user;

  const AuthTokenEntity({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.expiresIn,
    required this.isNewUser,
    required this.user,
  });
}
