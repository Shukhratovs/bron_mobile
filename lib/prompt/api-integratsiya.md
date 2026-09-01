# API integratsiyasi — to'liq ro'yxat

Backend: `https://34-0-250-111.sslip.io`. Quyida ilovada **haqiqatan
so'rov yuboradigan** (kod tekshirilib tasdiqlangan) barcha endpointlar.
`console/*` (veb-admin/super-admin paneli) bu ikki mobil ilovaga
kirmaydi — shu sabab bu ro'yxatda yo'q.

## Mijoz ilovasi (`lib/main.dart`)

| Method | Endpoint | Nima uchun |
|---|---|---|
| POST | `/auth/telegram` | Telegram Login Widget orqali kirish |
| POST | `/auth/logout` | Chiqish |
| GET | `/me` | Profil ma'lumoti |
| PATCH | `/me` | Profilni tahrirlash |
| GET | `/me/cards` | Kartalar ro'yxati |
| POST | `/me/cards` | Karta biriktirish (201/202 SMS/400 rad) |
| POST | `/me/cards/confirm` | SMS kod tasdiqlash |
| PATCH | `/me/cards/{id}` | Asosiy karta qilib belgilash |
| DELETE | `/me/cards/{id}` | Kartani o'chirish |
| GET | `/me/notifications` | Bildirishnomalar |
| GET | `/venues` | Katalog (qidiruv/filtr/saralash) |
| GET | `/venues/map` | Xarita pinlari |
| GET | `/venues/{id}` | Muassasa kartochkasi |
| GET | `/venues/{id}/menu` | To'liq menyu |
| GET | `/venues/{id}/availability` | Bo'sh slotlar (kun+mehmon) |
| GET | `/venues/{id}/availability/days` | Bo'sh kunlar lentasi |
| GET | `/venues/{id}/reviews` | Muassasa sharhlari |
| GET | `/bookings?tab=` | Bronlarim (faol/o'tgan) |
| GET | `/bookings/{id}` | Bron tafsiloti |
| POST | `/bookings` | Bron yaratish |
| POST | `/bookings/{id}/cancel` | Bronni bekor qilish |
| PATCH | `/bookings/{id}/time` | Bron vaqtini o'zgartirish |
| GET | `/bookings/{id}/qr` | QR kod (30s yangilanadi) |
| POST | `/bookings/{id}/review` | Sharh qoldirish |
| PATCH | `/bookings/{id}/review` | Sharhni tahrirlash |
| GET | `/waitlist` | Navbat yozuvlarim |
| POST | `/waitlist` | Navbatga yozilish |
| POST | `/waitlist/{id}/confirm` | "Stol bo'shadi" — joyni tasdiqlash |
| DELETE | `/waitlist/{id}` | Navbatdan chiqish |

**29 endpoint ulangan.**

## Xostes ilovasi (`lib/main_staff.dart`)

| Method | Endpoint | Nima uchun |
|---|---|---|
| POST | `/staff/auth/telegram/start` | Bot orqali kirish — nonce+deep-link |
| GET | `/staff/auth/telegram/status/{nonce}` | Kirish holatini polling (2s) |
| GET | `/staff/venues` | Xodim biriktirilgan muassasalar |
| GET | `/staff/me` | Xodim profili |
| GET | `/staff/bookings?date=` | "Bugun" ro'yxati |
| GET | `/staff/bookings/{id}` | Bron tafsiloti |
| POST | `/staff/bookings` | Qo'lda bron yaratish |
| POST | `/staff/bookings/{id}/arrive` | "Mehmon keldi" |
| POST | `/staff/bookings/{id}/late` | "Kechikmoqda" |
| POST | `/staff/bookings/{id}/no-show` | "Kelmadi" |
| POST | `/staff/bookings/{id}/cancel` | Bronni bekor qilish |
| PATCH | `/staff/bookings/{id}/tables` | Stol berish/almashtirish |
| PATCH | `/staff/bookings/{id}/time` | Vaqtni o'zgartirish |
| POST | `/staff/bookings/scan` | QR skanerlash |
| GET | `/staff/zal` | Zal holati (bo'sh/band stollar) |
| GET | `/staff/zal/availability?date=&guests=` | Navbatga stol tanlash ro'yxati |
| GET | `/staff/waitlist?kind=` | Navbat (Jonli/Buyurtma) |
| POST | `/staff/waitlist` | Navbatga qo'shish |
| POST | `/staff/waitlist/{id}/call` | Mehmonni chaqirish |
| POST | `/staff/waitlist/{id}/seat` | Joylashtirish (bron avtomatik) |
| DELETE | `/staff/waitlist/{id}` | Navbatdan chiqarish |

**20 endpoint ulangan.** Barcha yozuv amallarida (`arrive/late/no-show/
cancel/tables/time`, navbat 4 tasi) `Idempotency-Key` sarlavhasi
avtomatik yuboriladi (offline-ga tayyorgarlik).

## Jami: 49 endpoint, ikkala ilova ham to'liq real backendga ulangan
(mock/soxta ma'lumot yo'q — bitta ham qattiq yozilgan qiymat qolmagan).
