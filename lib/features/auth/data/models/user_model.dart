import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    required super.name,
    super.telegramId,
    super.locale = 'uz',
    super.visitsCount = 0,
    super.noShowCount = 0,
    super.blockedUntil,
    required super.createdAt,
    super.isBlocked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      telegramId: json['telegram_id'] is int ? json['telegram_id'] as int : null,
      locale: json['locale']?.toString() ?? 'uz',
      visitsCount: json['visits_count'] is int ? json['visits_count'] as int : 0,
      noShowCount: json['no_show_count'] is int ? json['no_show_count'] as int : 0,
      blockedUntil: json['blocked_until']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      isBlocked: json['is_blocked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'telegram_id': telegramId,
      'locale': locale,
      'visits_count': visitsCount,
      'no_show_count': noShowCount,
      'blocked_until': blockedUntil,
      'created_at': createdAt,
      'is_blocked': isBlocked,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    int? telegramId,
    String? locale,
    int? visitsCount,
    int? noShowCount,
    String? blockedUntil,
    String? createdAt,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      telegramId: telegramId ?? this.telegramId,
      locale: locale ?? this.locale,
      visitsCount: visitsCount ?? this.visitsCount,
      noShowCount: noShowCount ?? this.noShowCount,
      blockedUntil: blockedUntil ?? this.blockedUntil,
      createdAt: createdAt ?? this.createdAt,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
