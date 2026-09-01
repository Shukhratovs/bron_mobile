import '../../../../../core/network/api_result.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';

abstract class StaffBookingRepository {
  Future<ApiResult<List<BookingEntity>>> getBookings({String? date, String? status, String? q});
  Future<ApiResult<BookingEntity>> getBookingById(String id);
  Future<ApiResult<BookingEntity>> arrive(String id, {int? arrivedGuests, String? idempotencyKey});
  Future<ApiResult<BookingEntity>> late(String id, {String? idempotencyKey});
  Future<ApiResult<BookingEntity>> noShow(String id, {String reason, String? idempotencyKey});
  Future<ApiResult<BookingEntity>> cancel(String id, {String reason, String? idempotencyKey});
  Future<ApiResult<BookingEntity>> setTables(String id, List<String> tableIds, {String? idempotencyKey});
  Future<ApiResult<BookingEntity>> changeTime(String id, DateTime startsAt, {String? idempotencyKey});
  Future<ApiResult<BookingEntity>> scan(String qrToken);
  Future<ApiResult<BookingEntity>> createBooking({
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
