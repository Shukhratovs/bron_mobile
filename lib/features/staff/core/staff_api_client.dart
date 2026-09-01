import '../../../core/network/api_client.dart';
import 'staff_local_storage.dart';

/// `StandardApiClient`ni o'raydi va har bir so'rovga `X-Venue-Id`
/// sarlavhasini avtomatik qo'shadi — xostes uchun majburiy emas, lekin
/// bir necha filialli xodim uchun to'g'ri kontekstni aniqlaydi
/// (01-kirish.md §3).
class StaffApiClient implements ApiClient {
  final ApiClient _inner;
  final StaffLocalStorage _staffLocalStorage;

  StaffApiClient({required ApiClient inner, required StaffLocalStorage staffLocalStorage})
      : _inner = inner,
        _staffLocalStorage = staffLocalStorage;

  Map<String, String> _withVenueHeader(Map<String, String>? headers) {
    final venueId = _staffLocalStorage.selectedVenueId;
    return {
      if (venueId != null) 'X-Venue-Id': venueId,
      ...?headers,
    };
  }

  @override
  Future<dynamic> get(String url, {Map<String, String>? headers}) =>
      _inner.get(url, headers: _withVenueHeader(headers));

  @override
  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body}) =>
      _inner.post(url, headers: _withVenueHeader(headers), body: body);

  @override
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body}) =>
      _inner.put(url, headers: _withVenueHeader(headers), body: body);

  @override
  Future<dynamic> patch(String url, {Map<String, String>? headers, dynamic body}) =>
      _inner.patch(url, headers: _withVenueHeader(headers), body: body);

  @override
  Future<dynamic> delete(String url, {Map<String, String>? headers}) =>
      _inner.delete(url, headers: _withVenueHeader(headers));
}
