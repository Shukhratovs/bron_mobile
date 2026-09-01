import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/availability_entity.dart';
import '../models/venue_model.dart';

class VenueListPage {
  final List<VenueModel> items;
  final int total;

  const VenueListPage({required this.items, required this.total});
}

abstract class VenueRemoteDataSource {
  Future<VenueListPage> getVenues({
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
  Future<List<VenueMapPin>> getVenuesMap({String? kind, int limit = 200});
  Future<VenueModel> getVenueById(String id, {double? lat, double? lon});
  Future<VenueMenu> getVenueMenu(String id);
  Future<List<AvailabilityDay>> getAvailabilityDays(String venueId, {required int guests, int days = 5, String? from});
  Future<AvailabilityResult> getAvailability(String venueId, {required String date, required int guests, String? zoneId});
}

class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  final ApiClient apiClient;

  VenueRemoteDataSourceImpl({required this.apiClient});

  String _query(Map<String, dynamic> params) {
    final parts = <String>[];
    params.forEach((key, value) {
      if (value == null) return;
      parts.add('$key=${Uri.encodeQueryComponent(value.toString())}');
    });
    return parts.isEmpty ? '' : '?${parts.join('&')}';
  }

  @override
  Future<VenueListPage> getVenues({
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
    final query = _query({
      'kind': kind,
      'q': q,
      'district': district,
      'cuisine': cuisine,
      'check': check,
      'rating_min': ratingMin,
      'sort': sort,
      'lat': lat,
      'lon': lon,
      'date': date,
      'guests': guests,
      'limit': limit,
      'offset': offset,
    });
    final response = await apiClient.get('${ApiEndpoints.venues}$query');
    final map = (response as Map).cast<String, dynamic>();
    final items = (map['items'] as List?)
            ?.map((e) => VenueModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList() ??
        const <VenueModel>[];
    return VenueListPage(items: items, total: (map['total'] as num?)?.toInt() ?? items.length);
  }

  @override
  Future<List<VenueMapPin>> getVenuesMap({String? kind, int limit = 200}) async {
    final query = _query({'kind': kind, 'limit': limit});
    final response = await apiClient.get('${ApiEndpoints.venuesMap}$query');
    if (response is List) {
      return response
          .map((e) => VenueMapPin.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  @override
  Future<VenueModel> getVenueById(String id, {double? lat, double? lon}) async {
    final query = _query({'lat': lat, 'lon': lon});
    final response = await apiClient.get('${ApiEndpoints.venueById(id)}$query');
    return VenueModel.fromDetailJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<VenueMenu> getVenueMenu(String id) async {
    final response = await apiClient.get(ApiEndpoints.venueMenu(id));
    return VenueMenu.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<List<AvailabilityDay>> getAvailabilityDays(
    String venueId, {
    required int guests,
    int days = 5,
    String? from,
  }) async {
    final query = _query({'guests': guests, 'days': days, 'from': from});
    final response = await apiClient.get('${ApiEndpoints.venueAvailabilityDays(venueId)}$query');
    final map = (response as Map).cast<String, dynamic>();
    return (map['days'] as List?)
            ?.map((d) => AvailabilityDay.fromJson((d as Map).cast<String, dynamic>()))
            .toList() ??
        const [];
  }

  @override
  Future<AvailabilityResult> getAvailability(
    String venueId, {
    required String date,
    required int guests,
    String? zoneId,
  }) async {
    final query = _query({'date': date, 'guests': guests, 'zone_id': zoneId});
    final response = await apiClient.get('${ApiEndpoints.venueAvailability(venueId)}$query');
    return AvailabilityResult.fromJson((response as Map).cast<String, dynamic>());
  }
}
