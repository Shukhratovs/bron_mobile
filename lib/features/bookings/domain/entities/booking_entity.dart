enum BookingStatus {
  kutilmoqda,
  kechikmoqda,
  keldi,
  kelmadi,
  bekor,
  yakunlandi,
  unknown,
}

enum DepositStatus {
  talabQilinmaydi,
  bloklangan,
  hisobgaOtdi,
  qaytarildi,
  ushlabQolindi,
  unknown,
}

class BookingTable {
  final String id;
  final String number;
  final int seats;
  final String? description;

  const BookingTable({
    required this.id,
    required this.number,
    required this.seats,
    this.description,
  });

  factory BookingTable.fromJson(Map<String, dynamic> json) {
    return BookingTable(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
    );
  }
}

class BookingEvent {
  final String type;
  final Map<String, dynamic> payload;
  final String actorType;
  final DateTime? createdAt;

  const BookingEvent({
    required this.type,
    required this.payload,
    required this.actorType,
    this.createdAt,
  });

  factory BookingEvent.fromJson(Map<String, dynamic> json) {
    return BookingEvent(
      type: json['type']?.toString() ?? '',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      actorType: json['actor_type']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class BookingEntity {
  final String id;
  final String code;
  final String venueId;
  final String guestName;
  final String? guestPhone;
  final DateTime startsAt;
  final DateTime endsAt;
  final int guests;
  final BookingStatus status;
  final String source;
  final List<BookingTable> tables;
  final String? zoneId;
  final String? guestNote;
  final DateTime? arrivedAt;
  final int? arrivedGuests;
  final String? cancelReason;
  final int? depositAmount;
  final DepositStatus depositStatus;
  final DateTime? createdAt;
  final List<BookingEvent> events;
  final String? staffNote;

  const BookingEntity({
    required this.id,
    required this.code,
    required this.venueId,
    required this.guestName,
    this.guestPhone,
    required this.startsAt,
    required this.endsAt,
    required this.guests,
    required this.status,
    required this.source,
    this.tables = const [],
    this.zoneId,
    this.guestNote,
    this.arrivedAt,
    this.arrivedGuests,
    this.cancelReason,
    this.depositAmount,
    this.depositStatus = DepositStatus.talabQilinmaydi,
    this.createdAt,
    this.events = const [],
    this.staffNote,
  });

  String get tableLabel {
    if (tables.isEmpty) return '';
    final table = tables.first;
    final numbers = tables.map((t) => t.number).join('–');
    final desc = table.description;
    return desc == null || desc.isEmpty ? 'Stol $numbers' : 'Stol $numbers · $desc';
  }

  static BookingStatus parseStatus(String? value) {
    switch (value) {
      case 'kutilmoqda':
        return BookingStatus.kutilmoqda;
      case 'kechikmoqda':
        return BookingStatus.kechikmoqda;
      case 'keldi':
        return BookingStatus.keldi;
      case 'kelmadi':
        return BookingStatus.kelmadi;
      case 'bekor':
        return BookingStatus.bekor;
      case 'yakunlandi':
        return BookingStatus.yakunlandi;
      default:
        return BookingStatus.unknown;
    }
  }

  static DepositStatus parseDepositStatus(String? value) {
    switch (value) {
      case 'talab_qilinmaydi':
        return DepositStatus.talabQilinmaydi;
      case 'bloklangan':
        return DepositStatus.bloklangan;
      case 'hisobga_otdi':
        return DepositStatus.hisobgaOtdi;
      case 'qaytarildi':
        return DepositStatus.qaytarildi;
      case 'ushlab_qolindi':
        return DepositStatus.ushlabQolindi;
      default:
        return DepositStatus.unknown;
    }
  }
}
