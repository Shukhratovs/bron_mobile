class VenueFilters {
  final String? kind;
  final String? district;
  final String? cuisine;
  final String? check;
  final double? ratingMin;
  final String? sort;

  const VenueFilters({
    this.kind,
    this.district,
    this.cuisine,
    this.check,
    this.ratingMin,
    this.sort,
  });

  bool get isEmpty =>
      kind == null && district == null && cuisine == null && check == null && ratingMin == null && sort == null;

  VenueFilters copyWith({
    String? kind,
    bool clearKind = false,
    String? district,
    String? cuisine,
    String? check,
    bool clearCheck = false,
    double? ratingMin,
    bool clearRating = false,
    String? sort,
    bool clearSort = false,
  }) {
    return VenueFilters(
      kind: clearKind ? null : (kind ?? this.kind),
      district: district ?? this.district,
      cuisine: cuisine ?? this.cuisine,
      check: clearCheck ? null : (check ?? this.check),
      ratingMin: clearRating ? null : (ratingMin ?? this.ratingMin),
      sort: clearSort ? null : (sort ?? this.sort),
    );
  }
}
