import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.venueName,
    required super.venueCategory,
    required super.address,
    required super.dateTime,
    required super.guestCount,
    required super.qrCode,
    required super.status,
    super.imageUrl,
    super.price,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      venueName: json['venue_name'] as String? ?? '',
      venueCategory: json['venue_category'] as String? ?? '',
      address: json['address'] as String? ?? '',
      dateTime: json['date_time'] as String? ?? '',
      guestCount: json['guest_count'] as int? ?? 1,
      qrCode: json['qr_code'] as String? ?? 'BRN-0000',
      status: _parseStatus(json['status'] as String?),
      imageUrl: json['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_name': venueName,
      'venue_category': venueCategory,
      'address': address,
      'date_time': dateTime,
      'guest_count': guestCount,
      'qr_code': qrCode,
      'status': status.name,
      'image_url': imageUrl,
      'price': price,
    };
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.confirmed;
    }
  }
}
