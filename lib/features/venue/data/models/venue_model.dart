import '../../domain/entities/venue_entity.dart';

class VenueModel extends VenueEntity {
  const VenueModel({
    required super.id,
    required super.name,
    required super.kind,
    super.cuisine,
    super.district,
    super.rating,
    super.reviewsCount,
    super.avgCheck,
    super.distanceKm,
    super.photoUrl,
    super.freeSlots,
    super.depositRequired,
    super.address,
    super.description,
    super.phone,
    super.lat,
    super.lon,
    super.hoursText,
    super.photos,
    super.zoneNames,
    super.maxSeats,
    super.popularItems,
    super.cancelWindowHours,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'restoran',
      cuisine: json['cuisine'] as String?,
      district: json['district'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt(),
      avgCheck: (json['avg_check'] as num?)?.toInt(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      freeSlots: (json['free_slots'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      depositRequired: json['deposit_required'] as bool?,
    );
  }

  factory VenueModel.fromDetailJson(Map<String, dynamic> json) {
    final base = VenueModel.fromJson(json);
    final bookingSettings = (json['booking_settings'] as Map?)?.cast<String, dynamic>();
    return VenueModel(
      id: base.id,
      name: base.name,
      kind: base.kind,
      cuisine: base.cuisine,
      district: base.district,
      rating: base.rating,
      reviewsCount: base.reviewsCount,
      avgCheck: base.avgCheck,
      distanceKm: base.distanceKm,
      photoUrl: base.photoUrl,
      freeSlots: base.freeSlots,
      depositRequired: base.depositRequired,
      address: json['address'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      hoursText: json['hours_text'] as String?,
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      zoneNames: (json['zones'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      maxSeats: (json['max_seats'] as num?)?.toInt(),
      popularItems: (json['popular_items'] as List?)
              ?.map((e) => MenuItemEntity.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      cancelWindowHours: (bookingSettings?['cancel_window_hours'] as num?)?.toInt(),
    );
  }
}

class VenueMapPin {
  final String id;
  final String name;
  final String kind;
  final double lat;
  final double lon;
  final double? rating;

  const VenueMapPin({
    required this.id,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lon,
    this.rating,
  });

  factory VenueMapPin.fromJson(Map<String, dynamic> json) {
    return VenueMapPin(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'restoran',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}

class MenuCategory {
  final String id;
  final String name;
  final int sortOrder;
  final int itemsCount;

  const MenuCategory({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.itemsCount = 0,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class VenueMenu {
  final List<MenuCategory> categories;
  final List<MenuItemEntity> items;

  const VenueMenu({this.categories = const [], this.items = const []});

  factory VenueMenu.fromJson(Map<String, dynamic> json) {
    return VenueMenu(
      categories: (json['categories'] as List?)
              ?.map((c) => MenuCategory.fromJson((c as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      items: (json['items'] as List?)
              ?.map((i) => MenuItemEntity.fromJson((i as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
    );
  }
}
