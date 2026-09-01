import '../../domain/entities/waitlist_entity.dart';

class WaitlistModel extends WaitlistEntity {
  const WaitlistModel({
    required super.id,
    required super.kind,
    required super.status,
    super.guestName,
    super.guestPhone,
    required super.guests,
    super.desiredFrom,
    super.desiredTo,
    super.position,
    super.waitingMinutes,
    super.estimatedWaitMinutes,
    super.expiresAt,
    super.offeredTable,
    super.bookingId,
    super.createdAt,
  });

  factory WaitlistModel.fromJson(Map<String, dynamic> json) {
    return WaitlistModel(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'buyurtma',
      status: WaitlistEntity.parseStatus(json['status'] as String?),
      guestName: json['guest_name'] as String?,
      guestPhone: json['guest_phone'] as String?,
      guests: (json['guests'] as num?)?.toInt() ?? 0,
      desiredFrom: DateTime.tryParse(json['desired_from']?.toString() ?? ''),
      desiredTo: DateTime.tryParse(json['desired_to']?.toString() ?? ''),
      position: (json['position'] as num?)?.toInt() ?? 0,
      waitingMinutes: (json['waiting_minutes'] as num?)?.toInt() ?? 0,
      estimatedWaitMinutes: (json['estimated_wait_minutes'] as num?)?.toInt() ?? 0,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      offeredTable: json['offered_table'] as String?,
      bookingId: json['booking_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class WaitlistListResult {
  final List<WaitlistModel> items;
  final int? waiting;
  final int? averageWaitMinutes;

  const WaitlistListResult({required this.items, this.waiting, this.averageWaitMinutes});

  factory WaitlistListResult.fromClientJson(dynamic json) {
    if (json is List) {
      return WaitlistListResult(
        items: json.map((e) => WaitlistModel.fromJson((e as Map).cast<String, dynamic>())).toList(),
      );
    }
    return const WaitlistListResult(items: []);
  }

  factory WaitlistListResult.fromStaffJson(Map<String, dynamic> json) {
    return WaitlistListResult(
      items: (json['items'] as List?)
              ?.map((e) => WaitlistModel.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      waiting: (json['waiting'] as num?)?.toInt(),
      averageWaitMinutes: (json['average_wait_minutes'] as num?)?.toInt(),
    );
  }
}
