class AvailabilityDay {
  final DateTime date;
  final bool hasFreeSlots;

  const AvailabilityDay({required this.date, required this.hasFreeSlots});

  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    return AvailabilityDay(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      hasFreeSlots: json['has_free_slots'] as bool? ?? false,
    );
  }
}

class AvailabilitySlot {
  final String time;
  final bool available;

  const AvailabilitySlot({required this.time, required this.available});

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      time: json['time']?.toString() ?? '',
      available: json['available'] as bool? ?? false,
    );
  }
}

class AvailabilityZone {
  final String id;
  final String name;
  final int sortOrder;

  const AvailabilityZone({required this.id, required this.name, this.sortOrder = 0});

  factory AvailabilityZone.fromJson(Map<String, dynamic> json) {
    return AvailabilityZone(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class AvailabilityDeposit {
  final bool required;
  final int? amount;
  final int? perPerson;

  const AvailabilityDeposit({required this.required, this.amount, this.perPerson});

  factory AvailabilityDeposit.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AvailabilityDeposit(required: false);
    return AvailabilityDeposit(
      required: json['required'] as bool? ?? false,
      amount: (json['amount'] as num?)?.toInt(),
      perPerson: (json['per_person'] as num?)?.toInt(),
    );
  }
}

class AvailabilitySettings {
  final int slotMinutes;
  final int bookingDurationMinutes;
  final int advanceDays;

  const AvailabilitySettings({
    this.slotMinutes = 30,
    this.bookingDurationMinutes = 120,
    this.advanceDays = 30,
  });

  factory AvailabilitySettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AvailabilitySettings();
    return AvailabilitySettings(
      slotMinutes: (json['slot_minutes'] as num?)?.toInt() ?? 30,
      bookingDurationMinutes: (json['booking_duration_minutes'] as num?)?.toInt() ?? 120,
      advanceDays: (json['advance_days'] as num?)?.toInt() ?? 30,
    );
  }
}

class AvailabilityResult {
  final DateTime date;
  final int guests;
  final bool closed;
  final List<AvailabilitySlot> slots;
  final AvailabilityDeposit deposit;
  final List<AvailabilityZone> zones;
  final int? maxSeats;
  final AvailabilitySettings settings;

  const AvailabilityResult({
    required this.date,
    required this.guests,
    required this.closed,
    this.slots = const [],
    this.deposit = const AvailabilityDeposit(required: false),
    this.zones = const [],
    this.maxSeats,
    this.settings = const AvailabilitySettings(),
  });

  factory AvailabilityResult.fromJson(Map<String, dynamic> json) {
    return AvailabilityResult(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      guests: (json['guests'] as num?)?.toInt() ?? 1,
      closed: json['closed'] as bool? ?? false,
      slots: (json['slots'] as List?)
              ?.map((s) => AvailabilitySlot.fromJson((s as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      deposit: AvailabilityDeposit.fromJson((json['deposit'] as Map?)?.cast<String, dynamic>()),
      zones: (json['zones'] as List?)
              ?.map((z) => AvailabilityZone.fromJson((z as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      maxSeats: (json['max_seats'] as num?)?.toInt(),
      settings: AvailabilitySettings.fromJson((json['settings'] as Map?)?.cast<String, dynamic>()),
    );
  }
}
