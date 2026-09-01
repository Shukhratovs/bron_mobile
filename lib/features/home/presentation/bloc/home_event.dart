part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeCategorySelected extends HomeEvent {
  final String? kind;

  const HomeCategorySelected(this.kind);

  @override
  List<Object?> get props => [kind];
}

class HomeFiltersChanged extends HomeEvent {
  final VenueFilters filters;

  const HomeFiltersChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}
