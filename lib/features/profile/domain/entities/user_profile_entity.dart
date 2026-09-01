class UserProfileEntity {
  final dynamic id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? avatarUrl;
  final String? birthDate;
  final String? gender;
  final int bonusBalance;
  final int? telegramId;
  final String locale;
  final int visitsCount;
  final int noShowCount;
  final String? blockedUntil;
  final String? createdAt;
  final bool isBlocked;

  const UserProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.bonusBalance = 25000,
    this.telegramId,
    this.locale = 'uz',
    this.visitsCount = 0,
    this.noShowCount = 0,
    this.blockedUntil,
    this.createdAt,
    this.isBlocked = false,
  });

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    if (combined.isNotEmpty) return combined;
    return phoneNumber;
  }

  UserProfileEntity copyWith({
    dynamic id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    String? birthDate,
    String? gender,
    int? bonusBalance,
    int? telegramId,
    String? locale,
    int? visitsCount,
    int? noShowCount,
    String? blockedUntil,
    String? createdAt,
    bool? isBlocked,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bonusBalance: bonusBalance ?? this.bonusBalance,
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
