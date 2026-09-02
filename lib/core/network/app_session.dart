import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../services/push_notification_service.dart';
import 'api_client.dart';
import 'auth_local_storage.dart';
import 'favorites_local_storage.dart';

/// Process-wide session: one persistent [AuthLocalStorage] and one shared,
/// authenticated [ApiClient]. Initialized once in `main()` before `runApp`,
/// then used synchronously by every feature instead of each screen creating
/// its own throwaway client (which previously meant requests went out
/// without a bearer token, and a successful login had nowhere real to save
/// its session).
class AppSession {
  AppSession._();

  static late final AuthLocalStorage authLocalStorage;
  static late final ApiClient apiClient;
  static late final FavoritesLocalStorage favorites;
  static late final PushNotificationService pushService;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    authLocalStorage = await AuthLocalStorageImpl.create();
    apiClient = StandardApiClient(authLocalStorage: authLocalStorage);
    favorites = await FavoritesLocalStorage.getInstance();
    pushService = PushNotificationService(
      apiClient: apiClient,
      devicesEndpoint: ApiEndpoints.devices,
      isLoggedIn: () => authLocalStorage.isLoggedIn,
    );
    _initialized = true;
  }

  static const _onboardingSeenKey = 'onboarding_seen';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }
}
