# Bajarilgan ishlar va keyingi qadamlar

Bu hujjat 2026-08-31 kunidagi katta hajmdagi ishning yakuniy holatini
qayd etadi: nima tuzatildi, nima noldan qurildi, va nima hali ochiq
qoldi. `00-boshlash.md`ni to'ldiradi, uni almashtirmaydi.

---

## 1. Tuzatilgan buglar va navigatsiya teshiklari (Mijoz)

- `home_screen.dart`dagi 9 ta o'lik tugma ulandi: qidiruv paneli →
  `SearchScreen`, filtr ikonkasi → `FiltrlarScreen`, bildirishnoma →
  `NotificationsScreen`, "hammasini ko'rish" bloklari → tegishli ekran.
- **Haqiqiy sessiya bugi**: `profile_screen.dart` login qilingandan
  keyin tokenni `DummyAuthLocalStorage`ga (hech narsa saqlamaydigan
  soxta klassga) yozar edi — foydalanuvchi hech qachon haqiqatan
  tizimga kirmagan bo'lib chiqardi. Endi `AppSession` orqali haqiqiy
  `shared_preferences`ga saqlanadi.
- `splash_screen.dart` endi token va `onboarding_seen` flagini
  tekshiradi: kirgan foydalanuvchiga onboarding qayta ko'rsatilmaydi;
  aks holda faqat birinchi marta ko'rsatiladi (avval har safar
  ko'rsatilardi).
- **Auth guard** qo'shildi (`core/utils/auth_guard.dart`): bron
  qilish, navbatga yozilish, karta qo'shish tugmalari bosilganda token
  yo'q bo'lsa avval `LoginScreen` ochiladi — avval umuman tekshirilmas
  edi, natijada `POST /bookings` va h.k. jimgina 401 bilan tugardi.
- `api_client.dart` va `network_exceptions.dart`ga `code` va `body`
  maydonlari qo'shildi — endi `no_table_available`, `card_required`,
  `invalid_transition`, `venue_not_found` kabi xato kodlari UI'da
  to'g'ri aniqlanadi (avval faqat matn xabari bor edi, kod yo'q edi).
- `AppStrings._translations`da 10 ta kalit yo'q edi (`city_tashkent`,
  `search_placeholder`, `view_all`, `today`, `tomorrow`,
  `persons_count`, `near_me`, `popular_places`, `recommended`,
  `no_data`) — ekranda xom kalit ko'rinardi. Uch tilda (uz/ru/en)
  to'ldirildi.

## 2. O'chirilgan o'lik/takroriy kod

- `lib/features/favorites/` (butun papka — hech qayerdan
  ishlatilmaydigan ikkinchi `FavoritesScreen`).
- `lib/features/profile/presentation/screens/my_bookings_screen.dart`
  (hech qayerga ulanmagan).
- `lib/features/bookings/presentation/screens/live_queue_scanner_screen.dart`
  va `widgets/table_ready_bottom_sheet.dart` — soxta QR-navbat oqimi
  (haqiqiy `Stol bo'shadi`/Navbat ekranlariga almashtirildi).
- `lib/features/venue_detail/presentation/widgets/booking_bottom_sheet.dart`
  va `queue_bottom_sheet.dart` — mock bron/navbat bottom sheetlari
  (`VaqtTanlashScreen`, `NavbatgaYozilishScreen`ga almashtirildi).
