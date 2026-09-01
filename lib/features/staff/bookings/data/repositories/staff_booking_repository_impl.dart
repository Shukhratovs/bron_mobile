import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../../../bookings/domain/entities/booking_entity.dart';
import '../../domain/repositories/staff_booking_repository.dart';
import '../datasources/staff_booking_remote_data_source.dart';

class StaffBookingRepositoryImpl implements StaffBookingRepository {
  final StaffBookingRemoteDataSource remoteDataSource;

  StaffBookingRepositoryImpl({required this.remoteDataSource});

  Future<ApiResult<BookingEntity>> _wrap(Future<BookingEntity> Function() call) async {
    try {
      return ApiResult.success(await call());
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<BookingEntity>>> getBookings({String? date, String? status, String? q}) async {
    try {
      return ApiResult.success(await remoteDataSource.getBookings(date: date, status: status, q: q));
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<BookingEntity>> getBookingById(String id) => _wrap(() => remoteDataSource.getBookingById(id));

  @override
  Future<ApiResult<BookingEntity>> arrive(String id, {int? arrivedGuests, String? idempotencyKey}) =>
      _wrap(() => remoteDataSource.arrive(id, arrivedGuests: arrivedGuests, idempotencyKey: idempotencyKey));

  @override
  Future<ApiResult<BookingEntity>> late(String id, {String? idempotencyKey}) =>
      _wrap(() => remoteDataSource.late_(id, idempotencyKey: idempotencyKey));

  @override
  Future<ApiResult<BookingEntity>> noShow(String id, {String reason = 'kelmadi', String? idempotencyKey}) =>
      _wrap(() => remoteDataSource.noShow(id, reason: reason, idempotencyKey: idempotencyKey));

  @override
  Future<ApiResult<BookingEntity>> cancel(String id, {String reason = 'muassasa_sababli', String? idempotencyKey}) =>
      _wrap(() => remoteDataSource.cancel(id, reason: reason, idempotencyKey: idempotencyKey));

  @override
  Future<ApiResult<BookingEntity>> setTables(String id, List<String> tableIds, {String? idempotencyKey}) =>
      _wrap(() => remoteDataSource.setTables(id, tableIds, idempotencyKey: idempotencyKey));

  @override
  Future<ApiResult<BookingEntity>> changeTime(String id, DateTime startsAt, {String? idempotencyKey}) =>
      _wrap(() => remoteDataSource.changeTime(id, startsAt, idempotencyKey: idempotencyKey));

  @override
  Future<ApiResult<BookingEntity>> scan(String qrToken) => _wrap(() => remoteDataSource.scan(qrToken));

  @override
  Future<ApiResult<BookingEntity>> createBooking({
    required String venueId,
    required DateTime startsAt,
    required int guests,
    required String guestName,
    String? guestPhone,
    String source = 'xostes',
    String? staffNote,
    String? idempotencyKey,
  }) =>
      _wrap(() => remoteDataSource.createBooking(
            venueId: venueId,
            startsAt: startsAt,
            guests: guests,
            guestName: guestName,
            guestPhone: guestPhone,
            source: source,
            staffNote: staffNote,
            idempotencyKey: idempotencyKey,
          ));
}
