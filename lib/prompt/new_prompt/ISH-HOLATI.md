# Ish holati — bajarilgan va qolgan ishlar

Bu fayl shu suhbat davomida (`lib/prompt/new_prompt/**` speci va Figma
`i8FGYLF28h8GYXQgd1Pczf` dizayni asosida) qilingan barcha o'zgarishlarni va
hali qolgan ishlarni qayd etadi. Keyingi sessiyada shu yerdan davom etish
mumkin.

---

## 1. Bajarilgan ishlar

### 1.1. Auth, push, offline infratuzilma (00-boshlash.md, mijoz/00-kirish-va-profil.md)

- **Mijoz Telegram bot orqali kirish** — eski WebView/Login Widget oqimi
  butunlay olib tashlandi, `start → deep_link → poll status/{nonce}` modeliga
  o'tkazildi (xostesdagi bilan bir xil naqsh). Fayllar:
  `lib/features/auth/**` (domain/data/presentation to'liq qayta yozilgan),
  `lib/core/constants/api_endpoints.dart` (`telegramAuthStart`/`telegramAuthStatus`).
- **Push notification (FCM/APNs)** — Firebase loyihasi (`e-bron`) android va
  iOS uchun ulandi (`google-services.json`, `GoogleService-Info.plist`,
  `lib/firebase_options.dart`, Xcode `project.pbxproj`ga qo'lda qo'shildi).
  `lib/core/services/push_notification_service.dart` — universal servis,
  ikkala ilova (`AppSession`/`StaffSession`) o'z nusxasini yaratadi.
  Kirishdan keyin `POST /devices` (yoki `/staff/devices`), chiqishda
  `DELETE /devices?token=...` — `lib/features/profile/presentation/bloc/profile_bloc.dart`,
  `lib/features/staff/profile/presentation/screens/staff_profile_screen.dart`.
- **Idempotency-Key** — xostes tomonida allaqachon to'g'ri ishlagan
  (`staff_booking_remote_data_source.dart`, `staff_waitlist_remote_data_source.dart`),
  o'zgarishsiz qoldi.
- **Locale** — faqat `uz`/`ru` ko'rsatiladi, `en` UI'dan yashirilgan
  (`language_selection_sheet.dart`), backend bilan sinxronlash allaqachon
  himoyalangan edi.
- **Karta/depozit oqimi** (mijoz/03-depozit.md) — tekshirildi, hujjatga
  aynan mos edi, o'zgartirilmadi.

### 1.2. Build tuzatishlari (Android/iOS ikkalasi ham ishlashi uchun)

- Android `minSdk` 24 → 26 (`yandex_mapkit` talabi — build butunlay
  ishlamayotgan edi).
- `flutter_local_notifications` uchun core library desugaring yoqildi.
- **Android xarita ekrani ishlamasligi tuzatildi** — sabab: Yandex MapKit
  API kaliti Android'da hech qachon o'rnatilmagan edi (`MainActivity.kt`
  bo'sh, manifest meta-data plagin tomonidan o'qilmaydi). Yechim:
  `android/app/src/main/kotlin/.../MainApplication.kt` yaratildi
  (`MapKitFactory.setApiKey(...)`), `AndroidManifest.xml`
  `android:name=".MainApplication"`ga o'zgartirildi, `maps.mobile` SDK
  `app/build.gradle.kts`ga ham qo'shildi.
- Bottom-navigatsiya paneli (mijoz va xostes) endi `MediaQuery.padding.bottom`
  ni hisobga oladi — ba'zi Android qurilmalarida tizim navigatsiyasi ortida
  qolib ketish muammosi tuzatildi.
- `profile_state.dart`dagi `cardSubtitle` getter'idagi Dart generic
  reifikatsiya xatosi (`firstWhere`/`orElse` type mismatch) tuzatildi.
- `PushNotificationService`dagi `FirebaseMessaging.instance`ga erta
  murojaat qilish xatosi (`No Firebase App '[DEFAULT]'`) — `late final`
  qilib tuzatildi.

### 1.3. Avvalgi auditda topilgan 3 ta bo'shliq — barchasi bajarildi

1. **Smena yakuni ekrani** — yangi qurilgan (`lib/features/staff/shift/**`),
   endi xostes ilovasining doimiy tabi.
2. **Xostesda stol berish/almashtirish** — Bron detali ekraniga ulandi
   (`staff_table_select_sheet.dart`, `PATCH /staff/bookings/{id}/tables`).
3. **Mijoz navbat tasdiqlash xatolari** — tekshirilganda allaqachon to'g'ri
   ishlab turgani aniqlandi (`stol_boshadi_screen.dart`), o'zgartirilmadi.

### 1.4. Figma bilan pixel-mos qilib qayta qurilgan qismlar

Figma fayli: `https://www.figma.com/design/i8FGYLF28h8GYXQgd1Pczf/✦-Bron--Copy-`,
sahifa "✦ ・Xostes mobil" (node `1:2`). To'liq ekran xaritasi (bo'lim → node ID):

