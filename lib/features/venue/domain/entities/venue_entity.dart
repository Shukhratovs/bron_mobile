class MenuItemEntity {
  final String id;
  final String name;
  final String? description;
  final int price;
  final int? prepMinutes;
  final bool isPopular;
  final String? categoryId;

  const MenuItemEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.prepMinutes,
    this.isPopular = false,
    this.categoryId,
  });

  factory MenuItemEntity.fromJson(Map<String, dynamic> json) {
    return MenuItemEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toInt() ?? 0,
      prepMinutes: (json['prep_minutes'] as num?)?.toInt(),
      isPopular: json['is_popular'] as bool? ?? false,
      categoryId: json['category_id'] as String?,
    );
  }
}

class VenueEntity {
  final String id;
  final String name;
  final String kind;
  final String? cuisine;
  final String? district;
  final double? rating;
  final int? reviewsCount;
  final int? avgCheck;
  final double? distanceKm;
  final String? photoUrl;
  final List<String> freeSlots;
  final bool? depositRequired;

  // Faqat `GET /venues/{id}` javobida keladi — ro'yxat elementida `null`.
  final String? address;
  final String? description;
  final String? phone;
  final double? lat;
  final double? lon;
  final String? hoursText;
  final List<String> photos;
  final List<String> zoneNames;
  final int? maxSeats;
  final List<MenuItemEntity> popularItems;
  final int? cancelWindowHours;

  const VenueEntity({
    required this.id,
    required this.name,
    required this.kind,
    this.cuisine,
    this.district,
    this.rating,
    this.reviewsCount,
    this.avgCheck,
    this.distanceKm,
    this.photoUrl,
    this.freeSlots = const [],
    this.depositRequired,
    this.address,
    this.description,
    this.phone,
    this.lat,
    this.lon,
    this.hoursText,
    this.photos = const [],
    this.zoneNames = const [],
    this.maxSeats,
    this.popularItems = const [],
    this.cancelWindowHours,
  });
}
