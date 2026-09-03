import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

/// Top-level background handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message received — local notification will be shown by OS.
  // If you need custom processing, do it here.
}

/// Qurilmani push uchun ro'yxatdan o'tkazadi (00-boshlash.md §2).
/// Mijoz va xostes ilovalari o'z `ApiClient` va `/devices` yo'lini
/// berib alohida nusxa yaratadi — ikkalasi ham FCM/APNs tokenini
/// kirishdan keyin yuboradi, chiqishda o'chiradi.
class PushNotificationService {
  final ApiClient apiClient;
  final String devicesEndpoint;
  final bool Function() isLoggedIn;

  PushNotificationService({
    required this.apiClient,
    required this.devicesEndpoint,
    required this.isLoggedIn,
  });

  // `late` — bu maydonlar birinchi ishlatilganda baholanadi, konstruktorda
  // emas. `PushNotificationService` `AppSession.init()`/`StaffSession.init()`
  // ichida, ya'ni `Firebase.initializeApp()`dan OLDIN yaratiladi; agar bu
  // maydonlar oddiy `final` bo'lsa, `FirebaseMessaging.instance`ga o'sha
  // zahoti murojaat qilinib "No Firebase App '[DEFAULT]'" xatosini beradi.
  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'bron_notifications',
    'Bron bildirishnomalar',
    description: 'Bronlar va aksiyalar haqida bildirishnomalar',
    importance: Importance.high,
  );

  /// Called once after Firebase.initializeApp().
  Future<void> init() async {
    // 1. Request permission (iOS + Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // 2. Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 3. Initialize local notifications plugin
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 4. iOS foreground presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // 6. Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 7. Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }

    // 8. Register FCM token with backend (har ishga tushganda — 00-boshlash.md §2 qoida 1)
    await _registerToken();

    // 9. Listen for token refresh
    _messaging.onTokenRefresh.listen((_) => _registerToken());
  }

  /// Get current FCM token and send to backend.
  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      if (!isLoggedIn()) return;

      final platform = Platform.isIOS ? 'ios' : 'android';
      // suppressAuthClear: bu fon so'rovi — agar token muddati aynan shu
      // paytda tugagan bo'lsa ham, foydalanuvchi hali hech narsa qilmagan,
      // shuning uchun butun sessiya jimgina o'chirilmasligi kerak (aks holda
      // ilova ochilishi bilanoq, foydalanuvchi bilmagan holda chiqib
      // ketadi).
      await apiClient.post(
        devicesEndpoint,
        body: {
          'token': token,
          'platform': platform,
        },
        suppressAuthClear: true,
      );
    } catch (_) {
      // Token registration failed — will retry on next refresh
    }
  }

  /// Re-register token after user logs in.
  Future<void> registerTokenAfterLogin() async {
    await _registerToken();
  }

  /// Chiqishda qurilmani o'chirish — token ilova tomonida saqlanadi, server
  /// tomonida emas, shuning uchun `logout` buni o'zi qilmaydi
  /// (00-boshlash.md §2 qoida 3). Token doim mavjud so'rov bilan ishlatiladi,
  /// shuning uchun bu chaqiruv `authLocalStorage` tozalanishidan OLDIN
  /// bo'lishi kerak (DELETE ham Bearer talab qiladi).
  Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await apiClient.delete('$devicesEndpoint?token=$token', suppressAuthClear: true);
    } catch (_) {
      // Yo'q tokenni o'chirish ham 204 qaytaradi — xato bo'lsa ham
      // chiqish oqimini to'xtatmaymiz.
    }
  }

  /// Show local notification when app is in foreground.
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap (from background state).
  void _onMessageOpenedApp(RemoteMessage message) {
    // TODO: navigate to relevant screen based on message.data
    // e.g., if data['type'] == 'booking_confirmed', navigate to booking detail
  }

  /// Handle notification tap (from local notification).
  void _onNotificationTap(NotificationResponse response) {
    // TODO: navigate to relevant screen based on response.payload
  }
}
