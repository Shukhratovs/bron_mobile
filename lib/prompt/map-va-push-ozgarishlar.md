# Xarita (Yandex MapKit) va Push Notification o'zgarishlari — 2026-09-02

---

## 1. Xarita ekrani — Yandex MapKit ga o'tkazildi

### Nima o'zgartirildi

| Fayl | O'zgarish |
|---|---|
| `pubspec.yaml` | `flutter_map` + `latlong2` olib tashlandi, `yandex_mapkit: ^4.3.0` + `geolocator: ^13.0.2` qo'shildi |
| `android/app/build.gradle.kts` | `minSdk = 24` (yandex_mapkit talabi), `com.google.gms.google-services` plugin |
| `android/settings.gradle.kts` | `com.google.gms.google-services` plugin classpath qo'shildi |
| `android/app/src/main/AndroidManifest.xml` | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` ruxsatlari, Yandex API key meta-data placeholder |
| `ios/Podfile` | `platform :ios, '15.0'` (yandex_mapkit talabi) |
| `ios/Runner/Info.plist` | `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` qo'shildi |
| `ios/Runner/AppDelegate.swift` | `YandexMapsMobile` import, `YMKMapKit.setApiKey()` chaqiruvi |
| `lib/features/map/presentation/screens/map_screen.dart` | **To'liq qayta yozildi** |

### Yangi map_screen.dart xususiyatlari

- **YandexMap** widget `MapType.satellite` rejimida (Figma bilan bir xil)
- **User location**: `geolocator` orqali foydalanuvchi joylashuvi olinadi, xarita dastlab shu nuqtaga ko'chadi
- **User location layer**: `toggleUserLayer(visible: true)` — foydalanuvchi nuqtasi xaritada ko'rsatiladi (custom qizil nuqta)
- **"Mening joylashuvim" FAB tugmasi**: bosilganda kamerani foydalanuvchi joylashuviga qaytaradi
- **Custom pin ikonkalar**: `Canvas` orqali programmatik ravishda chiziladi (tashqi asset kerak emas):
  - Normal: oq doira, qizil chegarali, "B" harfi, pastda uchburchak
  - Tanlangan: qizil doira, oq chegarali, kattaroq "B", zIndex yuqoriroq
- **Venue carousel**: pastdagi PageView (avvalgidek), card tanlanishi xaritadagi pinga sync
- **Filtr**: avvalgi filter modal (venue kind bo'yicha) saqlandi
- **Header**: Bron logo, qidiruv, filtr, bildirishnoma — SVG ikonkalar (AppIcon)
- **API ulangan**: `GET /venues/map`, `GET /venues/{id}` (detail lazy load, cache)
- **Smooth animatsiya**: kamera ko'chishi `MapAnimation` bilan

### Sizdan kerak — Yandex MapKit API kaliti

1. https://developer.tech.yandex.ru/ ga kiring
2. Yangi ilova yarating, **MapKit SDK** xizmatini yoqing
3. API kalitni nusxalang
4. **Android**: `android/app/src/main/AndroidManifest.xml` — `YOUR_YANDEX_MAPKIT_API_KEY` ni haqiqiy kalitga almashtiring
5. **iOS**: `ios/Runner/AppDelegate.swift` — `YOUR_YANDEX_MAPKIT_API_KEY` ni haqiqiy kalitga almashtiring

**Ikkala joyda bir xil kalit** ishlatiladi.

---

## 2. Push Notification — Firebase Cloud Messaging (FCM)

### Nima o'zgartirildi

| Fayl | O'zgarish |
|---|---|
| `pubspec.yaml` | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` qo'shildi |
| `lib/core/services/push_notification_service.dart` | **Yangi fayl** — to'liq FCM xizmati |
| `lib/main.dart` | `Firebase.initializeApp()`, background handler, `PushNotificationService.init()` |
| `android/app/build.gradle.kts` | `com.google.gms.google-services` plugin |
| `android/settings.gradle.kts` | Google services classpath |
| `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` ruxsati, FCM default channel |
| `ios/Runner/Info.plist` | `UIBackgroundModes`: `fetch`, `remote-notification` |
| `ios/Runner/AppDelegate.swift` | `FirebaseCore`/`FirebaseMessaging` import, remote notification registratsiyasi |

