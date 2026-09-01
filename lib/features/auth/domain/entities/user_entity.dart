class UserEntity {
  final String id;
  final String phone;
  final String name;
  final int? telegramId;
  final String locale;
  final int visitsCount;
  final int noShowCount;
  final String? blockedUntil;
  final String createdAt;
  final bool isBlocked;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    this.telegramId,
    this.locale = 'uz',
    this.visitsCount = 0,
    this.noShowCount = 0,
    this.blockedUntil,
    required this.createdAt,
    this.isBlocked = false,
  });

  String get displayName => name.isNotEmpty ? name : phone;
}
