# Mijoz ilovasi — Navbatga yozilish

Figma: `Slot band bo'ldi` (`102:683`), `Navbatga yozilish` (`210:1407`),
`Bronlarim · navbat` (`211:1432`), `Stol bo'shadi` (`211:1481`).

Oldingi qadam: `01-vaqt-tanlash.md`.

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-26).

---

## 1. Qachon taklif qilinadi

Ikki holatda:

- Slot **band** (`available: false`) — dizayndagi kulrang chip bosilganda
- Bron qilishda `409 no_table_available` — joy oxirgi lahzada ketdi

Ikkalasida ham `Slot band bo'ldi` ekrani ochiladi va navbat taklif
qilinadi.

## 2. Yozilish

`POST /api/v1/waitlist` — **token kerak**.

```json
{ "venue_id": "...", "guests": 2,
  "desired_from": "2026-08-27T19:00:00Z",
  "desired_to": "2026-08-27T20:00:00Z" }
```

`desired_from`/`desired_to` — dizayndagi oraliq chiplari:
`19:00–20:00 · 19:00–21:00 · Istalgan vaqt`. Oxirgisi uchun kengroq
oraliq yuboring (masalan butun ish kuni).

```json
{
  "id": "34be4610-...", "kind": "buyurtma", "status": "kutmoqda",
  "guests": 2,
  "desired_from": "2026-08-27T08:53:17Z",
  "desired_to": "2026-08-27T09:53:17Z",
  "position": 1,
  "waiting_minutes": 0,
  "estimated_wait_minutes": 0,
  "expires_at": null,
  "offered_table": null,
  "booking_id": null,
  "created_at": "2026-08-26T08:53:17.240605Z"
}
```

| `code` | Status | Sabab |
|---|---|---|
| `already_in_waitlist` | 409 | Siz allaqachon shu joyning navbatidasiz |
| `party_too_large` | 400 | Eng katta stoldan katta kompaniya |
| `invalid_range` | 400 | `desired_to` `desired_from` dan oldin |
| `venue_not_found` | 404 | Muassasa faol emas |

Bir mehmon bir muassasada **bitta** navbatda tura oladi.

## 3. Mening navbatlarim

`GET /api/v1/waitlist` — faol yozuvlar.

Dizayndagi `Bronlarim · navbat` kartochkasi shundan:

| Maydon | Kartochkada |
|---|---|
| `position` | `Sizdan oldin 1 kishi` (→ `position - 1`) |
| `estimated_wait_minutes` | `~25 daqiqa` |
| `status` | `NAVBATDASIZ` tegi |

## 4. Stol bo'shadi — 10 daqiqalik oyna

Bron bekor bo'lganda siz **avtomatik chaqirilasiz**: push keladi va
yozuv `chaqirilgan` holatiga o'tadi.

```json
{ "status": "chaqirilgan",
  "offered_table": "12",
  "expires_at": "2026-08-26T09:03:17Z" }
```

`expires_at` — dizayndagi **`09:42` taymeri**. Undan qolgan vaqtni
sanang.

Vaqt tugasa yozuv `otkazib_yuborildi` bo'ladi va ro'yxatdan chiqadi —
stol keyingi mehmonga o'tadi.

### Tasdiqlash

`POST /api/v1/waitlist/{id}/confirm`

```jsonc
{}                        // taklif qilingan stol olinadi
{ "table_id": "..." }     // «Stolni mehmon tanlasin» oqimida
```

Tasdiqlangach **bron yaratiladi** — darhol `keldi` holatida. Javobdagi
`booking_id` bilan bron detaliga o'ting.

| `code` | Status | Sabab |
|---|---|---|
| `not_called` | 409 | Sizni hali chaqirishmadi |
| `confirm_expired` | 409 | 10 daqiqa o'tdi — stol boshqaga o'tdi |
| `table_required` | 400 | Stol tanlanmagan (mehmon tanlaydigan oqim) |
| `not_enough_seats` | 400 | Tanlangan stol kichik |

`confirm_expired` chiqsa ro'yxatni yangilang — yozuv o'zi yo'qoladi.

## 5. Navbatdan chiqish

`DELETE /api/v1/waitlist/{id}` → `204`. Dizayn: *"Istalgan payt
navbatdan chiqishingiz mumkin"*.

## 6. Hali yo'q

| Nima | Holat |
|---|---|
| Push bildirishnoma qurilmaga | Provayder mock — server saqlaydi, yubormaydi |
| Jonli navbat (ko'chadan) | Bu faqat xostes uchun |
