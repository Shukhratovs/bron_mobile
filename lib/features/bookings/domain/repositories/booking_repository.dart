import '../../../../core/network/api_result.dart';
import '../../data/models/booking_qr_model.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<ApiResult<List<BookingEntity>>> getBookings({required String tab});
  Future<ApiResult<BookingEntity>> getBookingById(String id);
  Future<ApiResult<BookingEntity>> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    String? zoneId,
    String? guestNote,
    String? cardId,
  });
  Future<ApiResult<bool>> cancelBooking(String id, {String reason});
  Future<ApiResult<BookingEntity>> changeBookingTime(String id, DateTime startsAt);
  Future<ApiResult<BookingQrModel>> getBookingQr(String id);
}
