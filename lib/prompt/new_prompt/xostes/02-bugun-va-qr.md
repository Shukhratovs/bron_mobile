# Xostes ilovasi — "Bugun", bron detali va QR skanerlash

Figma: `Bugun` (`286:244`), `Bron detali` (`292:468`), `Mehmon kelmadi`
(`787:1132`), `QR skanerlash` (`758:20939`), `Bron topildi` (`766:963`),
`Qo'lda qidirish` (`772:972`).

Oldingi qadam: `01-kirish.md`. Zal ekrani API'si:
`docs/frontend/veb-admin/02-zal-done.md` (bir xil endpointlar).

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-25).

---

## 1. "Bugun" ekrani

`GET /api/v1/staff/bookings?date=2026-08-26`

`date` berilmasa — bugun. Javob `BookingOut` massivi, **vaqt bo'yicha
tartiblangan**:

```json
[{
  "id": "1f5df460-...", "code": "BRN-7569",
  "guest_name": "Aziz Karimov", "guest_phone": null,
  "starts_at": "2026-08-26T19:00:00", "ends_at": "2026-08-26T21:00:00",
  "guests": 4, "status": "kutilmoqda", "source": "ilova",
  "tables": [{ "number": "12", "seats": 4, "description": "deraza yonida" }],
  "guest_note": "Tug'ilgan kun — tort olib chiqishni so'ragan",
  "arrived_at": null, "arrived_guests": null,
  "deposit_amount": 120000, "created_at": "2026-08-25T11:58:43"
}]
```

