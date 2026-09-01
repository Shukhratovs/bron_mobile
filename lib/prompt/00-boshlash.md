# Mobil dasturchi uchun boshlang'ich hujjat

Birinchi kuni shuni o'qing. Qolgan fayllar — ekran-ekran API
ma'lumotnomasi, ular kerak bo'lganda ochiladi.

---

## 1. Ikki alohida ilova

| | Xostes ilovasi | Mijoz ilovasi |
|---|---|---|
| Kim ishlatadi | Restoran xodimi, ish joyida | Mehmon |
| Qurilma | **Telefon + planshet** | Telefon |
| Figma sahifasi | `✦ ・Xostes mobil` (`1:2`) | `✦ ・Mijoz mobil` (`0:1`) |
| Ekranlar | ~17 noyob (har biri ikki o'lchamda) | ~57 |
| API sirti | `/docs/staff` — 38 yo'l | `/docs/client` — 21 yo'l |
| Kirish | Telegram **bot** (parolsiz) | Telegram **Login Widget** |
| Papka | `docs/mobile/xostes/` | `docs/mobile/mijoz/` |

Ikkalasi bitta backendga boradi, lekin **sirtlari alohida** — har biri
o'z OpenAPI hujjatidan tur generatsiya qiladi.

Figma fayli: `QhjMwPvVbmsQOY666wXvuw`.

## 2. Umumiy qoidalar

| | |
|---|---|
| Prod | `https://34-0-250-111.sslip.io` |
| Prefiks | `/api/v1` |
| Auth | `Authorization: Bearer <token>` — cookie yo'q |
| Xato | `{ "code": "...", "detail": "..." }` |
| Sahifalash | `?limit=&offset=` → `{ items, total, limit, offset }` |
| Til | `Accept-Language` — hozircha faqat javob matnlariga ta'sir qilmaydi |

### `401` va `403` ni aralashtirmang

| | Ma'nosi | Nima qilish |
|---|---|---|
| `401` | Token yo'q, eskirgan yoki hisob bloklangan | Kirish ekraniga |
| `403` | Token to'g'ri, huquq yo'q | **Yo'naltirmang** — xato holatini ko'rsating |

`403` da login ekraniga uloqtirish — eng ko'p uchraydigan xato. Foydalanuvchi
tizimga kirgan, shunchaki bu amalga ruxsati yo'q.

### `value: null` — nol emas

Ba'zi ko'rsatkichlar POS yoki billing integratsiyasidan keladi, ular hali
yo'q. `null` ni **"—"** deb chizing, `0` deb emas.

## 3. Xostes ilovasi

### Kirish — parolsiz

Xodimni administrator qo'shadi (telefon raqami bilan), **ro'yxatdan o'tish
yo'q**. Xodim ilovada "Telegram orqali kirish" bosadi:

```
POST /staff/auth/telegram/start   → { nonce, deep_link }
deep_link ni oching               → Telegram, "Raqamni yuborish"
GET  /staff/auth/telegram/status/{nonce}  → har 2 soniyada
      202 kutilmoqda · 200 token · 404 raqam topilmadi
```

Figmadagi **"SMS tasdiqlash" ekrani chizilmaydi** — SMS gateway yo'q,
Telegram uni almashtiradi.

Batafsil: `xostes/01-kirish.md`.

### Ekranlar

| Ekran | Holat | Hujjat |
|---|---|---|
| Kirish, muassasa tanlash | ✅ | `xostes/01-kirish.md` |
| **Bugun** — bronlar ro'yxati | ✅ | `xostes/02-bugun-va-qr.md` |
| Bron detali, holatlar | ✅ | `xostes/02-bugun-va-qr.md` |
| **QR skanerlash** | ✅ | `xostes/02-bugun-va-qr.md` |
| Qo'lda qidirish | ✅ | `xostes/02-bugun-va-qr.md` |
| **Zal** — stollar va holatlar | ✅ | `frontend/veb-admin/02-zal-done.md` (API bir xil) |
| **Navbat** — jonli va buyurtma | ✅ | `xostes/03-navbat.md` |
| Profil | ✅ qisman — `GET /staff/me` |
| Smena yakuni | ❌ API yo'q |
| Mehmon yaqinlashdi (geofence) | ❌ |
| Offline rejim | ❌ backend tayyor, quyiga qarang |

### Offline — arxitekturaga boshidan ta'sir qiladi

Dizaynda alohida ekran bor: *"Internet yo'q — offline rejim · 19:04 dagi
holat · **3 o'zgarish yuborilmadi**"*.

Xostes offline paytda bosishi mumkin bo'lgan **hamma** amal
`Idempotency-Key` sarlavhasini qabul qiladi:

```
POST   /staff/bookings                  yangi bron
POST   /staff/bookings/{id}/arrive      mehmon keldi
POST   /staff/bookings/{id}/late        kechikmoqda
POST   /staff/bookings/{id}/no-show     kelmadi
POST   /staff/bookings/{id}/cancel      bekor qilish
PATCH  /staff/bookings/{id}/tables      stolni almashtirish
PATCH  /staff/bookings/{id}/time        vaqtni o'zgartirish

POST   /staff/waitlist                  navbatga qo'shish
POST   /staff/waitlist/{id}/call        mehmonni chaqirish
POST   /staff/waitlist/{id}/seat        joylashtirish
DELETE /staff/waitlist/{id}             navbatdan chiqarish

Idempotency-Key: 6f2a4c1e-...
```

Qoida oddiy, lekin buzilsa xato **ko'rinmaydi**:

1. Har offline amalga **yaratilish paytida** UUID bering
2. Qayta yuborishda **o'sha UUID ni saqlang** — yangisini hosil qilmang
3. **Bitta kalit — bitta amal.** Uni boshqa endpointga qayta ishlatsangiz
   `409 idempotency_key_reused` qaytadi
4. Server saqlangan javobni qaytaradi, hech narsa ikkilanmaydi

Kalitsiz qayta yuborsangiz ikkinchi so'rov `409 invalid_transition` oladi
(holat allaqachon o'zgargan) va foydalanuvchi tushunarsiz xato ko'radi.

**Buni birinchi kundan qiling** — keyin qo'shish navbat qatlamini qayta
yozishni talab qiladi.

`DELETE /staff/waitlist/{id}` javob tanasiz `204` qaytaradi; kalit bilan
qayta yuborilsa yana `204` keladi, xato emas.

### Planshet

Har bir ekran Figmada **ikki o'lchamda**: telefon 402×874 va planshet
1194×834. API bir xil — farq faqat joylashuvda. Planshet ish joyidagi
stend, ya'ni u ko'proq ma'lumot ko'rsatadi (masalan zal va bronlar yonma-yon).

## 4. Mijoz ilovasi

### Kirish

Telegram **Login Widget** (bot emas). Muhim farq: widget **telefon
bermaydi**, shuning uchun `users.phone` `null` bo'lib qoladi — bu normal.

Figmadagi **"SMS kirish" ekrani chizilmaydi**.

Batafsil: `mijoz/00-kirish-va-profil.md`.

### Ekranlar

| Ekran | Holat | Hujjat |
|---|---|---|
| Kirish, onboarding | ✅ | `mijoz/00-kirish-va-profil.md` |
| Profil, til, kartalar | ✅ | `mijoz/00-kirish-va-profil.md` |
| **Katalog, qidiruv, filtrlar** | ✅ | `mijoz/04-katalog.md` |
| **Xarita** | ✅ | `mijoz/04-katalog.md` |
| Muassasa kartochkasi, menyu | ✅ | `mijoz/04-katalog.md` |
| **Vaqt tanlash** | ✅ | `mijoz/01-vaqt-tanlash.md` |
| **Bron qilish, QR, Bronlarim** | ✅ | `mijoz/02-bron-qilish.md` |
| Depozit, karta biriktirish | ✅ | `mijoz/03-depozit.md` |
| **Navbatga yozilish** | ✅ | `mijoz/05-navbat.md` |
| To'plamlar, tadbirlar | ❌ API yo'q |
| Sevimlilar, sharhlar | ❌ |
| JOY Plus obuna | ❌ |
| Geym klub, sartaroshxona, salon | ❌ faqat restoran ishlaydi |

### Bitta muhim cheklov

Katalogda **faqat `restoran`** turidagi muassasalar to'liq ishlaydi.
Geym klub soatlik seans, sartaroshxona esa xizmat + usta modelida —
ular hali qurilmagan. Vertikal chiplarini ko'rsating, lekin qolgan
uchtasi bo'sh natija beradi.

## 5. Nimadan boshlash

**Xostes ilovasi** (operatsion jihatdan shoshilinch):

1. Telegram kirish + `Raqam topilmadi` ekrani
2. Muassasa tanlash (bir necha filialli xodim uchun)
3. **Bugun** ekrani — HOZIR / KEYINGI guruhlash klient tomonda
4. Bron detali va holat tugmalari (`allowed` ro'yxatini ishlating)
5. QR skanerlash
6. Offline navbat skeleti — UUID kalitlari bilan, **hozirdan**
7. Zal, Navbat

**Mijoz ilovasi**:

1. Telegram kirish + onboarding
2. Katalog va qidiruv
3. Muassasa kartochkasi
4. Vaqt tanlash
5. Bron qilish + QR
6. Bronlarim
7. Depozit va karta

## 6. Sinash

Ilova qurilmasdan ham oqimlarni terminaldan tekshirsa bo'ladi:

```bash
# Xostes: Telegram kirish
curl -X POST https://34-0-250-111.sslip.io/api/v1/staff/auth/telegram/start
# chiqqan deep_link ni Telegramda oching, keyin:
curl https://34-0-250-111.sslip.io/api/v1/staff/auth/telegram/status/<NONCE>

# Mijoz: katalog (auth kerak emas)
curl "https://34-0-250-111.sslip.io/api/v1/venues?limit=5"
```

Interaktiv: **`/docs/staff`** va **`/docs/client`** — Swagger, `Authorize`
tugmasi bilan.

Klient generatsiyasi:

```bash
npx openapi-typescript https://34-0-250-111.sslip.io/openapi/staff.json -o src/api/staff.d.ts
```

## 7. Hujjat qanday yuritiladi

Backend har bosqichdan keyin shu papkaga qo'llanma yozadi — misollar
**haqiqiy serverdan olingan**, taxminiy emas. Endpoint o'zgarsa hujjat
o'sha zahoti yangilanadi.

Nomuvofiqlik ko'rsangiz ayting: hujjat noto'g'ri bo'lsa ham, backend
noto'g'ri bo'lsa ham tuzatiladi.
