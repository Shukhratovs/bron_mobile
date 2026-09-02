# Mijoz ilovasi — bron qilish va "Bronlarim"

Figma: `Tasdiqlandi` (`37:89`), `Bronlarim` (`42:130`), `Bron detali`
(`57:169`), `Vaqtni o'zgartirish` (`74:418`), `Bekor qilish` (`66:405`).

Oldingi qadam: `01-vaqt-tanlash.md`.

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-25).

---

## 1. Bron qilish

`POST /api/v1/bookings` — **token kerak**.

```json
{ "venue_id": "69372e16-...", "starts_at": "2026-08-26T19:00:00Z",
  "guests": 4, "zone_id": null,
  "guest_note": "Tug'ilgan kun — tort olib chiqishni so'ragan" }
```

`starts_at` — ISO 8601, **UTC**. `01-vaqt-tanlash.md` dagi `"19:00"`
chipini sana bilan qo'shib yuboring.

Javob — `201`:

```json
{
  "id": "1f5df460-...",
  "code": "BRN-7569",
  "venue_id": "69372e16-...",
  "guest_name": "Aziz Karimov",
  "guest_phone": null,
  "starts_at": "2026-08-26T19:00:00Z",
  "ends_at": "2026-08-26T21:00:00Z",
  "guests": 4,
  "status": "kutilmoqda",
  "source": "ilova",
  "tables": [{ "id": "8cbcb2eb-...", "number": "12", "seats": 4,
               "description": "deraza yonida" }],
  "zone_id": null,
  "guest_note": "Tug'ilgan kun — …",
  "arrived_at": null, "arrived_guests": null, "cancel_reason": null,
  "deposit_amount": 120000,
  "created_at": "2026-08-25T11:58:43"
}
```

### Stol o'zi biriktiriladi

Mehmon stol tanlamaydi — server eng mos bo'shini beradi (eng kichik
sig'im, keyin eng kichik raqam). `tables` da uning raqami va tavsifi
qaytadi: dizayndagi `Stol 12 · deraza yonida`.

`ends_at` — stol qachongacha band (`booking_duration_minutes`, standart
2 soat). Dizaynda buni "Stol 2 soat sizniki" deb ko'rsatsa bo'ladi.

### `deposit_amount`

`null` bo'lsa depozit talab qilinmaydi. To'lov moduli hali yo'q, ya'ni
summa **hisoblanadi va ko'rsatiladi**, lekin kartadan bloklanmaydi.
`Depozit` va `Karta biriktirish` ekranlarini hozircha qurmang.

### Xatolar

| `code` | Status | Ma'nosi | UI |
|---|---|---|---|
| `no_table_available` | 409 | Bu vaqtga bo'sh stol yo'q | **`Slot band bo'ldi`** ekrani (`102:683`) — navbat taklifi |
| `date_in_past`, `date_too_far` | 400 | Sana chegaradan tashqarida | Taqvimda oldini oling |
| `venue_not_found` | 404 | Muassasa faol emas | "Muassasa topilmadi" |
| `user_blocked` | 400 | Hisob vaqtincha bloklangan | Sababni ko'rsating |

`no_table_available` — **eng muhim holat**. Mehmon slotni ko'rgan
paytdan bron qilgunga qadar joy ketishi mumkin. Ro'yxatni yangilang va
`Slot band bo'ldi` ekranini oching.

## 2. QR kod

`GET /api/v1/bookings/{id}/qr`

```json
{ "code": "BRN-7569",
  "token": "1f5df460-….59588637.119bc2b33b6008a5",
  "expires_in": 17 }
```

Ikkita narsa, aralashtirmang:

| | Nima | UI |
|---|---|---|
| `code` | **Barqaror** — `BRN-7569` | Ekranda katta yozuv, xostes qo'lda qidiradi |
| `token` | **30 soniyada yangilanadi** | QR rasmiga aylantiriladi |

`expires_in` soniyadan keyin qayta so'rang va QR ni qayta chizing.
Dizayndagi *"30 soniyada yangilanadi"* aynan shu.

Token qisqa umrli — **skrinshot qilib yuborish ish bermaydi**. Bu
ataylab.

QR faqat `kutilmoqda` va `kechikmoqda` holatlarida beriladi; boshqa
holatda `qr_not_available`.

## 3. Bronlarim

`GET /api/v1/bookings?tab=faol` yoki `?tab=otgan`

Dizayndagi ikki tab. `faol` — kelgusi va tugallanmagan; `otgan` — bekor
qilingan, kelmagan, yakunlangan yoki vaqti o'tgan.

Javob — `BookingOut` massivi (yuqoridagi shakl).

### Holatlar

| `status` | Dizayndagi teg | Izoh |
|---|---|---|
| `kutilmoqda` | `TASDIQLANDI` | Odatiy holat |
| `kechikmoqda` | `KUTILMOQDA` | Vaqtdan 15 daqiqa o'tdi |
| `keldi` | — | Xostes belgiladi |
| `kelmadi` | `KELMADI` | 30 daqiqa o'tdi yoki xostes belgiladi |
| `bekor` | `BEKOR QILINGAN` | — |
| `yakunlandi` | — | Tashrif tugadi |

`kechikmoqda` va `kelmadi` ga o'tish **avtomatik** — ro'yxatni
so'raganingizda hisoblanadi. Ya'ni ilovada taymer yuritish shart emas,
lekin ekranga qaytganda ro'yxatni yangilang.

## 4. Vaqtni o'zgartirish

`PATCH /api/v1/bookings/{id}/time` → `{"starts_at": "..."}`

Yangi vaqtga stol qaytadan biriktiriladi — boshqa stol tushishi mumkin.
Bo'sh joy bo'lmasa `409 no_table_available`.

Faqat `kutilmoqda` va `kechikmoqda` holatlarida ishlaydi; boshqasida
`409 invalid_transition`.

## 5. Bekor qilish

`POST /api/v1/bookings/{id}/cancel` → `{"reason": "mehmon_soradi"}`

`reason` ixtiyoriy (standart `mehmon_soradi`). Depozit moduli kelganda
shu sabab pulning taqdirini belgilaydi — dizayndagi *"6 soat oldin bekor
qilsangiz blok butunlay olib tashlanadi"*.

## 6. Bron detali va tarix

`GET /api/v1/bookings/{id}` — `BookingOut` + `events`:

```json
"events": [
  { "type": "yaratildi", "payload": {"source":"ilova","table":"12","guests":4},
    "actor_type": "mehmon", "created_at": "2026-08-25T11:58:43" },
  { "type": "keldi", "payload": {"arrived_guests": 3},
    "actor_type": "xodim", "created_at": "2026-08-25T11:58:43" }
]
```

Dizayndagi `TARIX` bloki shundan chiziladi. `type` — erkin matn, yangi
turlar qo'shilishi mumkin; tanimaganini **o'tkazib yuboring**, xato
ko'rsatmang.

Mehmonga `staff_note` (ichki izoh) **hech qachon ko'rsatilmaydi** — u
har doim `null`.

## 7. Hali yo'q

| Nima | Holat |
|---|---|
| Depozit, karta bloklash | Keyingi bosqich |
| Navbatga yozilish | Yo'q — `Slot band bo'ldi` ekranida faqat xabar |
| Sharh yozish | Yo'q |
| Bildirishnomalar (eslatma, stol bo'shadi) | Yo'q |
| Muassasa kartochkasi, menyu | Yo'q — `24-muassasalar-katalogi.md` |
