import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    super.avatarUrl,
    super.birthDate,
    super.gender,
    super.bonusBalance,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      bonusBalance: json['bonus_balance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'birth_date': birthDate,
      'gender': gender,
      'bonus_balance': bonusBalance,
    };
  }

  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      birthDate: entity.birthDate,
      gender: entity.gender,
      bonusBalance: entity.bonusBalance,
    );
  }
}
