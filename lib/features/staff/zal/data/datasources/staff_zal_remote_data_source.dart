import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_client.dart';

/// `GET /staff/zal` — zonalar, stollar, xulosa (bitta so'rovda).
/// Backend sxemasi (`ZalOut`/`TableOut`/`ZoneOut`/`ZalSummaryOut`,
/// `/openapi/staff.json`) asosida — Figma `Zal · telefon` (288:373).
enum TableState { bosh, bronlangan, band }

TableState _parseTableState(String? raw) {
  switch (raw) {
    case 'bronlangan':
      return TableState.bronlangan;
    case 'band':
      return TableState.band;
    default:
      return TableState.bosh;
  }
}

class TableBookingRef {
  final String id;
  final String guestName;
  final DateTime startsAt;

  const TableBookingRef({required this.id, required this.guestName, required this.startsAt});

  factory TableBookingRef.fromJson(Map<String, dynamic> json) {
    return TableBookingRef(
      id: json['id']?.toString() ?? '',
      guestName: json['guest_name']?.toString() ?? '',
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ZalTable {
  final String id;
  final String number;
  final int seats;
  final String? zoneId;
  final String? zoneName;
  final String? description;
  final bool bookableInApp;
  final TableState state;
  final TableBookingRef? currentBooking;
  final DateTime? nextBookingAt;

  const ZalTable({
    required this.id,
    required this.number,
    required this.seats,
    this.zoneId,
    this.zoneName,
    this.description,
    required this.bookableInApp,
    required this.state,
    this.currentBooking,
    this.nextBookingAt,
  });

  factory ZalTable.fromJson(Map<String, dynamic> json) {
    return ZalTable(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      zoneId: json['zone_id'] as String?,
      zoneName: json['zone_name'] as String?,
      description: json['description'] as String?,
      bookableInApp: json['bookable_in_app'] == true,
      state: _parseTableState(json['state'] as String?),
      currentBooking: json['current_booking'] is Map ? TableBookingRef.fromJson((json['current_booking'] as Map).cast<String, dynamic>()) : null,
      nextBookingAt: json['next_booking_at'] != null ? DateTime.tryParse(json['next_booking_at'].toString()) : null,
    );
  }
}

class ZalZone {
  final String id;
  final String name;
  final int sortOrder;
  final int tablesCount;
  final int seatsTotal;

  const ZalZone({required this.id, required this.name, required this.sortOrder, this.tablesCount = 0, this.seatsTotal = 0});

  factory ZalZone.fromJson(Map<String, dynamic> json) {
    return ZalZone(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      tablesCount: (json['tables_count'] as num?)?.toInt() ?? 0,
      seatsTotal: (json['seats_total'] as num?)?.toInt() ?? 0,
    );
  }
}

class ZalSummary {
  final int tables;
  final int seats;
  final int freeNow;
  final double occupancyToday;

  const ZalSummary({required this.tables, required this.seats, required this.freeNow, required this.occupancyToday});

  factory ZalSummary.fromJson(Map<String, dynamic> json) {
    return ZalSummary(
      tables: (json['tables'] as num?)?.toInt() ?? 0,
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      freeNow: (json['free_now'] as num?)?.toInt() ?? 0,
      occupancyToday: (json['occupancy_today'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ZalState {
  final List<ZalZone> zones;
  final List<ZalTable> tables;
  final ZalSummary summary;

  const ZalState({required this.zones, required this.tables, required this.summary});

  factory ZalState.fromJson(Map<String, dynamic> json) {
    return ZalState(
      zones: (json['zones'] as List? ?? []).map((e) => ZalZone.fromJson((e as Map).cast<String, dynamic>())).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      tables: (json['tables'] as List? ?? []).map((e) => ZalTable.fromJson((e as Map).cast<String, dynamic>())).toList(),
      summary: ZalSummary.fromJson((json['summary'] as Map).cast<String, dynamic>()),
    );
  }
}

abstract class StaffZalRemoteDataSource {
  Future<ZalState> getZal({String? zoneId});
  Future<List<ZalTable>> getAvailability({required String date, required int guests});
}

class StaffZalRemoteDataSourceImpl implements StaffZalRemoteDataSource {
  final ApiClient apiClient;

  StaffZalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ZalState> getZal({String? zoneId}) async {
    final url = zoneId == null ? ApiEndpoints.staffZal : '${ApiEndpoints.staffZal}?zone_id=$zoneId';
    final response = await apiClient.get(url);
    return ZalState.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<List<ZalTable>> getAvailability({required String date, required int guests}) async {
    final response = await apiClient.get('${ApiEndpoints.staffZalAvailability}?date=$date&guests=$guests');
    if (response is List) {
      return response.map((e) => ZalTable.fromJson((e as Map).cast<String, dynamic>())).toList();
    }
    if (response is Map && response['tables'] is List) {
      return (response['tables'] as List).map((e) => ZalTable.fromJson((e as Map).cast<String, dynamic>())).toList();
    }
    return const [];
  }
}
