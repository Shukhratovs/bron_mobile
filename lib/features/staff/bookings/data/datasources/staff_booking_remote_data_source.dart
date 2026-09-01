import 'package:uuid/uuid.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../bookings/data/models/booking_model.dart';

const _uuid = Uuid();

abstract class StaffBookingRemoteDataSource {
  Future<List<BookingModel>> getBookings({String? date, String? status, String? q});
  Future<BookingModel> getBookingById(String id);
  Future<BookingModel> arrive(String id, {int? arrivedGuests, String? idempotencyKey});
  Future<BookingModel> late_(String id, {String? idempotencyKey});
  Future<BookingModel> noShow(String id, {String reason, String? idempotencyKey});
  Future<BookingModel> cancel(String id, {String reason, String? idempotencyKey});
  Future<BookingModel> setTables(String id, List<String> tableIds, {String? idempotencyKey});
  Future<BookingModel> changeTime(String id, DateTime startsAt, {String? idempotencyKey});
  Future<BookingModel> scan(String qrToken);
  Future<BookingModel> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    required String guestName,
    String? guestPhone,
    String source,
    String? staffNote,
    String? idempotencyKey,
  });
}

class StaffBookingRemoteDataSourceImpl implements StaffBookingRemoteDataSource {
  final ApiClient apiClient;

  StaffBookingRemoteDataSourceImpl({required this.apiClient});

  Map<String, String>? _idempotencyHeaders(String? key) =>
      key != null ? {'Idempotency-Key': key} : null;

  @override
  Future<List<BookingModel>> getBookings({String? date, String? status, String? q}) async {
    final params = <String>[];
    if (date != null) params.add('date=$date');
    if (status != null) params.add('status=$status');
    if (q != null && q.isNotEmpty) params.add('q=${Uri.encodeQueryComponent(q)}');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    final response = await apiClient.get('${ApiEndpoints.staffBookings}$query');
    if (response is List) {
      return response.map((e) => BookingModel.fromJson((e as Map).cast<String, dynamic>())).toList();
    }
    return const [];
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    final response = await apiClient.get(ApiEndpoints.staffBookingById(id));
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> arrive(String id, {int? arrivedGuests, String? idempotencyKey}) async {
    final response = await apiClient.post(
      ApiEndpoints.staffBookingArrive(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: {if (arrivedGuests != null) 'arrived_guests': arrivedGuests},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> late_(String id, {String? idempotencyKey}) async {
    final response = await apiClient.post(
      ApiEndpoints.staffBookingLate(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: const {},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> noShow(String id, {String reason = 'kelmadi', String? idempotencyKey}) async {
    final response = await apiClient.post(
      ApiEndpoints.staffBookingNoShow(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: {'reason': reason},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> cancel(String id, {String reason = 'muassasa_sababli', String? idempotencyKey}) async {
    final response = await apiClient.post(
      ApiEndpoints.staffBookingCancel(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: {'reason': reason},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> setTables(String id, List<String> tableIds, {String? idempotencyKey}) async {
    final response = await apiClient.patch(
      ApiEndpoints.staffBookingTables(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: {'table_ids': tableIds},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> changeTime(String id, DateTime startsAt, {String? idempotencyKey}) async {
    final response = await apiClient.patch(
      ApiEndpoints.staffBookingTime(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: {'starts_at': startsAt.toUtc().toIso8601String()},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> scan(String qrToken) async {
    final response = await apiClient.post(ApiEndpoints.staffBookingScan, body: {'qr_token': qrToken});
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    required String guestName,
    String? guestPhone,
    String source = 'xostes',
    String? staffNote,
    String? idempotencyKey,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.staffBookings,
      headers: _idempotencyHeaders(idempotencyKey),
      body: {
        'venue_id': venueId,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'guests': guests,
        'guest_name': guestName,
        if (guestPhone != null) 'guest_phone': guestPhone,
        'source': source,
        if (staffNote != null) 'staff_note': staffNote,
      },
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }
}

String newIdempotencyKey() => _uuid.v4();
