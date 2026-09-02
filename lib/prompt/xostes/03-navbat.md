# Xostes ilovasi — Navbat

Figma: `Navbat` (`305:488`), `Navbat · buyurtma` (`1167:1703`),
`Navbatga qo'shish` (`785:1078`), `Mehmonni chaqirish` (`785:1154`).

Oldingi qadamlar: `01-kirish.md`, `02-bugun-va-qr.md`.

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-26).

---

## 1. Ikki tab — ikki xil navbat

Dizayndagi `Jonli navbat` va `Buyurtma` tablari bir endpointdan, `kind`
parametri bilan olinadi:

```
GET /api/v1/staff/waitlist?kind=jonli       ← standart
GET /api/v1/staff/waitlist?kind=buyurtma
```

| | `jonli` | `buyurtma` |
|---|---|---|
| Kim | Ko'chadan kelgan mehmon | Ilovadagi mehmon |
| Kim qo'shadi | **Siz** | Mehmonning o'zi |
| Nima kutadi | Bo'sh stol | Aniq vaqtdagi bron bekor bo'lishini |
| `desired_from/to` | `null` | To'ldirilgan |

`X-Venue-Id` **majburiy** — navbat aniq filialniki.

## 2. Ro'yxat

```json
{
  "items": [
    { "id": "176071ef-...", "kind": "jonli",
      "guest_name": "Rustam Aliyev", "guest_phone": "+998901112233",
      "guests": 4, "status": "kutmoqda",
      "position": 1, "waiting_minutes": 12,
      "estimated_wait_minutes": 0,
      "expires_at": null, "offered_table": null,
      "booking_id": null, "created_at": "2026-08-26T08:53:17.198500Z" }
  ],
  "waiting": 2,
  "average_wait_minutes": 15
}
```

| Maydon | Dizayndagi joyi |
|---|---|
| `position` | Chapdagi raqam (`1 · Rustam Aliyev`) |
| `waiting_minutes` | `12 daq kutmoqda` |
| `estimated_wait_minutes` | `~25 daqiqa`, `Bekzod R. 5 daqiqada` |
| `waiting` | Yuqoridagi `Navbatda · 5` |
| `average_wait_minutes` | `O'rtacha kutish · ~25 daq` |

## 3. Navbatga qo'shish

`POST /api/v1/staff/waitlist`

```json
{ "guest_name": "Rustam Aliyev", "guests": 4,
  "guest_phone": "+998901112233", "zone_id": null }
```

**Telefon ham, zona ham ixtiyoriy.** Telefonsiz mehmonni ovoz bilan
chaqirasiz — push yuborilmaydi.

Javob darhol `position` va `estimated_wait_minutes` beradi — dizayndagi
*"Taxminiy kutish ~25 daqiqa · 5-o'rin"* ni shundan chizing.

| `code` | Status | Sabab |
|---|---|---|
| `party_too_large` | 400 | Eng katta stoldan katta kompaniya. Javobda `max_seats` |

Kutishning ma'nosi yo'q bo'lgani uchun ataylab to'siladi — 10 kishilik
kompaniyani 4 o'rinli zalda kutdirib qo'yish yomon tajriba.

## 4. Chaqirish

`POST /api/v1/staff/waitlist/{id}/call`

```jsonc
{ "table_id": "..." }   // yoki {} — «Stolni mehmon tanlasin»
```

```json
{ "status": "chaqirilgan", "offered_table": "12",
  "expires_at": "2026-08-26T09:03:17.229588Z" }
```

`expires_at` — **10 daqiqalik tasdiqlash oynasi**. Dizayndagi
*"Tasdiqlash uchun 10 daqiqa vaqti bo'ladi. Javob bermasa, stol keyingi
mehmonga o'tadi."*

`table_id` **berilmasa** — dizayndagi «Stolni mehmon tanlasin»: mehmonga
bo'sh stollar ro'yxati yuboriladi.

### Oyna o'zi yopiladi

Javob bermagan mehmon ro'yxatni **keyingi so'raganingizda**
`otkazib_yuborildi` bo'ladi va ro'yxatdan chiqadi. Ilovada taymer
yuritish shart emas, lekin `expires_at` ni ko'rsating va ro'yxatni
vaqti-vaqti bilan yangilang.

## 5. Joylashtirish

`POST /api/v1/staff/waitlist/{id}/seat` → `{"table_id": "..."}`

**Bu bron yaratadi** — darhol `keldi` holatida, `source = xostes`.
Javobdagi `booking_id` bilan bron detaliga o'tish mumkin.

Ya'ni alohida "bron yaratish" qadami yo'q: mehmonni stolga o'tqazdingiz —
bron o'zi paydo bo'ldi va "Bugun" ekranida ko'rinadi.

| `code` | Status | Sabab |
|---|---|---|
| `not_enough_seats` | 400 | Stol kichik |
| `table_not_found` | 404 | Stol boshqa filialniki |
| `invalid_transition` | 409 | Allaqachon joylashtirilgan yoki chiqib ketgan |

## 6. Chiqarish

`DELETE /api/v1/staff/waitlist/{id}` → `204`. Dizayndagi `Chiqarish`
tugmasi.

Joylashtirilgan yozuvni chiqarib bo'lmaydi (`409`).

## 7. Bron bekor bo'lganda nima bo'ladi

Siz bronni bekor qilsangiz yoki `kelmadi` deb belgilasangiz — o'sha vaqt
va sig'imga mos **`buyurtma`** navbatidagi birinchi mehmon **avtomatik
chaqiriladi** va unga push ketadi.

Ya'ni `Buyurtma` tabidagi ro'yxat o'zidan o'zgaradi. Bron bekor
qilgandan keyin ro'yxatni yangilang.

## 8. Offline — `Idempotency-Key`

Navbatning to'rtta yozuv amali ham kalitni qabul qiladi:

```
POST   /api/v1/staff/waitlist                navbatga qo'shish
POST   /api/v1/staff/waitlist/{id}/call      chaqirish
POST   /api/v1/staff/waitlist/{id}/seat      joylashtirish
DELETE /api/v1/staff/waitlist/{id}           chiqarish
```

Qoida bronlardagi bilan bir xil (`02-bugun-va-qr.md` §6): har amalga
yaratilish paytida UUID, qayta yuborishda o'shani saqlang, bitta kalit —
bitta amal.

`DELETE` javob tanasiz `204` qaytaradi; kalit bilan qayta yuborilsa yana
`204` keladi, xato emas.

## 9. Hali yo'q

| Nima | Holat |
|---|---|
| SMS xabar | Provayder yo'q — push mock |
| QR kod bilan navbatga qo'shish (`342:723`) | Yo'q |
| Sartaroshxona navbati (usta tanlovi) | Yo'q — vertikal |
| Smena yakuni statistikasi | Yo'q |
