import '../../../../core/constants/app_assets.dart';
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
    super.telegramId,
    super.locale = 'uz',
    super.visitsCount = 0,
    super.noShowCount = 0,
    super.blockedUntil,
    super.createdAt,
    super.isBlocked = false,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String fName = '';
    String lName = '';

    if (json['first_name'] != null || json['last_name'] != null) {
      fName = json['first_name']?.toString() ?? '';
      lName = json['last_name']?.toString() ?? '';
    } else if (json['name'] != null) {
      final parts = json['name'].toString().trim().split(' ');
      if (parts.isNotEmpty) {
        fName = parts.first;
        if (parts.length > 1) {
          lName = parts.sublist(1).join(' ');
        }
      }
    }

    final phone = json['phone']?.toString() ?? json['phone_number']?.toString() ?? '';

    return UserProfileModel(
      id: json['id'] ?? 'user_1',
      firstName: fName.isNotEmpty ? fName : 'Aziz',
      lastName: lName.isNotEmpty ? lName : 'Karimov',
      phoneNumber: phone.isNotEmpty ? phone : '+998 90 123-45-67',
      avatarUrl: json['avatar_url']?.toString() ?? json['photo_url']?.toString() ?? AppAssets.me,
      birthDate: json['birth_date']?.toString(),
      gender: json['gender']?.toString(),
      bonusBalance: json['bonus_balance'] is int ? json['bonus_balance'] as int : 25000,
      telegramId: json['telegram_id'] is int ? json['telegram_id'] as int : null,
      locale: json['locale']?.toString() ?? 'uz',
      visitsCount: json['visits_count'] is int ? json['visits_count'] as int : 0,
      noShowCount: json['no_show_count'] is int ? json['no_show_count'] as int : 0,
      blockedUntil: json['blocked_until']?.toString(),
      createdAt: json['created_at']?.toString(),
      isBlocked: json['is_blocked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'name': fullName,
      'phone': phoneNumber,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'birth_date': birthDate,
      'gender': gender,
      'bonus_balance': bonusBalance,
      'telegram_id': telegramId,
      'locale': locale,
      'visits_count': visitsCount,
      'no_show_count': noShowCount,
      'blocked_until': blockedUntil,
      'created_at': createdAt,
      'is_blocked': isBlocked,
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
      telegramId: entity.telegramId,
      locale: entity.locale,
      visitsCount: entity.visitsCount,
      noShowCount: entity.noShowCount,
      blockedUntil: entity.blockedUntil,
      createdAt: entity.createdAt,
      isBlocked: entity.isBlocked,
    );
  }
}
