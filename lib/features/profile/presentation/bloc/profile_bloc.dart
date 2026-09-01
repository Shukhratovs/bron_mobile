import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_session.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final CardRepository cardRepository;

  ProfileBloc({
    required this.profileRepository,
    required this.cardRepository,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (!AppSession.authLocalStorage.isLoggedIn) {
      emit(const ProfileState(status: ProfileStatus.loaded));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    final results = await Future.wait([
      profileRepository.getUserProfile(),
      cardRepository.getCards(),
    ]);

    final profileResult = results[0] as ApiResult<UserProfileEntity>;
    final cardsResult = results[1] as ApiResult<List<CardEntity>>;

    UserProfileEntity? user;
    List<CardEntity> cards = [];
    String? error;

    switch (profileResult) {
      case Success(:final data):
        user = data;
      case Failure(:final exception):
        error = exception.message;
    }

    if (cardsResult case Success(:final data)) {
      cards = data;
    }

    emit(ProfileState(
      status: error != null ? ProfileStatus.error : ProfileStatus.loaded,
      user: user,
      cards: cards,
      favoritesCount: AppSession.favorites.count,
      errorMessage: error,
    ));
  }

  void _onUpdated(ProfileUpdated event, Emitter<ProfileState> emit) {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await profileRepository.logout();
    await AppSession.authLocalStorage.clear();
    emit(const ProfileState(
      status: ProfileStatus.loggedOut,
    ));
  }
}
