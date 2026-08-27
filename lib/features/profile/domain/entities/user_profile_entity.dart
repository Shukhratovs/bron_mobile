class UserProfileEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? avatarUrl;
  final String? birthDate;
  final String? gender;
  final int bonusBalance;

  const UserProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.bonusBalance = 0,
  });

  String get fullName => '$firstName $lastName'.trim();

  UserProfileEntity copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    String? birthDate,
    String? gender,
    int? bonusBalance,
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
    );
  }
}
