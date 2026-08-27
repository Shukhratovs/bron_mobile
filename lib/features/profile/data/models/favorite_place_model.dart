import '../../domain/entities/favorite_place_entity.dart';

class FavoritePlaceModel extends FavoritePlaceEntity {
  const FavoritePlaceModel({
    required super.id,
    required super.name,
    required super.category,
    required super.location,
    required super.rating,
    required super.reviewsCount,
    required super.imagePath,
    required super.averageCheck,
    super.isFavorite,
  });

  factory FavoritePlaceModel.fromJson(Map<String, dynamic> json) {
    return FavoritePlaceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      imagePath: json['image_path'] as String? ?? '',
      averageCheck: json['average_check'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'location': location,
      'rating': rating,
      'reviews_count': reviewsCount,
      'image_path': imagePath,
      'average_check': averageCheck,
      'is_favorite': isFavorite,
    };
  }
}
