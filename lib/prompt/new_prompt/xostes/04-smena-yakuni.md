# Xostes ilovasi — smena yakuni

Figma: xostes `Smena yakuni`.

| | |
|---|---|
| Swagger | `/docs/staff` |
| Prod | `https://34-0-250-111.sslip.io` |

Misol javob **haqiqiy serverdan olingan** (2026-08-26).

---

## 1. Bitta so'rov

```
GET /api/v1/staff/shift/summary
GET /api/v1/staff/shift/summary?date=2026-08-25
```

`X-Venue-Id` **majburiy** — qaysi filialning smenasi ekani shundan
bilinadi. Berilmasa `400`.

`date` berilmasa — bugun.

```json
{
  "date": "2026-08-26",
  "venue_id": "df7063cd-a86d-4df2-bc26-3fb4e68e0068",
  "opens_at": "10:00",
  "closes_at": "00:00",
  "is_closed": false,
  "bookings": {
    "jami": 3,
    "kutilmoqda": 0,
    "keldi": 2,
    "kechikmoqda": 0,
    "kelmadi": 1,
    "bekor": 0,
    "yakunlandi": 0
  },
  "guests": 5,
  "waitlist": {
    "jami": 2,
    "kutmoqda": 0,
    "chaqirilgan": 0,
    "joylashtirildi": 1,
    "otkazib_yuborildi": 0,
    "chiqdi": 1
  },
  "seated_from_waitlist": 1,
  "busiest_hour": "20:00"
}
```

## 2. Smena chegarasi — kalendar kuni emas

Bu eng ko'p chalkashtiradigan joy. Smena **ish vaqti** bo'yicha kesiladi:

```
Muassasa 10:00–02:00 ishlaydi
  → 26-avgust smenasi = 26-avgust 10:00 dan 27-avgust 02:00 gacha
  → 27-avgust 01:30 dagi bron 26-avgustning smenasiga kiradi
```

Shuning uchun yarim tundan keyin `date` ni **o'zingiz hisoblamang** —
ilovada "bugun" ni server bilan bir xil tushunish uchun smena
tugamaguncha eski sanani yuboring.

Yopiq kunda `is_closed: true`, `opens_at` va `closes_at` — `null`.
Bunda oyna kalendar kuniga teng bo'ladi.

## 3. Maydonlar

| Maydon | Nima |
|---|---|
| `bookings` | Holat bo'yicha bronlar. Kalitlar `BookingStatus` bilan bir xil |
| `bookings.jami` | Barcha holatlar yig'indisi |
| `guests` | **Faqat kelgan** mehmonlar soni (`keldi` + `yakunlandi`) |
| `waitlist` | Smena ichida **yozilgan** navbat yozuvlari, holati bo'yicha |
| `seated_from_waitlist` | Navbatdan bronga aylanganlar |
| `busiest_hour` | Eng ko'p mehmon kelgan soat; bron bo'lmasa `null` |

### Nega `bookings.jami` navbatdan kattaroq bo'lishi mumkin

Yuqoridagi misolda `jami: 3`, lekin xostes qo'lda ikkita bron
belgilagan. Uchinchisi — **navbatdan joylashtirilgan** mehmon: `seat`
bron yaratadi, u ham shu smenaga tushadi.

Ya'ni `seated_from_waitlist` bronlar ichida **allaqachon sanalgan**, uni
alohida qo'shmang.

### Bronlar `starts_at`, navbat `created_at` bo'yicha

Bron smenaga **qachonga belgilangani** bilan tushadi, navbat esa
**qachon yozilgani** bilan. Bu ataylab: navbatdagi odam hozir kutadi,
bron esa kelasi vaqtga.

## 4. Nima yo'q

| Nima | Sabab |
|---|---|
| Tushum, o'rtacha chek | POS (iiko) integratsiyasi yo'q |
| Xodim kesimida statistika | Smenalar moduli yo'q — kim qaysi smenada ishlaganini tizim bilmaydi |
| Depozit summasi | Hisoblanadi, lekin pul harakatlanmaydi |
| Smenani "yopish" amali | Bu **faqat o'qish** — hech narsa saqlanmaydi |

Oxirgisi muhim: ekran hisobot ko'rsatadi, holatni o'zgartirmaydi.
"Smenani yopish" tugmasi qo'ysangiz, u faqat ilova ichida ishlaydi.
