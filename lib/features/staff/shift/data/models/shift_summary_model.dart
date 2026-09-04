/// `GET /staff/shift/summary` javobi — xostes/04-smena-yakuni.md.
class ShiftSummaryModel {
  final String date;
  final String venueId;
  final String? opensAt;
  final String? closesAt;
  final bool isClosed;
  final Map<String, int> bookings;
  final int guests;
  final Map<String, int> waitlist;
  final int seatedFromWaitlist;
  final String? busiestHour;

  const ShiftSummaryModel({
    required this.date,
    required this.venueId,
    this.opensAt,
    this.closesAt,
    required this.isClosed,
    required this.bookings,
    required this.guests,
    required this.waitlist,
    required this.seatedFromWaitlist,
    this.busiestHour,
  });

  factory ShiftSummaryModel.fromJson(Map<String, dynamic> json) {
    return ShiftSummaryModel(
      date: json['date']?.toString() ?? '',
      venueId: json['venue_id']?.toString() ?? '',
      opensAt: json['opens_at'] as String?,
      closesAt: json['closes_at'] as String?,
      isClosed: json['is_closed'] == true,
      bookings: _asIntMap(json['bookings']),
      guests: (json['guests'] as num?)?.toInt() ?? 0,
      waitlist: _asIntMap(json['waitlist']),
      seatedFromWaitlist: (json['seated_from_waitlist'] as num?)?.toInt() ?? 0,
      busiestHour: json['busiest_hour'] as String?,
    );
  }

  static Map<String, int> _asIntMap(dynamic value) {
    if (value is! Map) return const {};
    return value.map((key, v) => MapEntry(key.toString(), (v as num?)?.toInt() ?? 0));
  }

  int get bookingsTotal => bookings['jami'] ?? 0;
  int get waitlistTotal => waitlist['jami'] ?? 0;
}
