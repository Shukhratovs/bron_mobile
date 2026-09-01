class FavoritePlaceEntity {
  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final int reviewsCount;
  final String imagePath;
  final String averageCheck;
  final bool isFavorite;

  const FavoritePlaceEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.imagePath,
    required this.averageCheck,
    this.isFavorite = true,
  });
}
