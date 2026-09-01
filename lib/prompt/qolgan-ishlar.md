# Qolgan ishlar

## 1. Tashqi blok — sizdan/backenddan kerak

- **Mijoz Telegram Login Widget ishlamayapti.** Bot butunlay o'chirilgan
  (`bron_staff_bot` "Username invalid" berib, keyin o'chirildi). Yangi/
  tuzatilgan bot username va uning `@BotFather /setdomain` qiymati
  kerak — bulardan biri kelmaguncha **mijoz ilovasida hech kim kira
  olmaydi** (`core/constants/telegram_config.dart`da bo'sh turibdi).

## 2. Backendda bor, ilovada hali ulanmagan endpointlar

Bular Xostes mobil ilovasi hujjatlarida (`xostes.zip` — faqat 3 ta
fayl: kirish, bugun/QR, navbat) tasvirlanmagan, shu sabab ekran
maketi noma'lum va spekulyativ qurilmadi:

| Endpoint | Nima uchun kerak bo'lishi mumkin |
|---|---|
| `GET/POST /staff/menu*`, `PATCH/DELETE .../items` | Menyu boshqaruvi |
| `GET/POST /staff/employees*` | Xodimlar boshqaruvi |
| `GET/PATCH /staff/settings` | Muassasa sozlamalari |
| `POST /staff/zal/zones`, `.../tables` (CRUD) | Zal xaritasini tuzish |
| `GET /staff/dashboard`, `/staff/shift/summary` | Kunlik statistika |
| `GET /staff/guests*` | Mehmonlar bazasi |
| `GET /staff/reviews*`, `POST .../reply` | Sharhlarga javob berish |
| `POST/DELETE /staff/devices` | Push-bildirishnoma ro'yxati |
| `POST/DELETE /me/devices` | Mijozda ham xuddi shu (push) |

Bularning aksariyati ehtimol **veb-admin panelga** tegishli (alohida
loyiha, shu repoda yo'q) — Xostes mobil ilovasiga tegishli ekanini
tasdiqlash uchun hujjat/vazifa kerak.

## 3. Ichki, tugallanmagan qismlar

1. **Xostes ekranlari Figma bilan piksel darajasida solishtirilmagan.**
   Figma faylida faqat "Mijoz mobil" canvasi ochildi (57 ekran, to'liq
   tekshirildi); "Xostes mobil" canvasiga hali kirish yo'q — Xostes
   ikonkalari/shrift/rang Mijozdagi bilan bir xil tizimdan olindi
   (Remix Icon), lekin ekran-ekran solishtirilmagan.
2. **Test to'plami eskirgan** — `test/*.dart`dagi 6 ta fayl eski mock
   ekranlarga qurilgan, qayta yozish kerak.
3. **Planshet maketi yo'q** — Xostes faqat telefon o'lchamida
   (`402×874`), planshet (`1194×834`) uchun alohida joylashuv yo'q.
4. **Offline rejim yo'q** — faqat `Idempotency-Key` infratuzilmasi
   tayyor, haqiqiy saqlash/qayta yuborish yozilmagan.
5. **Joylashuv (geolocation) yo'q** — `sort=yaqin` ataylab yashirilgan
   (`geolocator` paketi qo'shilmagan).
6. **API'siz UI-only ekranlar** (ataylab, backendda endpoint yo'q):
   Sevimlilar (mahalliy/mock), "BRON PLUS" obuna, "Hamkor bo'lish"
   arizasi — uchalasi ham hozircha faqat vizual, real so'rov yubormaydi.

## Ustuvorlik

Eng katta blok — **#1 (Telegram bot)**: shu hal bo'lmaguncha mijoz
ilovasiga umuman kirib bo'lmaydi, boshqa hamma narsa ishlaydi.
