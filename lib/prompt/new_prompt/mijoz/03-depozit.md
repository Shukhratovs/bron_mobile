# Mijoz mobil — Depozit va karta biriktirish

Figma: `Depozit` (`35:82`), `Karta biriktirish` (`39:98`),
`SMS tasdiqlash` (`40:127`), `Karta rad etildi` (`208:1534`),
`Bron detali · o'tgan` (`84:545`).

Backend: `docs/prompts/23-depozit.md`.

## Qachon karta so'raladi

Depozit talab qilinsa (dizayn: «150 000 so'm bloklanadi... 6 soat oldin
bekor qilsangiz blok butunlay olib tashlanadi»), `POST /bookings` javob
qaytarish o'rniga 400 va shu xato bilan javob beradi:

```json
{
  "code": "card_required",
  "message": "Bu bron uchun karta biriktirish talab qilinadi",
  "amount": 120000
}
```

Bu ekran mijozdan **`Karta biriktirish`** oqimini so'raydi va tugagach
`POST /bookings` qayta yuboriladi — endi `card_id` bilan.

**Formulani mijoz ilovasi hisoblamaydi** — dizayndagi summa
`GET /venues/{id}` javobidagi `deposit_required`/`deposit_amount` orqali
oldindan ko'rsatiladi (mijoz «Bron qilish» tugmasini bosishdan oldin
bilishi kerak). Bu maydonlar 24-katalog bosqichida qo'shiladi.

## Karta biriktirish oqimi

Klient endi karta raqamini serverga yuboradi — provayder SDK sahifasi
ochilmaydi. Bu 23-depozit.md dagi asosiy o'zgarish.

```http
POST /api/v1/me/cards
Authorization: Bearer <mehmon tokeni>
Content-Type: application/json

{
  "pan": "8600123456784412",
  "expiry": "12/28",
  "holder": "IVANOV IVAN",
  "is_default": true
}
```

### 201 — muvaffaqiyatli

```json
{
  "id": "3f0…",
  "provider": "mock",
  "card_type": "uzcard",
  "masked_pan": "8600 •••• 4412",
  "is_default": true
}
```

`provider_token` **hech qachon** javobda qaytmaydi. `pan` xotirada
tegishli JS o'zgaruvchisidan darhol o'chiriladi (RAM'da ham qolmasin).

### 202 — SMS/3DS talab qilinadi

Dizayn: `SMS tasdiqlash` (`40:127`). Bu javob **xato emas**, oraliq bosqich:

```json
{
  "status": "sms_kerak",
  "binding_id": "bind_a1b2c3…",
  "masked_pan": "8600 •••• 0001"
}
```

Klient `binding_id` ni saqlaydi, taymerni ko'rsatadi va foydalanuvchidan
6 xonali kodni oladi:

```http
POST /api/v1/me/cards/confirm
{
  "binding_id": "bind_a1b2c3…",
  "code": "1234",
  "is_default": true
}
```

- **201** — karta biriktirildi (`CardOut`).
- **400 `sms_invalid`** — kod noto'g'ri. Dizayndagi «SMS kod noto'g'ri»
  ekrani. Kodni qayta so'rash tugmasi hali yo'q (haqiqiy provayderda
  qayta yuborish keladi — bu bosqichda oddiy qayta kiritish).

### 400 `payment_declined`

Dizayn: `Karta rad etildi` (`208:1534`). «Boshqa karta» tugmasi bir xil
oqimni yangi PAN bilan qayta boshlaydi.

## Bron yaratishda `card_id`

Depozit talab qilinadigan bronda `card_id` majburiy:

```http
POST /api/v1/bookings
{
  "venue_id": "…",
  "starts_at": "2026-09-15T19:00:00Z",
  "guests": 4,
  "card_id": "3f0…"
}
```

Xatolar:

| Kod | Ma'nosi | Nima qilish |
|---|---|---|
| `card_required` | Karta yuborilmagan, depozit kerak | Karta biriktirish oqimiga o'tish |
| `card_not_found` | Karta boshqa foydalanuvchiniki | Ro'yxatdan tanlanmagan |
| `payment_declined` | Provayder holdni rad etdi (mablag' yetarli emas) | «Boshqa karta» tugmasini ko'rsatish |

**Muhim:** `payment_declined` bo'lganda **bron yaratilmagan** — qayta
urinishda hamma maydon (venue_id, starts_at, guests) qayta yuboriladi.

## Depozit holati — `deposit_status`

`BookingOut.deposit_status` — dizayndagi kartochka ostidagi ma'lumot:

| Qiymat | Ekranda | Rangi |
|---|---|---|
| `talab_qilinmaydi` | ko'rsatilmaydi | — |
| `bloklangan` | «150 000 so'm bloklandi» | ko'k |
| `hisobga_otdi` | «Hisobingizga o'tdi» | yashil |
| `qaytarildi` | «Blok olib tashlandi» | kulrang |
| `ushlab_qolindi` | «150 000 so'm hisobingizdan o'tdi» | qizil |

Dizayn: `Bron detali · o'tgan` (`84:545`) — no-show holatida bir qatorda
«150 000 so'm hisobingizdan o'tdi» ko'rinadi.

## Bekor qilish oynasi

`booking_settings.cancel_window_hours` (standart 6 soat) —
`GET /venues/{id}` javobida yuboriladi. Bekor qilish ekrani (`66:405`)
shu ma'lumotni ko'rsatadi:

- **6 soatdan oldin** bekor qilinsa → blok olib tashlanadi
  (`deposit_status = qaytarildi`).
- **Oyna o'tgan bo'lsa** → depozit ushlab qolinadi
  (`deposit_status = ushlab_qolindi`).

Bu qaror serverda `POST /bookings/{id}/cancel` javobida darhol
qaytariladi — mijozga alohida so'rov kerak emas.

## Muhim chekloviya

- **Uzoq muddatga bron** — provayder holdi 7-30 kun amal qiladi. Shuning
  uchun `hold_max_advance_days` (standart 7) kundan uzoq bronda depozit
  **talab qilinmaydi** (`deposit_status = talab_qilinmaydi`). Fon
  vazifasi keladigan versiyada hold sana yaqinlashganda qo'yiladi va bu
  chegara olib tashlanadi.
- **Karta o'chirilishi** — faol hold bo'lgan karta o'chirilmaydi
  (`409 card_in_use`). Bron yakunlangach (arrive/no-show/cancel)
  o'chiriladi. Tarixdagi tranzaksiyalarda `card_id = null` bo'lib
  qoladi, lekin `masked_pan` yozuv nusxasi hujjatlarda ko'rinadi (kelasi
  bosqichda).
