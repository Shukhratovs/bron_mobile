import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../models/booking_qr_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BookingModel>> getBookings({required String tab});
  Future<BookingModel> getBookingById(String id);
  Future<BookingModel> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    String? zoneId,
    String? guestNote,
    String? cardId,
  });
  Future<void> cancelBooking(String id, {String reason});
  Future<BookingModel> changeBookingTime(String id, DateTime startsAt);
  Future<BookingQrModel> getBookingQr(String id);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient apiClient;

  BookingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BookingModel>> getBookings({required String tab}) async {
    final response = await apiClient.get('${ApiEndpoints.bookings}?tab=$tab');
    if (response is List) {
      return response
          .map((item) => BookingModel.fromJson((item as Map).cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    final response = await apiClient.get(ApiEndpoints.bookingById(id));
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingModel> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    String? zoneId,
    String? guestNote,
    String? cardId,
  }) async {
    final body = {
      'venue_id': venueId,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'guests': guests,
      if (zoneId != null) 'zone_id': zoneId,
      if (guestNote != null && guestNote.isNotEmpty) 'guest_note': guestNote,
      if (cardId != null) 'card_id': cardId,
    };
    final response = await apiClient.post(ApiEndpoints.bookings, body: body);
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<void> cancelBooking(String id, {String reason = 'mehmon_soradi'}) async {
    await apiClient.post(ApiEndpoints.bookingCancel(id), body: {'reason': reason});
  }

  @override
  Future<BookingModel> changeBookingTime(String id, DateTime startsAt) async {
    final response = await apiClient.patch(
      ApiEndpoints.bookingTime(id),
      body: {'starts_at': startsAt.toUtc().toIso8601String()},
    );
    return BookingModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<BookingQrModel> getBookingQr(String id) async {
    final response = await apiClient.get(ApiEndpoints.bookingQr(id));
    return BookingQrModel.fromJson((response as Map).cast<String, dynamic>());
  }
}
