import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.code,
    required super.venueId,
    required super.guestName,
    super.guestPhone,
    required super.startsAt,
    required super.endsAt,
    required super.guests,
    required super.status,
    required super.source,
    super.tables,
    super.zoneId,
    super.guestNote,
    super.arrivedAt,
    super.arrivedGuests,
    super.cancelReason,
    super.depositAmount,
    super.depositStatus,
    super.createdAt,
    super.events,
    super.staffNote,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      venueId: json['venue_id']?.toString() ?? '',
      guestName: json['guest_name']?.toString() ?? '',
      guestPhone: json['guest_phone'] as String?,
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? '') ?? DateTime.now(),
      guests: (json['guests'] as num?)?.toInt() ?? 0,
      status: BookingEntity.parseStatus(json['status'] as String?),
      source: json['source']?.toString() ?? 'ilova',
      tables: (json['tables'] as List?)
              ?.map((t) => BookingTable.fromJson((t as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      zoneId: json['zone_id'] as String?,
      guestNote: json['guest_note'] as String?,
      arrivedAt: DateTime.tryParse(json['arrived_at']?.toString() ?? ''),
      arrivedGuests: (json['arrived_guests'] as num?)?.toInt(),
      cancelReason: json['cancel_reason'] as String?,
      depositAmount: (json['deposit_amount'] as num?)?.toInt(),
      depositStatus: BookingEntity.parseDepositStatus(json['deposit_status'] as String?),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      events: (json['events'] as List?)
              ?.map((e) => BookingEvent.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      staffNote: json['staff_note'] as String?,
    );
  }
}
