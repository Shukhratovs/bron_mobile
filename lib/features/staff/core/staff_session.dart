import '../../../core/network/api_client.dart';
import 'staff_api_client.dart';
import 'staff_local_storage.dart';

/// Xostes ilovasining process-wide sessiyasi — `AppSession`ning xostes
/// uchun ekvivalenti. `lib/main_staff.dart`da `runApp`dan oldin
/// initsializatsiya qilinadi.
class StaffSession {
  StaffSession._();

  static late final StaffLocalStorage localStorage;
  static late final ApiClient apiClient;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    localStorage = await StaffLocalStorage.create();
    final base = StandardApiClient(authLocalStorage: localStorage);
    apiClient = StaffApiClient(inner: base, staffLocalStorage: localStorage);
    _initialized = true;
  }
}
