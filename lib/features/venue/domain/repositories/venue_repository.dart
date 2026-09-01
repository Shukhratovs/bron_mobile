import '../../../../core/network/api_result.dart';
import '../../data/datasources/venue_remote_data_source.dart';
import '../../data/models/venue_model.dart';
import '../entities/availability_entity.dart';
import '../entities/venue_entity.dart';

abstract class VenueRepository {
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
  });
  Future<ApiResult<List<VenueMapPin>>> getVenuesMap({String? kind, int limit = 200});
  Future<ApiResult<VenueEntity>> getVenueById(String id, {double? lat, double? lon});
  Future<ApiResult<VenueMenu>> getVenueMenu(String id);
  Future<ApiResult<List<AvailabilityDay>>> getAvailabilityDays(String venueId, {required int guests, int days = 5, String? from});
  Future<ApiResult<AvailabilityResult>> getAvailability(String venueId, {required String date, required int guests, String? zoneId});
}
