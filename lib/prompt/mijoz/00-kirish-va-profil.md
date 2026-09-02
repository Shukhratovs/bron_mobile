# Mijoz ilovasi — kirish, profil, kartalar

Figma: `Telefon raqami` (`64:306`), `SMS kirish` (`64:468`), `Profil`
(`59:180`), `Kartalarim` (`206:1402`), `Bildirishnomalar` (`65:415`).

| | |
|---|---|
| Swagger | `/docs/client` |
| OpenAPI | `/openapi/client.json` |
| Prod | `https://34-0-250-111.sslip.io` |

Barcha misol javoblar **haqiqiy serverdan olingan** (2026-08-25).

---

## 1. SMS yo'q — Telegram Login Widget

Figmada kirish telefon + SMS kod bilan chizilgan. **SMS gateway hali
yo'q**, shuning uchun mijoz **Telegram Login Widget** orqali kiradi.

Xostes ilovasidan farqi bor va u muhim:

| | Mijoz ilovasi | Xostes ilovasi |
|---|---|---|
| Usul | Telegram **Login Widget** | Telegram **bot + `request_contact`** |
| Telefon | **Bermaydi** | Beradi (tasdiqlangan) |
| Nima uchun | Ro'yxatdan o'tish ochiq — kim bo'lishidan qat'i nazar | Raqam bo'yicha xodim topiladi |

Ya'ni mijozning `phone` maydoni **`null` bo'lib qoladi** — bu normal.
Haqiqiy raqam keyinroq OTP orqali biriktiriladi (SMS ulanganda).

> Figmadagi **"SMS kirish" ekrani hozircha chizilmaydi.**

## 2. Kirish

`POST /api/v1/auth/telegram` — Telegram Login Widget qaytargan
ma'lumotni o'zgartirmasdan yuboring:

```json
{ "id": 900000001, "first_name": "Aziz", "last_name": "Karimov",
  "username": "aziz", "photo_url": "https://t.me/i/x.jpg",
  "auth_date": 1787658450, "hash": "…" }
```

`hash` — Telegram imzosi, **server tekshiradi**. Uni o'zgartirmang va
o'zingiz hosil qilmang.

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 2592000,
  "is_new_user": true,
  "user": {
    "id": "d187cc27-...",
    "phone": null,
    "name": "Aziz Karimov",
    "telegram_id": 900000001,
    "locale": "uz",
    "visits_count": 0,
    "no_show_count": 0,
    "blocked_until": null,
    "created_at": "2026-08-25T11:47:30",
    "is_blocked": false
  }
}
```

| Maydon | Izoh |
|---|---|
| `expires_in` | **30 kun** — mobil ilova uchun uzoq sessiya |
| `is_new_user` | `true` → onboarding ekranlarini ko'rsating |
| `name` | Telegram'dagi ism-familiyadan yig'iladi |
| `phone` | Hozircha har doim `null` |

## 3. Chiqish

`POST /api/v1/auth/logout` → `204`.

Bu **barcha qurilmalardagi** eski tokenlarni bekor qiladi (server tomonda
sessiya avlodi oshadi). Chiqishdan keyin eski token bilan so'rov → `401`.

Ya'ni "boshqa qurilmalardan chiqish" alohida funksiya emas — `logout`
o'zi shunday ishlaydi. Foydalanuvchiga buni ayting.

## 4. Profil

```
GET   /api/v1/me
PATCH /api/v1/me      {name?, locale?}
```

`locale` — `uz` yoki `ru`.

> ⚠️ Figmadagi `Til tanlash` ekranida **uchta** til bor: O'zbekcha,
> Русский, **English**. Backend hozircha faqat `uz` va `ru` ni qabul
> qiladi. English yuborilsa `422`. Uchinchi tilni ko'rsatmang yoki
> o'chirilgan holda chizing.

`visits_count`, `no_show_count`, `is_blocked` — profil ekranidagi
ko'rsatkichlar. `is_blocked: true` bo'lsa mehmon bron qila olmaydi
(bloklash logikasi bronlar moduli bilan keladi).

## 5. Kartalar

```
GET    /api/v1/me/cards
POST   /api/v1/me/cards
PATCH  /api/v1/me/cards/{id}      asosiy qilib belgilash
DELETE /api/v1/me/cards/{id}
```

```json
[{ "id": "78e4be42-...", "provider": "payme", "card_type": "uzcard",
   "masked_pan": "8600 •••• 4821", "is_default": true }]
```

Birinchi karta avtomatik `is_default` bo'ladi. Bitta foydalanuvchida
faqat bitta asosiy karta bo'ladi — yangisini belgilasangiz eskisi o'zi
bekor bo'ladi.

`card_type`: `uzcard` yoki `humo` — dizayndagi ikonka shuni ko'rsatadi.

### ⚠️ Karta qo'shish oqimi o'zgaradi

Hozir `POST /me/cards` **klientdan `provider_token`** qabul qiladi. Bu
vaqtinchalik: to'lov provayderi (Payme/Click) hali ulanmagan.

Depozit moduli kelganda oqim shunday bo'ladi: karta raqami serverga
yuboriladi → server provayderdan token oladi → kerak bo'lsa 3DS/SMS
tasdiq. Ya'ni **`Karta biriktirish` va `SMS tasdiqlash` ekranlarini
hozir qurmang** — kontrakt o'zgaradi.

Karta raqami hech qachon saqlanmaydi va bu qoida o'zgarmaydi.

## 6. Bildirishnomalar

`GET /api/v1/me/notifications?limit=20&offset=0`

```json
{ "items": [], "total": 0, "limit": 20, "offset": 0 }
```

Hozircha bo'sh — bildirishnomalar bronlar moduli bilan paydo bo'ladi
(bron tasdiqlandi, eslatma, stol bo'shadi va h.k.).

Push provayderi (`PUSH_PROVIDER`) ham `mock` — xabarlar serverda
saqlanadi, lekin qurilmaga yuborilmaydi.

## 7. Xatolar

Format: `{ "code": "...", "detail": "..." }`.

| Status | Ma'nosi | Nima qilish |
|---|---|---|
| `401` | Token yo'q, eskirgan yoki chiqilgan | Kirish ekraniga |
| `403` | Huquq yo'q | **Yo'naltirmang** — xato holatini ko'rsating |
| `422` | Noto'g'ri ma'lumot (masalan `locale: "en"`) | Maydon xatosini ko'rsating |

## 8. Hozir nima qura olasiz

| Ekran | Holat |
|---|---|
| Kirish (Telegram) | ✅ |
| Onboarding (`is_new_user`) | ✅ |
| Profil, tahrirlash | ✅ (til — ikkita) |
| Kartalar ro'yxati | ✅ (qo'shish oqimi o'zgaradi) |
| Bildirishnomalar ro'yxati | ✅ (bo'sh) |
| **Vaqt tanlash** | ✅ — `01-vaqt-tanlash.md` |
| Muassasalar katalogi, qidiruv, xarita | ✅ — `04-katalog.md` |
| Bron qilish, Bronlarim, QR | ✅ — `02-bron-qilish.md` |
| Depozit, karta biriktirish | ✅ — `03-depozit.md` |
| Navbatga yozilish | ✅ — `05-navbat.md` |
| Sevimlilar, sharhlar, JOY Plus, to'plamlar | ❌ |
