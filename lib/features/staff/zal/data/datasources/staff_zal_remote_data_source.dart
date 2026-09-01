import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/network/api_client.dart';

class ZalSummary {
  final int freeNow;
  final Map<String, dynamic> raw;

  const ZalSummary({required this.freeNow, this.raw = const {}});

  factory ZalSummary.fromJson(Map<String, dynamic> json) {
    final summary = (json['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ZalSummary(freeNow: (summary['free_now'] as num?)?.toInt() ?? 0, raw: json);
  }
}

abstract class StaffZalRemoteDataSource {
  Future<ZalSummary> getZal();
  Future<List<Map<String, dynamic>>> getAvailability({required String date, required int guests});
}

class StaffZalRemoteDataSourceImpl implements StaffZalRemoteDataSource {
  final ApiClient apiClient;

  StaffZalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ZalSummary> getZal() async {
    final response = await apiClient.get(ApiEndpoints.staffZal);
    return ZalSummary.fromJson((response as Map).cast<String, dynamic>());
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailability({required String date, required int guests}) async {
    final response = await apiClient.get('${ApiEndpoints.staffZalAvailability}?date=$date&guests=$guests');
    if (response is List) {
      return response.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    if (response is Map && response['tables'] is List) {
      return (response['tables'] as List).map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    return const [];
  }
}