- `lib/features/booking/presentation/screens/deposit_confirmation_screen.dart`
  va `sms_verification_screen.dart` — eski (o'zgargan) depozit
  kontraktiga qurilgan edi.
- Eski `profile/domain/entities/booking_entity.dart`,
  `profile/data/models/booking_model.dart`,
  `booking/data/models/booking_model.dart`,
  `home/data/models/venue_model.dart`,
  `venue_detail/data/models/menu_item_model.dart` — bittalashtirilgan
  haqiqiy modellarga almashtirildi.

## 3. Mijoz ilovasi — real API bilan qayta qurilgan/qo'shilgan ekranlar

| Ekran | Holat |
|---|---|
| Home (katalog, "Bugun bo'sh joylar") | ✅ `GET /venues` |
| Xarita | ✅ `GET /venues/map` + pin bosilganda `GET /venues/{id}` |
| Qidiruv | ✅ `GET /venues?q=` (debounce bilan) |
| Filtrlar | ✅ yangi ekran — kind/check/rating/sort |
| Muassasa kartochkasi | ✅ `GET /venues/{id}` |
| To'liq menyu | ✅ `GET /venues/{id}/menu` |
| **Vaqt tanlash** | ✅ yangi to'liq ekran — kunlar/zona/mehmon/slot, `GET availability(+/days)` |
| Bron qilish | ✅ `POST /bookings`, `no_table_available`/`card_required` boshqariladi |
| **Slot band bo'ldi** | ✅ yangi ekran |
| Bron tasdiqlandi | ✅ haqiqiy QR (`qr_flutter`, 30s yangilanish) |
| Bronlarim (Faol/O'tgan) | ✅ `GET /bookings?tab=`, holat guruhlash |
| Bron detali | ✅ TARIX, bekor qilish, vaqt o'zgartirish, depozit holati |
| **Karta biriktirish** | ✅ qayta yozildi — `POST /me/cards` 201/202(SMS)/400(rad) |
| Kartalarim | ✅ `GET/POST/PATCH/DELETE /me/cards` |
| **Navbatga yozilish** | ✅ yangi ekran — `POST /waitlist` |
| **Stol bo'shadi** | ✅ yangi ekran — 10 daqiqalik taymer, `POST /waitlist/{id}/confirm` |
| Bildirishnomalar | ✅ `GET /me/notifications`, bo'sh holat to'g'ri ko'rsatiladi |

## 4. Xostes ilovasi — noldan qurildi

Alohida ildiz: `lib/main_staff.dart` (`flutter run -t lib/main_staff.dart`).

- `StaffSession`/`StaffLocalStorage`/`StaffApiClient` — mijozdan
  mustaqil sessiya, `X-Venue-Id` sarlavhasi avtomatik qo'shiladi.
- **Kirish**: Telegram bot orqali (`start` → deep-link → 2 soniyalik
  polling), "Raqam topilmadi" ekrani, muassasa tanlash (bir nechta
  filial bo'lsa).
- **Bugun**: `GET /staff/bookings`, HOZIR/KEYINGI guruhlash,
  hisoblagichlar, qidiruv.
- **Bron detali**: holat tugmalari `allowed` ro'yxatiga qarab
  yoqiladi (`arrive/late/no-show/cancel`), TARIX, `staff_note`.
- **QR skanerlash** (`mobile_scanner`) + **Qo'lda qidirish**.
- **Navbat**: Jonli/Buyurtma tablari, qo'shish/chaqirish/joylashtirish/
  chiqarish.
- **Zal** — minimal (pastga qarang, hujjat yetishmayapti).
- **Profil** — `GET /staff/me`, chiqish.
- Barcha yozuv amallariga `Idempotency-Key` (`uuid` paketi) ulandi.

## 5. Tekshirish

- `flutter analyze` — **0 xato** (faqat ~13 ta kichik lint-info,
  funksionallikka ta'sir qilmaydi).
- Android emulyatorda ikkala ilova ham haqiqiy prod serverga
  (`34-0-250-111.sslip.io`) ulanib sinaldi: Mijoz — Home → Venue
  Detail → Vaqt tanlang (haqiqiy kunlar/zonalar/slotlar) to'liq
  ishladi; Xostes — Telegram kirish oqimi (`start` → deep-link →
  polling) xatosiz ishladi.

---

## 5a. Yana bitta haqiqiy auth bugi topildi va tuzatildi

Emulyatorda sinash paytida aniqlandi: **Profil ekrani token yo'q
bo'lsa ham har doim "Aziz Karimov" deb soxta profil ko'rsatar edi**
— chunki `ProfileRemoteDataSourceImpl.getUserProfile()` har qanday
xatoni (shu jumladan `401`ni) yutib, qattiq yozilgan soxta
foydalanuvchini qaytarardi. Bu "auth majburiy emas" tamoyilini
buzardi: mehmon hech qachon haqiqiy "kiring" holatini ko'rmasdi.

- `getUserProfile()`/`updateProfile()` endi xatoni yutmaydi — token
  yo'q/eskirgan bo'lsa `Failure` qaytadi, `ProfileScreen` haqiqiy
  Login CTA'ni ko'rsatadi.
- `ProfileScreen._loadUserProfile()` endi avval
  `AppSession.authLocalStorage.isLoggedIn`ni tekshiradi — kirilmagan
  bo'lsa keraksiz tarmoq so'rovi yuborilmaydi.
- **"Hisobdan chiqish" mahalliy tokenni tozalamas edi** (faqat
  serverga `POST /auth/logout` yuborardi) — `isLoggedIn` chiqishdan
  keyin ham `true` bo'lib qolardi. Endi
  `AppSession.authLocalStorage.clear()` ham chaqiriladi.

## 5b. Telefon raqam inputi

`core/utils/uz_phone_formatter.dart` — `+998` mamlakat kodi maydonda
doimo ko'rinib turadigan qilib (`prefixText`), foydalanuvchi faqat
9 ta raqamni kiritadi, ular avtomatik `(##) ### ## ##` ko'rinishiga
formatlanadi (`UzPhoneInputFormatter`). Qo'llanildi: mijoz kirish
ekranidagi (dev/test) telefon maydoni, "Hamkor bo'lish" arizasi,
xostesning navbatga mehmon qo'shish formasi. Backendga yuborishda
`uzPhoneToE164()` bilan `+998901234567` shakliga o'giriladi.

Emulyatorda tekshirilib tasdiqlandi: `InputDecoration.prefixText`
kutilganidek ko'rinmadi (Material 3'da hint bilan bo'sh maydonda
ba'zan chizilmaydi) — shu sabab uch joyda ham (`prefixIcon` + qattiq
kenglik cheklovi) usuliga o'tildi, bu 100% ishonchli ko'rinadi.

## 5c. Xostes tomonini qayta ko'rib chiqish (kod tekshiruvi)

- `BugunScreen` va `ManualSearchScreen`dagi `TextEditingController`lar
  `dispose()` qilinmas edi (kichik xotira sizib chiqishi) — tuzatildi.
- **"Mehmon keldi" endi kelgan mehmonlar sonini so'raydi** — avval
  har doim bron qilingan sonni yubortarardi, hujjatdagi "1 kishi
  kelmadi — stol 4 kishilik qoladi" holatini hisobga olmasdi.
  Endi kichik dialog orqali +/- bilan sonini o'zgartirish mumkin.
- **Navbatda "Joylashtirish" tugmasi xodimdan xom stol UUID'ini
  qo'lda yozishni so'rardi** — hech kim buni bilmaydi/qila olmaydi,
  amalda ishlatib bo'lmas edi. Endi `GET /staff/zal/availability`dan
  haqiqiy bo'sh stollar ro'yxati chiqadi, xodim shundan birini
  tanlaydi (raqami va o'rin soni bilan).

Qolgan ekranlar (`StaffProfileScreen`, `StaffZalScreen`,
`QrScanScreen`) qayta o'qib chiqildi — jiddiy xato topilmadi.

**Kirish oqimida haqiqiy bug topildi va tuzatildi** — emulyatorda
sinaganda: kirish tugmasi bosilib, Telegram (Chrome fallback) ochilib,
ilovaga qaytilganda **polling butunlay to'xtab, "Internet aloqasi
mavjud emas" xatosi bilan bekor bo'lib qolgan edi** — bitta vaqtinchalik
tarmoq nosozligi (fonga o'tish paytida) butun 5 daqiqalik kutish oynasini
yo'qqa chiqarardi. Bu aynan hujjat ogohlantirgan holat edi: *"Ilova
fonga o'tib qaytganda pollingni davom ettiring."* Endi `_poll()`dagi
har qanday vaqtinchalik xato pollingni to'xtatmaydi — `_expiresAt`
(5 daqiqa) o'zi haqiqiy chegara bo'lib qoladi.

## 5d. Mijoz ilovasi ichidan Xostes rejimiga o'tish (dev qulayligi)

Ikkala ilova alohida `-t` build target talab qilishi (`lib/main.dart`
vs `lib/main_staff.dart`) sinash uchun noqulay edi — har safar qayta
qurish kerak bo'lardi. Endi **Profil → "Xostes rejimi"** orqali,
alohida qurmasdan, xuddi shu ishlab turgan Mijoz ilovasi ichidan
Xostes kirish oqimini sinash mumkin:

- `ProfileScreen`ga yangi menyu bandi qo'shildi — bosilganda
  `StaffSession.init()` chaqiriladi (mustaqil, mijozdan butunlay
  ajratilgan sessiya/token) va `StaffLoginScreen` shu Navigator ichiga
  push qilinadi.
- Xostes ekranlaridagi barcha `pushAndRemoveUntil(..., (route) => false)`
  chaqiruvlari `pushReplacement`ga almashtirildi — standalone
  (`main_staff.dart`) rejimida natija bir xil (stekda faqat bitta
  ekran bo'lgani uchun), lekin Mijoz ichidan ochilganda mijoz
  navigatsiya stekini endi **yo'q qilib yubormaydi** — orqaga
  tugmasi/imo bilan istalgan payt Mijoz Profiliga qaytish mumkin.
- Bu **faqat sinash qulayligi** — ishlab chiqarish (production)
  qurilishida ikkala ilova haligacha alohida bo'lishi kerak
  (`00-boshlash.md` — "Ikki alohida ilova"), shu sabab bu band aniq
  "(dev)" deb belgilangan.

## 5e. Sharhlar (Reviews) — jonli API endi mavjud, ulandi

Statik hujjat (`mijoz/04-katalog.md`) "Sharhlar ro'yxati — Yo'q (faqat
`rating`/`reviews_count`)" deb yozgan, lekin **2026-08-31 kuni jonli
serverning to'liq OpenAPI sxemasi qayta tekshirilganda** bu endpointlar
paydo bo'lgani aniqlandi: `GET /venues/{id}/reviews` (auth shart emas),
`POST/PATCH /bookings/{id}/review`. Avval `venue_detail_screen.dart` va
`reviews_screen.dart` **butunlay qattiq yozilgan (`Aziz Karimov` va h.k.)
soxta sharhlarni** ko'rsatardi — haqiqiy API borligiga qaramay.

- Yangi `venue_detail/data/{datasources,repositories}/review_*.dart` —
  boshqa featurelardagi datasource→repository→`ApiResult` patterniga
  mos.
- `ReviewsScreen` endi `GET /venues/{id}/reviews`dan haqiqiy ro'yxatni
  o'qiydi (yuklanish/xato/bo'sh holatlar bilan), reyting taqsimoti
  haqiqiy sharhlardan hisoblanadi, muassasa javobi (`reply_text`) bo'lsa
  ko'rsatiladi.
- `VenueDetailScreen`dagi "top review" preview blok ham haqiqiy birinchi
  sharhni oladi (`limit=1`) — sharh bo'lmasa blok butunlay yashiriladi.
- **Yangi**: `BookingDetailScreen`da `yakunlandi` (tugallangan)
  holatidagi bronlar uchun **"Sharh qoldirish"** tugmasi qo'shildi —
  yulduzcha (1-5) + ixtiyoriy matn bilan `POST /bookings/{id}/review`.

**Diqqat**: sevimlilar, "BRON PLUS" obuna va "Hamkor bo'lish" arizasi
hali ham mahalliy/soxta qolmoqda — bu **ataylab**, chunki na statik
hujjatda (`"Sevimlilar, sharhlar, JOY Plus, to'plamlar — ❌"`), na jonli
OpenAPI'da bularga mos endpoint yo'q (tekshirildi, `/api/v1/**`da
`favorite`/`bonus`/`partner` yo'q). Backend qo'shilganda ulash kerak.

## 5f. Shimmer loading va Figma SVG ikonkalar (2026-08-31)

Figma faylining to'g'ri havolasi topildi (`i8FGYLF28h8GYXQgd1Pczf`, node
`0:1` — "Mijoz mobil" canvasi, 57 ekran). Shundan:

- **Shimmer**: "6 · HOLATLAR → Yuklanmoqda" tugunidan skelet o'lchamlari/
  ranglari olindi (`bg-weak-50 #f7f7f7`, skelet `bg-soft-200 #ebebeb`).
  `shimmer` paketi qo'shildi, `core/widgets/shimmer_skeleton.dart`da
  qayta ishlatiladigan bloklar: `ShimmerBox`, `VenueListSkeleton`
  (Home/Qidiruv katalog kartalari — Figma bilan piksel darajasida bir
  xil), `ListRowSkeletonGroup` (bronlar/bildirishnoma/kartalar/sevimli/
  sharh ro'yxatlari), `DetailScreenSkeleton` (muassasa/bron tafsilot
  ekranlari). Barcha asosiy "to'liq sahifa yuklanmoqda" holatlaridagi
  oddiy `CircularProgressIndicator`lar (Mijozda ~12 ta, Xostesda ~6 ta
  ekran) shu skeletlarga almashtirildi.
- **SVG ikonkalar**: loyihada `main_icons/`/`nav_icons/` allaqachon bor
  ekan (avvalgi ishdan), lekin faqat bitta faylda ishlatilgan edi.
  Figma'dagi Profil/Yuklanmoqda ekranlaridan haqiqiy SVG'lar (Remix Icon
  kutubxonasi, dizayn shu tilni ishlatadi) yuklab olindi + qolgan ~55 ta
  ikonka nomi Remix Icon'ning ochiq npm paketidan (`remixicon@4.9.1`,
  MIT litsenziya) aniq mos nomlar bilan olindi. `AppAssets`ga qo'shildi,
  `core/widgets/app_icon.dart` — `Icon(IconData)` bilan bir xil `size`/
  `color` API'ga ega `AppIcon(String asset)` — shu orqali butun
  `lib/`bo'ylab (Mijoz + Xostes) **deyarli barcha** `Icon(Icons.X)`
  chaqiruvlari avtomatlashtirilgan skript bilan almashtirildi (30 fayl,
  57 ta o'rin), qolgan 4 tasi qo'lda tuzatildi (skript bitta joyda
  metod nomini `_buildCircleCategoryIcon` xato o'zgartirib qo'ygan edi —
  aniqlanib to'g'irlandi). Faqat 2 ta dekorativ `Icons.circle` (nuqta
  belgisi) o'zgartirilmadi — mazmunli ikonka emas.
- Emulyatorda tekshirildi (`adb install` + `am start`): Home, Profil,
  Kartalarim, Muassasa tafsiloti ekranlari — barcha yangi SVG ikonkalar
  va bottom-nav to'g'ri, Figma bilan bir xil ko'rinishda chiqdi.
  `flutter analyze` — 0 xato.
- **Figma haqiqiy skrinshoti/kontenti yo'q qolganlar**: Xostes ilovasi
  uchun Figma'dagi alohida "Xostes mobil" canvasiga hali kirish yo'q
  (faqat Mijoz canvasi ochildi) — shu sabab Xostes ekranlaridagi
  ikonkalar ham xuddi shu umumiy Remix Icon to'plamidan olindi (bir xil
  dizayn tili bo'lgani uchun izchil), lekin ekran-ekran Figma bilan
  piksel darajasida solishtirilmagan.

## 6. Hali ochiq — keyingi qadamlar

1. **Mijoz Telegram Login Widget** — 2026-08-31 kuni jonli serverning
   to'liq OpenAPI sxemasi (`/openapi.json`, `/openapi/client.json`)
   qayta tekshirildi: `TelegramAuthIn`da `id`dan boshqa hammasi
   (`hash`, `auth_date`, `phone` ham) ixtiyoriy, lekin mijoz uchun
   xostesdagi kabi `.../telegram/start` + `.../telegram/status/{nonce}`
   (bot-polling) endpointlari **yo'q** — faqat bitta
   `POST /api/v1/auth/telegram` bor. Shu sabab haqiqiy yagona yo'l —
   **Telegram Login Widget** (web-widget, WebView orqali).
   - `core/constants/telegram_config.dart` — konfiguratsiya joyi
     (`botUsername`, `widgetOriginUrl`), hozircha **bo'sh** (TODO).
   - `auth/presentation/screens/telegram_webview_login_screen.dart` —
     to'liq tayyor `webview_flutter` implementatsiyasi
     (`data-onauth` JS callback, `baseUrl` orqali domen mosligini
     ta'minlaydi).
   - `login_screen.dart` — `TelegramConfig.isConfigured` bo'lsa
     haqiqiy widgetni ochadi; bo'lmasa "vaqtinchalik test kirish"
     deb aniq belgilangan zaxira forma ko'rsatiladi (soxta hash
     endi yuborilmaydi — `hash`/`auth_date` shunchaki jo'natilmaydi).
   - **2026-08-31, keyinroq**: haqiqiy serverda sinalganda `401
     telegram_hash_missing` xatosi chiqdi — bu **kutilgan natija**:
     backend har doim Telegramning o'zi hisoblagan raqamli imzoni
     talab qiladi, uni soxta yuborib bo'lmaydi (xavfsizlik uchun
     ataylab shunday). Shu sabab "vaqtinchalik test kirish" formasi
     (ism/telefon maydonlari) butunlay **olib tashlandi** — u hech
     qachon ishlay olmasdi, faqat chalg'itardi. O'rniga aniq
     tushuntiruvchi eslatma qo'yildi: "Telegram bot hali sozlanmagan
     — kirish ishlamaydi". **Haqiqiy Telegram Login Widget
     ulanmaguncha, mijoz ilovasida umuman hech kim kira olmaydi** —
     bu vaqtinchalik holat emas, texnik majburiyat.
   - **2026-08-31, yana keyinroq**: siz tasdiqladingiz — Xostes va
     Mijoz **bitta botni** ishlatar ekan (`bron_staff_bot`).
     `telegram_config.dart`ga yozildi, `TelegramConfig.isConfigured`
     endi `true`, shu sabab kirish ekrani haqiqiy Login Widget'ni
     ochadi ("Telegram bot hali sozlanmagan" eslatmasi endi ko'rinmaydi).
     **Hali noaniq qolgan yagona narsa** — shu bot @BotFather'da qaysi
     domenga (`/setdomain`) bog'langani; `widgetOriginUrl` hozircha
     backend serveriga (`34-0-250-111.sslip.io`) qo'yilgan — agar
     kirishda Telegram "domain invalid" xatosi bersa, shuni to'g'ri
     domenga almashtirish kerak bo'ladi.
   - **Shu zahoti sinaldi** (`bron_staff_bot` bilan): Telegram widget
     o'zi **"Username invalid"** deb qaytardi. Bot xostesning
     deep-link oqimida ishlayotgani tasdiqlangan (haqiqiy `deep_link`
     qaytaradi) — demak bot mavjud, lekin **Login Widget rejimi shu
     bot uchun @BotFather'da hali yoqilmagan/domen sozlanmagan**
     (`/setdomain` bilan). Bot chat-rejimida ishlashi va Login
     Widget-rejimida ishlashi — @BotFather'da ikkita alohida sozlash,
     bittasi ikkinchisini avtomatik yoqmaydi.
   - **2026-08-31, yakuniy**: bot butunlay o'chirildi. `botUsername`
     yana bo'sh qilib qo'yildi (`isConfigured = false`) — hozircha
     kirish tugmasi yana aniq "sozlanmagan" eslatmasini ko'rsatadi
     (soxta/osilib qoladigan WebView emas).
   - **Qo'shimcha mustahkamlik qo'shildi**: `TelegramWebviewLoginScreen`
     avval — agar Telegram widget hech narsa ko'rsatmasa (masalan bot
     topilmasa) — abadiy "loading" holatida osilib qolar edi, chunki
     tashqi WebView faqat o'zining statik sahifasi yuklanganini biladi,
     Telegramning ichki iframe xatosini (masalan "Username invalid")
     ko'rolmaydi (boshqa domen). Endi **12 soniyalik taymer** bor —
     shu vaqtda haqiqiy kirish bo'lmasa, aniq xato ekrani ("Telegram
     tugmasi ko'rinmadi... bu ilova kodiga emas, @BotFather
     sozlamasiga bog'liq") + "Qayta urinish"/"Yopish" tugmalari bilan
     chiqadi.
   - **Sizdan kerak**: backend/jamoadan (1) mijoz uchun (yangi) bot username
     (masalan `bron_bot`, xostesning `bron_staff_bot`idan alohida
     yoki umumiy), (2) shu bot @BotFather'da qaysi domenga
     (`/setdomain`) bog'langani — `widgetOriginUrl` shu bilan mos
     bo'lishi kerak. Ikkalasi kelgach faqat `telegram_config.dart`ga
     yozish kifoya, boshqa hech narsa o'zgartirilmaydi.
2. **Test to'plami** — `test/*.dart` ichidagi 6 ta fayl
   (`home_and_booking_flow_test.dart`, `map_screen_test.dart`,
   `main_navigation_test.dart` va h.k.) eski mock ekranlarga
   qurilgan edi. Hozir compile bo'ladi, lekin haqiqiy tarmoq
   chaqiruvi qiladigan ekranlarni sinaydi — har biriga soxta
   repository (`repository:` konstruktor parametri orqali) berib
   qayta yozish kerak.
3. **Zal ekrani** — `docs/frontend/veb-admin/02-zal-done.md` hujjati
   repoda yo'q, shu sabab faqat `summary.free_now` va oddiy stol
   ro'yxati ko'rsatiladi. Hujjat kelganda to'liq zal xaritasini
   qurish kerak.
4. **Planshet maketi** — Xostes ekranlari hozircha faqat telefon
   o'lchamida (`402×874`). Planshet (`1194×834`) uchun alohida
   joylashuv (`LayoutBuilder`/`MediaQuery` bilan tarmoqlanish)
   qo'shilmagan.
5. **Joylashuv (geolocation)** — `sort=yaqin` va xaritadagi "men
   shu yerdaman" nuqtasi hali ulanmagan (`geolocator` paketi
   qo'shilmagan, ataylab — hujjat joylashuv yo'q bo'lganda bu
   saralashni yashirishni so'raydi, hozir shunday qilingan).
6. **Offline rejim** — faqat `Idempotency-Key` infratuzilmasi
   tayyor (har amalga UUID). Haqiqiy offline navbat/saqlash/qayta
   yuborish (internetni yo'qligini aniqlash, mahalliy saqlash)
   hali yozilmagan — bu alohida katta ish, hujjatda ham hali "yo'q".
7. **Figma** — fayl (`QhjMwPvVbmsQOY666wXvuw`) hisobga hali
   ulashilmagan. Ulashilgach, barcha yangi ekranlarni (Vaqt tanlash,
   Slot band bo'ldi, Navbat, Xostes ekranlari) node-ID bo'yicha
   piksel darajasida solishtirib chiqish kerak (rang/bo'shliq/shrift).
8. ~~Karta raqami orqali "Boshqa karta" oqimi qayta urinish~~ —
   **2026-08-31 qayta tekshirildi, muammo yo'q ekan**: `payment_declined`
   `BindCardScreen`ning o'zida (kartani biriktirishda) sodir bo'ladi,
   `card_required` esa `VaqtTanlashScreen`da — ikkalasida ham foydalanuvchi
   ekrandan chiqmasdan turib qayta uriniladi (`Navigator.push` bilan ochilib,
   natija `await` qilinadi), shuning uchun state hech qachon yo'qolmaydi.
9. **Xostesda `staff/reviews` moduli hali qurilmagan** — jonli OpenAPI'da
   `GET /staff/reviews`, `GET /staff/reviews/summary`,
   `POST /staff/reviews/{id}/reply` bor, lekin `xostes.zip`dagi 3 ta
   hujjat (`01-kirish`, `02-bugun-va-qr`, `03-navbat`) bu modulni
   tasvirlamaydi — ekran maketi/oqimi noma'lum, shu sabab hozircha
   qurilmadi (spekulyativ UI yozishdan saqlanildi).
