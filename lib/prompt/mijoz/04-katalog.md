# Mijoz ilovasi — muassasalar katalogi

Figma: `Home` (`128:968`), `Qidiruv` (`60:193`), `Filtrlar` (`61:243`),
`Restoran` (`32:61`), `To'liq menyu` (`260:1900`),
`Home · xarita` (`972:24330`).

Bu — ilovaning **kirish nuqtasi**. Undan keyingi qadam:
`01-vaqt-tanlash.md`.

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-26).

---

## 1. Auth kerak emas

Katalogning hamma endpointi **ochiq**. Mehmon kirmasdan ko'ra oladi,
token faqat bron qilishda kerak bo'ladi.

Faqat **`faol`** muassasalar chiqadi. `moderatsiya` va `pauza`
holatidagilari `404` beradi — mavjud emasdan farqlanmaydi.

## 2. Katalog

```
GET /api/v1/venues?kind=&q=&district=&cuisine=&check=&rating_min=
                  &sort=&lat=&lon=&date=&guests=&limit=&offset=
```

```json
{
  "items": [{
    "id": "4cfcc593-...", "name": "Osteria Da Vinci", "kind": "restoran",
    "cuisine": "Yevropa oshxonasi", "district": "Chilonzor",
    "rating": 4.8, "reviews_count": 124,
    "avg_check": 120000,
    "distance_km": 7.0,
    "photo_url": null,
    "free_slots": ["19:00", "19:30", "20:00"],
    "deposit_required": true
  }],
  "total": 1, "limit": 20, "offset": 0
}
```

### Filtrlar — dizayndagi `Filtrlar` ekrani

| Parametr | Qiymatlar | Dizayndagi joyi |
|---|---|---|
| `kind` | `restoran · geym_klub · sartaroshxona · gozallik_saloni` | Vertikal chiplari |
| `q` | matn | «Restoran, taom yoki joy» |
| `district` | matn | — |
| `cuisine` | matn | Oshxona chiplari |
| `check` | `50_gacha · 50_150 · 150_dan` | O'rtacha chek |
| `rating_min` | `4.0` · `4.5` · `4.8` | Reyting |
| `sort` | `yaqin · reyting · arzon · qimmat` | Saralash |

`q` hozircha **nom va oshxona** bo'yicha qidiradi. Taomlar bo'yicha
qidiruv keyingi bosqichda — dizayndagi "taom" so'zini vaqtincha
placeholder'dan olib tashlang yoki qoldiring, lekin natija bermasligini
biling.

Dizayndagi `Depozitsiz`, `Bo'sh stol bor`, `Katta kompaniya · 8+`
filtrlari **hali yo'q**.

### `sort=yaqin` joylashuvni talab qiladi

```json
{ "code": "location_required",
  "detail": "«Yaqin» saralash uchun joylashuv kerak" }
```

`400` bilan. Ruxsat berilmagan bo'lsa bu saralashni **o'chirib qo'ying**,
so'rov yubormang.

`lat`/`lon` berilsa har elementda `distance_km` keladi (km, bitta
kasrgacha). Koordinatasi yo'q muassasada `null`.

### `free_slots` — faqat so'rasangiz

`date` **va** `guests` birga berilgandagina to'ladi, aks holda `null`.

Eng ko'pi **3 ta** slot qaytadi — dizayndagi kartochkada ham uchta chip
bor. To'liq ro'yxat uchun `01-vaqt-tanlash.md`.

`deposit_required` — shu mehmon soni uchun depozit kerakmi. Kartochkada
belgi qo'yish uchun.

> Bu N ta muassasa uchun N marta hisoblash. Ro'yxat sahifasi 20 ta bo'lsa
> javob sekinroq keladi — `date`/`guests` ni **faqat kerak bo'lganda**
> yuboring (masalan foydalanuvchi sana tanlagandan keyin).

## 3. Xarita

```
GET /api/v1/venues/map?kind=&limit=200
```

```json
[{ "id": "...", "name": "Osteria Da Vinci", "kind": "restoran",
   "lat": 41.2856, "lon": 69.2034, "rating": 4.8 }]
```

**Ataylab yengil**: rasm, slot, masofa yo'q — xaritada yuzlab pin
bo'lishi mumkin. Pin bosilganda `GET /venues/{id}` bilan to'liq
kartochkani oling.

Koordinatasi yo'q muassasalar ro'yxatga **umuman tushmaydi**.

## 4. Muassasa kartochkasi

`GET /api/v1/venues/{id}?lat=&lon=`

Ro'yxatdagi barcha maydonlar + quyidagilar:

```json
{
  "address": "Bunyodkor 12",
  "description": "Chilonzordagi yevropa oshxonasi",
  "phone": "+998712000000",
  "lat": 41.2856, "lon": 69.2034,
  "hours_text": "10:00 — 24:00",
  "photos": [],
  "zones": ["Asosiy zal", "Terasa", "VIP"],
  "max_seats": 4,
  "popular_items": [
    { "id": "...", "name": "Osso buco",
      "description": "Sekin pishirilgan mol go'shti, gremolata",
      "price": 145000, "prep_minutes": 35, "is_popular": true,
      "category_id": "..." }
  ]
}
```

| Maydon | Nima uchun |
|---|---|
| `photos` | Galereya. Havolalar **vaqtinchalik** (bir soat) — keshlab qo'ymang |
| `zones` | `Qaysi joyda` chiplari uchun nomlar |
| `max_seats` | «Eng katta stol — 14 kishi» yozuvi |
| `popular_items` | `Mashhur taomlar` bo'limi, eng ko'pi 6 ta |
| `hours_text` | «Bugun 10:00–24:00» |

`free_slots` bu yerda **har doim `null`** — kartochkada to'liq slot
ro'yxati kerak, uni `01-vaqt-tanlash.md` dagi endpoint beradi.

## 5. To'liq menyu

`GET /api/v1/venues/{id}/menu` — dizayndagi `To'liq menyu` ekrani.

```json
{
  "categories": [
    { "id": "...", "name": "Issiq taomlar", "sort_order": 0, "items_count": 1 }
  ],
  "items": [
    { "id": "...", "name": "Osso buco",
      "description": "Sekin pishirilgan mol go'shti, gremolata",
      "price": 145000, "prep_minutes": 35, "is_popular": true,
      "category_id": "..." }
  ]
}
```

Kategoriyalar `sort_order` bo'yicha tartiblangan. Taomlar
`is_popular` birinchi, keyin alifbo bo'yicha.

`category_id` `null` bo'lgan taomlar ham bo'lishi mumkin (kategoriyasi
o'chirilgan) — ularni "Boshqa" guruhiga qo'ying.

**Yashirilgan va tugagan taomlar bu yerda chiqmaydi** — administrator
o'chirgan yoki tugagan deb belgilagan.

## 6. Hali yo'q

| Nima | Holat |
|---|---|
| To'plamlar va chegirmalar | Kontent moduli — yo'q |
| Tadbirlar | Yo'q |
| Sevimlilar | Yo'q |
| Sharhlar ro'yxati | Yo'q (`rating` va `reviews_count` bor, ro'yxat yo'q) |
| `Depozitsiz`, `Bo'sh stol bor`, `Katta kompaniya` filtrlari | Yo'q |
| Taomlar bo'yicha qidiruv | Yo'q |
| Geym klub tariflari, sartaroshxona xizmatlari | Yo'q — vertikallar |

`rating` va `reviews_count` hozircha **qo'lda kiritiladi** yoki bo'sh —
sharhlar moduli kelganda avtomatik hisoblanadi. Bo'sh bo'lsa reyting
belgisini ko'rsatmang.
