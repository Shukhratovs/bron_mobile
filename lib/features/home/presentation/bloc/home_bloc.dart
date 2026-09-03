import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../venue/domain/entities/venue_entity.dart';
import '../../../venue/domain/repositories/venue_repository.dart';
import '../../domain/venue_filters.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final VenueRepository venueRepository;

  HomeBloc({required this.venueRepository}) : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeFiltersChanged>(_onFiltersChanged);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    final today = DateTime.now();
    final dateParam =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final kind = state.selectedKind ?? state.filters.kind;

    final results = await Future.wait([
      venueRepository.getVenues(
        kind: kind,
        district: state.filters.district,
        cuisine: state.filters.cuisine,
        check: state.filters.check,
        ratingMin: state.filters.ratingMin,
        sort: state.filters.sort == 'yaqin' ? null : state.filters.sort,
        date: state.filters.dateParam,
        guests: state.filters.effectiveGuests,
        limit: 20,
      ),
      venueRepository.getVenues(
        kind: kind ?? 'restoran',
        date: dateParam,
        guests: 2,
        limit: 6,
      ),
    ]);

    final listResult = results[0];
    final todayResult = results[1];

    List<VenueEntity> venues = [];
    List<VenueEntity> todayVenues = state.todayVenues;
    String? error;
    bool isOffline = false;

    switch (listResult) {
      case Success(:final data):
        venues = state.filters.hasClientOnlyFilters
            ? data.items.where(state.filters.matchesClientSide).toList()
            : data.items;
      case Failure(:final exception):
        error = exception.message;
        isOffline = exception is NoInternetException;
    }

    if (todayResult case Success(:final data)) {
      todayVenues = data.items;
    }

    emit(state.copyWith(
      status: error != null ? HomeStatus.error : HomeStatus.loaded,
      venues: venues,
      todayVenues: todayVenues,
      errorMessage: error,
      isOffline: isOffline,
    ));
  }

  void _onCategorySelected(
    HomeCategorySelected event,
    Emitter<HomeState> emit,
  ) {
    final newKind = state.selectedKind == event.kind ? null : event.kind;
    emit(state.copyWith(
      selectedKind: newKind,
      clearKind: newKind == null,
    ));
    add(const HomeLoadRequested());
  }

  void _onFiltersChanged(
    HomeFiltersChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(filters: event.filters));
    add(const HomeLoadRequested());
  }
}
