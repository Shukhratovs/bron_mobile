import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/waitlist_model.dart';

abstract class WaitlistRemoteDataSource {
  Future<WaitlistModel> join({
    required String venueId,
    required int guests,
    required DateTime desiredFrom,
    required DateTime desiredTo,
  });
  Future<List<WaitlistModel>> getMine();
  Future<WaitlistModel> confirm(String id, {String? tableId});
  Future<void> leave(String id);
}

class WaitlistRemoteDataSourceImpl implements WaitlistRemoteDataSource {
  final ApiClient apiClient;

  WaitlistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WaitlistModel> join({
    required String venueId,
    required int guests,
    required DateTime desiredFrom,
    required DateTime desiredTo,
  }) async {
    final response = await apiClient.post(ApiEndpoints.waitlist, body: {
      'venue_id': venueId,
      'guests': guests,
      'desired_from': desiredFrom.toUtc().toIso8601String(),
      'desired_to': desiredTo.toUtc().toIso8601String(),
    });
    return WaitlistModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<List<WaitlistModel>> getMine() async {
    final response = await apiClient.get(ApiEndpoints.waitlist);
    return WaitlistListResult.fromClientJson(response).items;
  }

  @override
  Future<WaitlistModel> confirm(String id, {String? tableId}) async {
    final response = await apiClient.post(
      ApiEndpoints.waitlistConfirm(id),
      body: tableId != null ? {'table_id': tableId} : <String, dynamic>{},
    );
    return WaitlistModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<void> leave(String id) async {
    await apiClient.delete(ApiEndpoints.waitlistDelete(id));
  }
}
