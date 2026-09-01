part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdated extends ProfileEvent {
  final UserProfileEntity user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}