### PushNotificationService nima qiladi

1. **Ruxsat so'raydi** (iOS + Android 13+)
2. **Android notification channel** yaratadi (`bron_notifications`, high importance)
3. **Local notifications plugin** sozlaydi (foreground ko'rsatish uchun)
4. **iOS foreground presentation** yoqadi (alert + badge + sound)
5. **Foreground messages** — kelganda `flutter_local_notifications` orqali ko'rsatadi
6. **Background messages** — `firebaseMessagingBackgroundHandler` (top-level function)
7. **Notification tap** — background va terminated holatlardan bosilganda handle qiladi
8. **FCM token registratsiyasi** — `POST /api/v1/me/devices` ga `{ token, platform }` yuboradi
9. **Token refresh** — yangilanganda avtomatik qayta ro'yxatdan o'tkazadi
10. **Login keyin** — `registerTokenAfterLogin()` orqali qayta ulash mumkin

### Sizdan kerak — Firebase konfiguratsiya fayllari

1. https://console.firebase.google.com/ ga kiring
2. Loyiha yarating (yoki mavjudini oching)
3. **Android ilova qo'shing** (package name: `bron.mobile.uz.bron_mobile`):
   - `google-services.json` ni yuklab oling
   - `android/app/google-services.json` ga joylang
4. **iOS ilova qo'shing** (bundle ID: Xcode'dan oling):
   - `GoogleService-Info.plist` ni yuklab oling
   - `ios/Runner/GoogleService-Info.plist` ga joylang (Xcode orqali)
5. iOS uchun: Xcode'da **Push Notifications** capability yoqing (Signing & Capabilities)
6. Firebase Console'da **APNs Key** yuklang (iOS push uchun)

**Bu ikki fayl (`google-services.json`, `GoogleService-Info.plist`) yo'q bo'lsa build xato beradi.**

---

## 3. Notification ekrani — real API ga ulandi

| Fayl | O'zgarish |
|---|---|
| `lib/features/profile/domain/entities/notification_item_entity.dart` | API formatiga qayta yozildi (type, channel, payload, sent_at, read_at, created_at) |
| `lib/features/profile/data/models/notification_item_model.dart` | `fromJson` + `NotificationListResponse` (paginated) |
| `lib/features/profile/data/datasources/profile_remote_data_source.dart` | Mock olib tashlandi, real API: `GET /me/notifications`, `POST .../read`, `POST .../read-all` |
| `lib/features/profile/domain/repositories/profile_repository.dart` | `getNotifications()` → `NotificationListResponse`, yangi `markNotificationRead/markAllNotificationsRead` |
| `lib/features/profile/data/repositories/profile_repository_impl.dart` | Yangi metodlar implementatsiyasi |
| `lib/features/profile/presentation/screens/notifications_screen.dart` | Yangi entity bilan ishlaydi, o'qilmagan bildirishnomalar qizil border, tap → mark as read |
| `lib/core/constants/api_endpoints.dart` | `notifications`, `notificationRead(id)`, `notificationsReadAll`, `devices` endpointlari |

---

## 4. flutter analyze natijasi

**0 ta xato, 0 ta warning** — faqat 17 ta oldindan mavjud info-level lint.

---

## 5. Build qilishdan oldin checklist

- [ ] Yandex MapKit API kalitni olish va 2 joyga yozish (AndroidManifest.xml + AppDelegate.swift)
- [ ] `google-services.json` → `android/app/`
- [ ] `GoogleService-Info.plist` → `ios/Runner/`
- [ ] `cd ios && pod install`
- [ ] Xcode'da Push Notifications capability yoqish
- [ ] Firebase Console'da APNs key/sertifikat yuklash
- [ ] `flutter run` bilan sinash
