import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/repositories/venue_repository.dart';
import '../datasources/venue_remote_data_source.dart';
import '../models/venue_model.dart';

class VenueRepositoryImpl implements VenueRepository {
  final VenueRemoteDataSource remoteDataSource;

  VenueRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<VenueListPage>> getVenues({
    String? kind,
    String? q,
    String? district,
    String? cuisine,
    String? check,
    double? ratingMin,
    String? sort,
    double? lat,
    double? lon,
    String? date,
    int? guests,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final page = await remoteDataSource.getVenues(
        kind: kind,
        q: q,
        district: district,
        cuisine: cuisine,
        check: check,
        ratingMin: ratingMin,
        sort: sort,
        lat: lat,
        lon: lon,
        date: date,
        guests: guests,
        limit: limit,
        offset: offset,
      );
      return ApiResult.success(page);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<VenueMapPin>>> getVenuesMap({String? kind, int limit = 200}) async {
    try {
      final pins = await remoteDataSource.getVenuesMap(kind: kind, limit: limit);
      return ApiResult.success(pins);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<VenueEntity>> getVenueById(String id, {double? lat, double? lon}) async {
    try {
      final venue = await remoteDataSource.getVenueById(id, lat: lat, lon: lon);
      return ApiResult.success(venue);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<VenueMenu>> getVenueMenu(String id) async {
    try {
      final menu = await remoteDataSource.getVenueMenu(id);
      return ApiResult.success(menu);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AvailabilityDay>>> getAvailabilityDays(
    String venueId, {
    required int guests,
    int days = 5,
    String? from,
  }) async {
    try {
      final result = await remoteDataSource.getAvailabilityDays(
        venueId,
        guests: guests,
        days: days,
        from: from,
      );
      return ApiResult.success(result);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<AvailabilityResult>> getAvailability(
    String venueId, {
    required String date,
    required int guests,
    String? zoneId,
  }) async {
    try {
      final result = await remoteDataSource.getAvailability(
        venueId,
        date: date,
        guests: guests,
        zoneId: zoneId,
      );
      return ApiResult.success(result);
    } on NetworkException catch (e) {
      return ApiResult.failure(e);
    } catch (e) {
      return ApiResult.failure(NetworkException(message: e.toString()));
    }
  }
}