| Bo'lim | Telefon node | Holat |
|---|---|---|
| 1 · KIRISH | `281:626` | ❌ pixel-mos qilinmagan (funksional ishlaydi) |
| 2 · BUGUN | `286:243` | ✅ qayta qurildi |
| 3 · ZAL | `288:372` | ✅ qayta qurildi |
| 4 · SKANER | `751:955` | ❌ pixel-mos qilinmagan (funksional ishlaydi) |
| 5 · NAVBAT | `305:487` | ❌ pixel-mos qilinmagan (funksional ishlaydi) |
| 6 · YAKUN | `352:715` | ✅ yangidan qurildi |
| 7 · PROFIL | `371:768` | ❌ pixel-mos qilinmagan (funksional ishlaydi) |
| 8 · HOLATLAR (bo'sh kun/internet yo'q/yuklanmoqda/offline) | `373:818` | ❌ qurilmagan |

Qayta qurilganlar:
- **Pastki navigatsiya butunlay almashtirildi**: eski 4-tabli
  (Bugun/Zal/Navbat/Profil) `GlassLiquidBottomNavBar` o'rniga yangi
  `StaffBottomNav` (`lib/features/staff/main/presentation/widgets/staff_bottom_nav.dart`)
  — Bugun/Zal/[markazda Skaner FAB]/Navbat/Yakun. **Profil panelda yo'q** —
  har ekran sarlavhasidagi avatar orqali ochiladi
  (`staff_avatar_button.dart`).
- **Bugun** (`bugun_screen.dart`) — 2x2 statistika panjarasi (icon+rang),
  avatar, "HOZIR · vaqt oralig'i" / "KEYINGI" formatlash, yangi kartochka
  uslubi. Eski qidiruv paneli olib tashlandi (Figma'da yo'q — qidiruv
  Skaner→Qo'lda qidirish orqali).
- **Zal** (`staff_zal_screen.dart`, `staff_zal_remote_data_source.dart`) —
  **butunlay qayta yozildi**. Backend'ning haqiqiy OpenAPI sxemasi
  (`https://34-0-250-111.sslip.io/openapi/staff.json`, `ZalOut`/`TableOut`/
  `ZoneOut`/`ZalSummaryOut`) tekshirib chiqilib, real maydonlar ulandi:
  `state` (bosh/bronlangan/band), `current_booking`, `next_booking_at`,
  `zone_id`/`zone_name`. Zona chiplari, rangli stol panjarasi, legenda.
  - Bo'sh stolga bosilsa → `StaffEmptyTableSheet`
    (`lib/features/staff/zal/presentation/widgets/staff_empty_table_sheet.dart`):
    mehmon soni tanlash + "Ko'chadan joylashtirish" (avval **hech qayerda
    ishlatilmagan** `createBooking` API'sini birinchi marta UI'ga ulab,
    `POST /staff/bookings` → `PATCH .../tables` → `POST .../arrive`
    zanjiri bilan), "Telefon broni" (`source: qongiroq`), "Navbatdan
    chaqirish" (Navbat tabiga o'tkazadi).
  - Bronlangan/band stolga bosilsa → to'g'ridan-to'g'ri mavjud
    `StaffBookingDetailScreen`ga o'tadi (Figma'dagi mini-varaq o'rniga —
    kod takrorlanmasin va "Mehmon keldi"/"Kelmadi"/"Stolni almashtirish"
    logikasi ikki joyda saqlanmasin deb ataylab shunday qilindi).
- **Smena yakuni** (`staff_shift_summary_screen.dart`) — Figma bo'yicha
  to'liq qurildi: gradient hero karta (holat, vaqt oralig'i, davomiylik),
  2x2 statistika, TAFSILOT ro'yxati. Backend qaytarmaydigan ko'rsatkichlar
  ("Stol aylanmasi", "Bo'sh o'tgan stol-soat", "O'rtacha kutish") uchun
  **halol "—"** ko'rsatiladi (`0` emas — 00-boshlash.md §2 qoidasi).
  "Kelmaslik ulushi" va "Navbatdan joylashtirildi" — hisoblab
  ko'rsatiladi (haqiqiy ma'lumot). "Smenani yopish" tugmasi — hujjat
  aytganidek **faqat ilova ichida**, hech qanday API'ga ulanmagan (buni
  aniq matn bilan foydalanuvchiga bildiradi, Figma'dagi noto'g'ri
  "hisobot administratorga yuboriladi" matni ishlatilmadi).
