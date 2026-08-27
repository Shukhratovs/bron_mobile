enum BookingStatus {
  confirmed,
  pending,
  completed,
  cancelled,
}

class BookingEntity {
  final String id;
  final String venueName;
  final String venueCategory;
  final String address;
  final String dateTime;
  final int guestCount;
  final String qrCode;
  final BookingStatus status;
  final String? imageUrl;
  final double? price;

  const BookingEntity({
    required this.id,
    required this.venueName,
    required this.venueCategory,
    required this.address,
    required this.dateTime,
    required this.guestCount,
    required this.qrCode,
    required this.status,
    this.imageUrl,
    this.price,
  });
}
