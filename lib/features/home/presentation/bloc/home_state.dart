part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<VenueEntity> venues;
  final List<VenueEntity> todayVenues;
  final String? selectedKind;
  final VenueFilters filters;
  final String? errorMessage;
  final bool isOffline;

  const HomeState({
    this.status = HomeStatus.initial,
    this.venues = const [],
    this.todayVenues = const [],
    this.selectedKind = 'restoran',
    this.filters = const VenueFilters(),
    this.errorMessage,
    this.isOffline = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<VenueEntity>? venues,
    List<VenueEntity>? todayVenues,
    String? selectedKind,
    VenueFilters? filters,
    String? errorMessage,
    bool? isOffline,
    bool clearKind = false,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      todayVenues: todayVenues ?? this.todayVenues,
      selectedKind: clearKind ? null : (selectedKind ?? this.selectedKind),
      filters: filters ?? this.filters,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOffline: clearError ? false : (isOffline ?? this.isOffline),
    );
  }

  @override
  List<Object?> get props => [status, venues, todayVenues, selectedKind, filters, errorMessage, isOffline];
}
