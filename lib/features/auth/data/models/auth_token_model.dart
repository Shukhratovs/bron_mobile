import '../../domain/entities/auth_token_entity.dart';
import 'user_model.dart';

class AuthTokenModel extends AuthTokenEntity {
  const AuthTokenModel({
    required super.accessToken,
    super.tokenType = 'bearer',
    required super.expiresIn,
    required super.isNewUser,
    required super.user,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      expiresIn: json['expires_in'] is int ? json['expires_in'] as int : 0,
      isNewUser: json['is_new_user'] == true,
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : UserModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'is_new_user': isNewUser,
      'user': (user as UserModel).toJson(),
    };
  }
}