- **Yangi ikonka assetlari** Figma'dan yuklab olindi:
  `assets/icons/check-double-line.svg`, `timer-line.svg`,
  `layout-grid-line.svg`, `nav_icons/staff-{bugun,zal,navbat,yakun}-icon.svg`.
- **Venue nomi saqlash** — `StaffLocalStorage` endi `selectedVenueName`ni
  ham saqlaydi (login/muassasa tanlashda), Bugun/Yakun sarlavhalarida
  ko'rsatiladi.

**Tekshirildi**: `flutter analyze` toza (faqat oldindan mavjud lint
info'lar), ikkala ilova (mijoz + xostes) Android debug APK sifatida
muvaffaqiyatli build bo'ladi.

---

## 2. Qolgan ishlar

### 2.1. Figma bilan pixel-mos qilib qayta qurish kerak bo'lgan ekranlar

- **1 · Kirish** (`281:626`) — hozirgi `staff_login_screen.dart`,
  `raqam_topilmadi_screen.dart`, `muassasa_tanlash_screen.dart` funksional
  ishlaydi, lekin Figma'dagi aniq uslubga (rang, joylashuv, "SMS
  tasdiqlash" ekrani chizilmaydi qoidasi) solishtirib chiqilmagan.
- **4 · Skaner** (`751:955`) — `qr_scan_screen.dart`, "Bron topildi",
  "Qo'lda qidirish" (`manual_search_screen.dart`) — ishlaydi, Figma bilan
  solishtirib chiqilmagan.
- **5 · Navbat** (`305:487`) — `staff_navbat_screen.dart` — "Jonli"/
  "Buyurtma" tablari, "Navbatga qo'shish", "Mehmonni chaqirish" — ishlaydi,
  Figma bilan solishtirib chiqilmagan (masalan `Navbat · buyurtma`
  (`1167:1703`) alohida vizual holat bo'lishi mumkin).
- **7 · Profil** (`371:768`) — `staff_profile_screen.dart` — juda minimal
  (faqat ism/rol/tashkilot + chiqish tugmasi). Figma'da to'liqroq maket
  bo'lishi ehtimoli katta (masalan tilni tanlash, statistika, sozlamalar).
- **8 · Holatlar** (`373:818`) — **umuman qurilmagan**: "Bo'sh kun"
  (`373:820`), "Internet yo'q" (`373:910`), "Yuklanmoqda" (`377:884`),
  "Offline rejim" (`834:1396`) — bular hozircha har ekranda o'z-o'zidan
  yozilgan oddiy matn/`CircularProgressIndicator` bilan almashtirilgan,
  Figma'dagi maxsus dizayn qo'llanilmagan.

### 2.2. Planshet (tablet) maketlari

Har bir bo'limning "· PLANSHET" varianti (masalan `281:627`, `287:312`,
`290:432` va h.k.) Figma'da alohida chizilgan (1194×834, ikki panelli
joylashuv — masalan zal va bronlar yonma-yon). Hozir ilova **faqat bitta
ustunli telefon maketini** ishlatadi, planshetda ham shu maket cho'ziladi.
Bu alohida, ancha katta ish — responsive breakpoint qo'shish va ko'p
ekranni qayta joylashtirishni talab qiladi.

### 2.3. Doc tomonidan ataylab qoldirilgan (bajarilmasligi kerak, eslatma uchun)

- SMS tasdiqlash ekrani (Telegram bot bilan almashtirilgan)
- Mehmon yaqinlashdi (geofence) — API yo'q
- Offline rejim (haqiqiy tarmoqsiz navbat/queue) — backend infratuzilmasi
  (Idempotency-Key) tayyor, lekin ilovada connectivity monitoring +
  mahalliy navbat hali yozilmagan
- Mijoz: to'plamlar/tadbirlar, sevimlilar/sharhlar, JOY Plus, geym
  klub/sartaroshxona/salon vertikallar — API yo'q

### 2.4. iOS — faqat Mac/Xcode orqali bajarilishi mumkin

- `pod install` / birinchi `flutter build ios` (Firebase pod'larini
  o'rnatish uchun).
- Xcode → Signing & Capabilities → **Push Notifications** capability'ni
  qo'shish (Windows'dan xavfsiz qila olmadim).
- Firebase Console → Project Settings → Cloud Messaging → Apple app
  configuration'ga **APNs Authentication Key**ni yuklash (Apple Developer
  akkauntidan).

### 2.5. Kichik, tekshirilmagan detallar

- `mijoz/02-bron-qilish.md` va `mijoz/04-katalog.md` — oldingi auditda
  "✅, qayta tekshirilmagan" deb belgilangan, chuqur qayta audit qilinmagan.
- `xostes/03-navbat.md` — shuningdek oldingi Explore hisobotiga
  tayanilgan, bu sessiyada qayta tekshirilmagan.
