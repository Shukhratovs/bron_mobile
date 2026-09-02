part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, error, loggedOut }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfileEntity? user;
  final List<CardEntity> cards;
  final int favoritesCount;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.cards = const [],
    this.favoritesCount = 0,
    this.errorMessage,
  });

  bool get isLoggedIn => user != null;

  String get cardSubtitle {
    if (cards.isEmpty) return 'Karta qo\'shilmagan';
    // `.cast<CardEntity>()` — `cards`ning haqiqiy runtime turi (masalan
    // `List<CardModel>`) `firstWhere`ning `orElse` imzosini `CardModel
    // Function()` deb talab qilib qo'yishining oldini oladi (Dart
    // generic'lari reifikatsiya qilinadi), aks holda `() => cards.first`
    // (statik tur `CardEntity Function()`) mos kelmay xato beradi.
    final defaultCard = cards.cast<CardEntity>().firstWhere(
      (c) => c.isDefault,
      orElse: () => cards.first,
    );
    final provider = defaultCard.provider.isNotEmpty
        ? defaultCard.provider.toUpperCase()
        : 'KARTA';
    return '$provider ${defaultCard.maskedPan}';
  }

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileEntity? user,
    List<CardEntity>? cards,
    int? favoritesCount,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      cards: cards ?? this.cards,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, cards, favoritesCount, errorMessage];
}
