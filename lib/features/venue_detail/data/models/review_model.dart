/// `ReviewOut` — `GET /venues/{id}/reviews`, `POST/PATCH /bookings/{id}/review`.
class ReviewModel {
  final String id;
  final String venueId;
  final String bookingId;
  final int rating;
  final String? text;
  final String? replyText;
  final DateTime? repliedAt;
  final DateTime createdAt;
  final String? guestName;
  final DateTime? visitDate;
  final List<String> tables;
  final int? guests;

  const ReviewModel({
    required this.id,
    required this.venueId,
    required this.bookingId,
    required this.rating,
    this.text,
    this.replyText,
    this.repliedAt,
    required this.createdAt,
    this.guestName,
    this.visitDate,
    this.tables = const [],
    this.guests,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      venueId: json['venue_id'] as String,
      bookingId: json['booking_id'] as String,
      rating: (json['rating'] as num).toInt(),
      text: json['text'] as String?,
      replyText: json['reply_text'] as String?,
      repliedAt: json['replied_at'] != null ? DateTime.tryParse(json['replied_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      guestName: json['guest_name'] as String?,
      visitDate: json['visit_date'] != null ? DateTime.tryParse(json['visit_date'] as String) : null,
      tables: (json['tables'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      guests: (json['guests'] as num?)?.toInt(),
    );
  }

  String get authorName => (guestName == null || guestName!.trim().isEmpty) ? 'Mehmon' : guestName!;
}
