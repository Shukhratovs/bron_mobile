import 'package:uuid/uuid.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../waitlist/data/models/waitlist_model.dart';

const _uuid = Uuid();
String newIdempotencyKey() => _uuid.v4();

abstract class StaffWaitlistRemoteDataSource {
  Future<WaitlistListResult> getWaitlist({required String kind});
  Future<WaitlistModel> add({
    required String guestName,
    required int guests,
    String? guestPhone,
    String? zoneId,
    String? idempotencyKey,
  });
  Future<WaitlistModel> call(String id, {String? tableId, String? idempotencyKey});
  Future<WaitlistModel> seat(String id, String tableId, {String? idempotencyKey});
  Future<void> remove(String id, {String? idempotencyKey});
}

class StaffWaitlistRemoteDataSourceImpl implements StaffWaitlistRemoteDataSource {
  final ApiClient apiClient;

  StaffWaitlistRemoteDataSourceImpl({required this.apiClient});

  Map<String, String>? _idempotencyHeaders(String? key) =>
      key != null ? {'Idempotency-Key': key} : null;

  @override
  Future<WaitlistListResult> getWaitlist({required String kind}) async {
    final response = await apiClient.get('${ApiEndpoints.staffWaitlist}?kind=$kind');
    return WaitlistListResult.fromStaffJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<WaitlistModel> add({
    required String guestName,
    required int guests,
    String? guestPhone,
    String? zoneId,
    String? idempotencyKey,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.staffWaitlist,
      headers: _idempotencyHeaders(idempotencyKey),
      body: {
        'guest_name': guestName,
        'guests': guests,
        if (guestPhone != null) 'guest_phone': guestPhone,
        'zone_id': zoneId,
      },
    );
    return WaitlistModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<WaitlistModel> call(String id, {String? tableId, String? idempotencyKey}) async {
    final response = await apiClient.post(
      ApiEndpoints.staffWaitlistCall(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: tableId != null ? {'table_id': tableId} : <String, dynamic>{},
    );
    return WaitlistModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<WaitlistModel> seat(String id, String tableId, {String? idempotencyKey}) async {
    final response = await apiClient.post(
      ApiEndpoints.staffWaitlistSeat(id),
      headers: _idempotencyHeaders(idempotencyKey),
      body: {'table_id': tableId},
    );
    return WaitlistModel.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<void> remove(String id, {String? idempotencyKey}) async {
    await apiClient.delete(ApiEndpoints.staffWaitlistDelete(id), headers: _idempotencyHeaders(idempotencyKey));
  }
}
