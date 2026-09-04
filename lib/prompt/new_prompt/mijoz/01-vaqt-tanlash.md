# Mijoz ilovasi — bo'sh vaqtlarni ko'rsatish

Figma: `Vaqt tanlang` (`857:1938`), `Restoran` (`32:61`),
`Slot band bo'ldi` (`102:683`).

| | |
|---|---|
| Swagger | `/docs/client` |
| OpenAPI | `/openapi/client.json` |
| Prod | `https://34-0-250-111.sslip.io` |

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-25).

---

## 1. Auth kerak emas

`GET /api/v1/venues/{id}/availability` **ochiq** — mehmon kirmasdan ham
bo'sh vaqtlarni ko'ra oladi. Token faqat bron **qilishda** kerak bo'ladi.

Bu dizaynga mos: onboarding ekranlarida muassasalar login'gacha
ko'rinadi.

## 2. Kunlar lentasi

Dizaynda 5 kunlik lenta (`Bugun 27 · Erta 28 · Sesh 29 · Chor 30 · Pay 31`)
va `Taqvim` havolasi. Har kun uchun alohida so'rov yubormang:

```
GET /api/v1/venues/{id}/availability/days?guests=4&days=5
```

```json
{ "days": [
    { "date": "2026-08-26", "has_free_slots": true },
    { "date": "2026-08-27", "has_free_slots": true },
    { "date": "2026-08-28", "has_free_slots": false }
] }
```

`has_free_slots: false` bo'lgan kunni **kulrang** qiling, lekin bosish
mumkin qoldiring — mehmon o'sha kunga navbatga yozilishi mumkin.

`from` parametri ixtiyoriy (standart — bugun), `days` 1–14.

## 3. Bir kunning slotlari

```
GET /api/v1/venues/{id}/availability?date=2026-08-26&guests=4
```

```json
{
  "date": "2026-08-26",
  "guests": 4,
  "closed": false,
  "slots": [
    { "time": "10:00", "available": true },
    { "time": "10:30", "available": true },
    { "time": "20:30", "available": false }
  ],
  "deposit": { "required": true, "amount": 120000, "per_person": 37500 },
  "zones": [
    { "id": "26926bc7-...", "name": "Asosiy zal", "sort_order": 0 },
    { "id": "5ef37697-...", "name": "Terasa", "sort_order": 1 }
  ],
  "max_seats": 4,
  "settings": { "slot_minutes": 30, "booking_duration_minutes": 120,
                "advance_days": 30 }
}
```

### Band slotlar ro'yxatda qoladi

`available: false` bo'lgan slot **olib tashlanmaydi**. Dizayn uni kulrang
chip qilib ko'rsatadi — mehmon "bu vaqt bor edi, lekin band" ekanini
bilishi kerak va bosganda `Slot band bo'ldi` ekraniga o'tadi (navbatga
yozilish taklifi bilan).

### Zonalar — `Qaysi joyda` chiplari

`zones` ro'yxati chiplarni chizish uchun. Birinchi chip **"Farqi yo'q"**
bo'ladi — u API'dan kelmaydi, uni o'zingiz qo'shasiz va tanlanganda
`zone_id` yubormaysiz.

Zona tanlansa so'rovga `&zone_id=<uuid>` qo'shiladi va slotlar shu zona
stollari bo'yicha qayta hisoblanadi.

> Dizayndagi `Deraza yonida` chipi **zona emas** — u stol tavsifi
> (`description`). Hozircha u bo'yicha filtr yo'q; chiplarni faqat
> `zones` dan chizing.

### Depozit

`deposit` **butun so'rov uchun** qaytadi, slot darajasida emas — chunki
depozit mehmonlar soniga bog'liq, vaqtga emas.

```
required = guests >= deposit_min_guests
amount   = min(per_person × guests, shift)
         = min(37 500 × 4, 120 000) = 120 000
```

Dizaynda ba'zi slot chiplarida kalendar ikonkasi bor — `required: true`
bo'lganda **hamma chipga** qo'ying, va pastdagi izohni ko'rsating:
*"bu vaqtlarda depozit kartada bloklanadi"*.

`guests` o'zgarganda `amount` ham o'zgaradi — chiplarni qayta so'rang.

### `max_seats`

Eng katta stolning sig'imi. `guests` undan katta bo'lsa hamma slot
`available: false` bo'ladi. Bunda dizayndagi xabarni ko'rsating:

> Eng katta stol — 14 kishi · katta kompaniya uchun zal bor

### `settings`

| Kalit | Nima uchun |
|---|---|
| `slot_minutes` | Chiplar orasidagi qadam (30) |
| `booking_duration_minutes` | "Stol 2 soat sizniki" degan izoh uchun |
| `advance_days` | Taqvimda qancha oldinga ruxsat berilishi (30) |

Bu qiymatlar **har filialda boshqacha bo'lishi mumkin** — qattiq yozmang.

## 4. Yopiq kun

```json
{ "date": "2026-08-31", "closed": true, "slots": [], "...": "..." }
```

`closed: true` bo'lsa `slots` bo'sh. Dizaynda bunday ekran chizilmagan —
"Bu kuni yopiq" degan holatni o'zingiz qo'shing.

## 5. Xatolar

| `code` | Status | Qachon | UI |
|---|---|---|---|
| `date_in_past` | 400 | O'tgan sana | Taqvimda oldini oling |
| `date_too_far` | 400 | `advance_days` dan uzoq | Taqvimda chegara qo'ying |
| `venue_not_found` | 404 | Muassasa yo'q **yoki faol emas** | "Muassasa topilmadi" |

`venue_not_found` — muassasa `pauza` yoki `moderatsiya` holatida bo'lsa
ham shu qaytadi. Bu ataylab: mehmon farqni bilmasligi kerak.

## 6. Bugungi kun

Bugungi slotlar avtomatik filtrlanadi: hozirdan **15 daqiqadan** oldingi
vaqtlar ro'yxatga tushmaydi. Ya'ni soat 19:00 da so'rasangiz, birinchi
chip 19:15 dan boshlanadi.

Ilova ochiq turganda ro'yxat eskiradi — ekranga qaytganda **qayta
so'rang**.

## 7. Hali yo'q

| Nima | Holat |
|---|---|
| Bron yaratish | ✅ `02-bron-qilish.md` |
| Muassasalar katalogi, qidiruv, xarita | ✅ `04-katalog.md` |
| Navbatga yozilish | ✅ `05-navbat.md` |
| Depozit va karta biriktirish | ✅ `03-depozit.md` |
| Sharhlar, sevimlilar | Yo'q |

Hozir **"Vaqt tanlang" ekranining butun yuqori qismini** qurish mumkin:
kunlar lentasi, zona chiplari, mehmon soni, slot chiplari, depozit izohi.
Pastdagi "davom etish" tugmasi bronlar moduli bilan ulanadi.

Muassasa ma'lumotlari (nom, manzil, reyting, menyu) uchun endpoint hali
yo'q — hozircha `venue_id` ni qo'lda bering.
