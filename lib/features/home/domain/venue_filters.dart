import '../../venue/domain/entities/venue_entity.dart';

class VenueFilters {
  final String? kind;
  final String? district;
  final DateTime? date;
  final String? time;
  final int? guests;
  final String? duration;
  final String? cuisine;
  final String? check;
  final double? ratingMin;
  final String? sort;
  final bool noDeposit;
  final bool hasAvailableTable;
  final bool largeCompany;

  const VenueFilters({
    this.kind,
    this.district,
    this.date,
    this.time,
    this.guests,
    this.duration,
    this.cuisine,
    this.check,
    this.ratingMin,
    this.sort,
    this.noDeposit = false,
    this.hasAvailableTable = false,
    this.largeCompany = false,
  });

  bool get isEmpty =>
      kind == null &&
      district == null &&
      date == null &&
      time == null &&
      guests == null &&
      duration == null &&
      cuisine == null &&
      check == null &&
      ratingMin == null &&
      sort == null &&
      !noDeposit &&
      !hasAvailableTable &&
      !largeCompany;

  VenueFilters copyWith({
    String? kind,
    bool clearKind = false,
    String? district,
    DateTime? date,
    bool clearDate = false,
    String? time,
    bool clearTime = false,
    int? guests,
    bool clearGuests = false,
    String? duration,
    bool clearDuration = false,
    String? cuisine,
    bool clearCuisine = false,
    String? check,
    bool clearCheck = false,
    double? ratingMin,
    bool clearRating = false,
    String? sort,
    bool clearSort = false,
    bool? noDeposit,
    bool? hasAvailableTable,
    bool? largeCompany,
  }) {
    return VenueFilters(
      kind: clearKind ? null : (kind ?? this.kind),
      district: district ?? this.district,
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
      guests: clearGuests ? null : (guests ?? this.guests),
      duration: clearDuration ? null : (duration ?? this.duration),
      cuisine: clearCuisine ? null : (cuisine ?? this.cuisine),
      check: clearCheck ? null : (check ?? this.check),
      ratingMin: clearRating ? null : (ratingMin ?? this.ratingMin),
      sort: clearSort ? null : (sort ?? this.sort),
      noDeposit: noDeposit ?? this.noDeposit,
      hasAvailableTable: hasAvailableTable ?? this.hasAvailableTable,
      largeCompany: largeCompany ?? this.largeCompany,
    );
  }

  /// `GET /venues` haqiqatda qabul qiladigan `date` formati (`YYYY-MM-DD`).
  String? get dateParam {
    final d = date;
    if (d == null) return null;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// `largeCompany` ("Katta kompaniya · 8+") belgilansa, mavjud `guests`
  /// filtri orqali amalga oshiriladi. `maxSeats` faqat bitta muassasa
  /// tafsilotida (`GET /venues/{id}`) keladi, ro'yxatda (`GET /venues`)
  /// har doim `null` — shuning uchun mijoz tomonida filtrlab bo'lmaydi,
  /// aksincha serverdan bevosita "kamida 8 kishilik joy" so'raladi.
  int? get effectiveGuests {
    if (!largeCompany) return guests;
    if (guests != null && guests! > 8) return guests;
    return 8;
  }

  /// Backend qo'llab-quvvatlamaydigan uchta filtr (`time`, `noDeposit`,
  /// `hasAvailableTable`) — allaqachon yuklangan ro'yxat ustida mijoz
  /// tomonida qo'llaniladi. `venue.freeSlots`/`depositRequired` faqat
  /// ro'yxat javobida ham keladi, shuning uchun bu ishonchli ishlaydi.
  bool matchesClientSide(VenueEntity venue) {
    if (time != null && !venue.freeSlots.contains(time)) return false;
    if (noDeposit && venue.depositRequired == true) return false;
    if (hasAvailableTable && venue.freeSlots.isEmpty) return false;
    return true;
  }

  bool get hasClientOnlyFilters => time != null || noDeposit || hasAvailableTable;
}
