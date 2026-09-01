import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_qr_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<BookingEntity>>> getBookings({required String tab}) async {
    try {
      final bookings = await remoteDataSource.getBookings(tab: tab);
      return ApiResult.success(bookings);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<BookingEntity>> getBookingById(String id) async {
    try {
      final booking = await remoteDataSource.getBookingById(id);
      return ApiResult.success(booking);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<BookingEntity>> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    String? zoneId,
    String? guestNote,
    String? cardId,
  }) async {
    try {
      final booking = await remoteDataSource.createBooking(
        venueId: venueId,
        startsAt: startsAt,
        guests: guests,
        zoneId: zoneId,
        guestNote: guestNote,
        cardId: cardId,
      );
      return ApiResult.success(booking);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> cancelBooking(String id, {String reason = 'mehmon_soradi'}) async {
    try {
      await remoteDataSource.cancelBooking(id, reason: reason);
      return ApiResult.success(true);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<BookingEntity>> changeBookingTime(String id, DateTime startsAt) async {
    try {
      final booking = await remoteDataSource.changeBookingTime(id, startsAt);
      return ApiResult.success(booking);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<BookingQrModel>> getBookingQr(String id) async {
    try {
      final qr = await remoteDataSource.getBookingQr(id);
      return ApiResult.success(qr);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}