Qo'shimcha parametrlar: `status=` (bitta holat bo'yicha), `q=` (ism,
telefon yoki `BRN-` kodi bo'yicha qidiruv — dizayndagi `Qo'lda qidirish`
ekrani shuni ishlatadi).

### HOZIR / KEYINGI guruhlash

Dizayndagi bo'linish **klient tomonda** qilinadi: `starts_at` hozirgi
vaqtga yaqin bo'lganlar (masalan ±30 daqiqa) — `HOZIR`, qolganlari —
`KEYINGI`. Backend guruhlamaydi.

### Yuqoridagi hisoblagichlar

`Kutilmoqda · Keldi · Kechikmoqda · Bo'sh stol` — birinchi uchtasi
ro'yxatdan sanaladi. `Bo'sh stol` uchun `GET /api/v1/staff/zal` dagi
`summary.free_now`.

### Holatlar o'zi yangilanadi

`kechikmoqda` (15 daqiqa) va `kelmadi` (30 daqiqa) ga o'tish
**avtomatik** — ro'yxatni so'raganingizda hisoblanadi. Ilovada taymer
yuritish shart emas; ro'yxatni vaqti-vaqti bilan yangilang.

## 2. Bron detali

`GET /api/v1/staff/bookings/{id}` — ro'yxatdagi maydonlar + `staff_note`
(ichki izoh, mehmon ko'rmaydi) + `events` (dizayndagi `TARIX`).

```json
{ "code": "BRN-7569", "status": "keldi", "arrived_guests": 3,
  "staff_note": null,
  "events": [
    { "type": "yaratildi", "payload": {"source":"ilova","table":"12","guests":4},
      "actor_type": "mehmon", "created_at": "..." },
    { "type": "keldi", "payload": {"arrived_guests": 3},
      "actor_type": "xodim", "created_at": "..." }
  ] }
```

## 3. Holat o'zgartirish

```
POST /api/v1/staff/bookings/{id}/arrive     {"arrived_guests": 3}
POST /api/v1/staff/bookings/{id}/late       {}
POST /api/v1/staff/bookings/{id}/no-show    {"reason": "kelmadi"}
POST /api/v1/staff/bookings/{id}/cancel     {"reason": "muassasa_sababli"}
```

`arrived_guests` — dizayndagi *"1 kishi kelmadi — stol 4 kishilik
qoladi"*. Berilmasa bronniki olinadi.

### Ruxsat etilgan o'tishlar

```
kutilmoqda  → keldi · kechikmoqda · kelmadi · bekor
kechikmoqda → keldi · kelmadi · bekor
keldi       → yakunlandi
kelmadi · bekor · yakunlandi → (oxirgi holat)
```

Noto'g'ri o'tishda `409` va **ruxsat etilganlar ro'yxati** qaytadi:

```json
{ "code": "invalid_transition",
  "detail": "«keldi» dan «kelmadi» ga o'tib bo'lmaydi",
  "current": "keldi", "allowed": ["yakunlandi"] }
```

Tugmalarni shu asosda faolsizlantiring — `allowed` ni ishlating,
o'zingizda takrorlamang.

### `cancel` sabablari

`mehmon_soradi · muassasa_sababli · kelmadi` — dizayndagi
`Mehmon kelmadi` ekranidagi uch variant. Depozit moduli kelganda pul
taqdiri shu sababdan kelib chiqadi.

## 4. QR skanerlash

`POST /api/v1/staff/bookings/scan` → `{"qr_token": "..."}`

Mehmon ilovasidagi QR ni o'qib, ichidagi matnni o'zgartirmasdan
yuboring. Javob — to'liq bron detali (`events` bilan), ya'ni darhol
`Bron topildi` ekranini chizsangiz bo'ladi.

| Xato | Ma'nosi |
|---|---|
| `404 qr_invalid` | QR yaroqsiz **yoki eskirgan** (token 30 soniya yashaydi) |
| `403 booking_forbidden` | Bron boshqa filialniki |

QR eskirgan bo'lsa mehmondan ekranni yangilashni so'rang — ilova o'zi
30 soniyada qayta chizadi.

**QR bo'lmasa** — `?q=` bilan qidiring (telefon yoki `BRN-` kodi).
Dizayndagi `Qo'lda qidirish` ekrani.

## 5. Stol berish va almashtirish

```
PATCH /api/v1/staff/bookings/{id}/tables    {"table_ids": ["..."]}
PATCH /api/v1/staff/bookings/{id}/time      {"starts_at": "..."}
```

Bir bronga **bir nechta stol** berish mumkin (dizayndagi `Stol 1–2`).

| Xato | Ma'nosi |
|---|---|
| `409 table_busy` | Stol shu vaqtda band; javobda `tables` — qaysilari |
| `400 not_enough_seats` | O'rin yetarli emas |
| `404 table_not_found` | Stol boshqa filialniki |

Bo'sh stollarni `GET /api/v1/staff/zal/availability?date=&guests=` dan
oling.

## 6. Offline rejim — `Idempotency-Key`

Barcha yozuv endpointlari shu sarlavhani qabul qiladi:

```
POST /api/v1/staff/bookings/{id}/arrive
Idempotency-Key: 6f2a4c1e-...
```

Qoida oddiy, lekin buzilsa xato ko'rinmaydi:

1. Har offline amalga **yaratilish paytida** UUID bering
2. Qayta yuborishda **o'sha UUID ni saqlang** — yangisini hosil qilmang
3. Server saqlangan javobni qaytaradi, hech narsa ikkilanmaydi

Kalitsiz qayta yuborsangiz — ikkinchi so'rov `409 invalid_transition`
oladi (holat allaqachon o'zgargan), ya'ni foydalanuvchi tushunarsiz xato
ko'radi.

Bir kalitni ikki xil amalga ishlatsangiz `409 idempotency_key_reused`.

## 7. Qo'lda bron yaratish

`POST /api/v1/staff/bookings` — telefon qo'ng'irog'i yoki ko'chadan
kelgan mehmon uchun:

```json
{ "venue_id": "...", "starts_at": "...", "guests": 4,
  "guest_name": "Aziz Karimov", "guest_phone": "+998901234567",
  "source": "qongiroq", "staff_note": "VIP mehmon" }
```

`source`: `xostes` (standart) · `qongiroq` · `yandex` · `boshqa`.
Dizayndagi "Bron manbalari" hisoboti shundan yig'iladi.

Bu endpoint ham `Idempotency-Key` ni qabul qiladi.

## 8. Hali yo'q

| Ekran | Holat |
|---|---|
| Navbat | ✅ tayyor — `03-navbat.md` |
| Smena yakuni | ✅ tayyor — `04-smena-yakuni.md` |
| Mehmon yaqinlashdi (geofence) | Yo'q |
| Depozit ushlab qolish | Hisoblanadi, lekin pul harakatlanmaydi |
| Bildirishnomalar | Push manzili tayyor (`POST /staff/devices`), xodimga yuboruvchi chaqiruv hali yo'q |

Zal ekrani ishlaydi (`docs/frontend/veb-admin/02-zal-done.md` bilan bir xil API), va
stol holati endi **haqiqiy** — band stol `band` bo'lib ko'rinadi.
