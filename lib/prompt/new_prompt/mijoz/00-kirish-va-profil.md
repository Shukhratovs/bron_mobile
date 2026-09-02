# Mijoz ilovasi — kirish, profil, kartalar

Figma: `Telefon raqami` (`64:306`), `SMS kirish` (`64:468`), `Profil`
(`59:180`), `Kartalarim` (`206:1402`), `Bildirishnomalar` (`65:415`).

| | |
|---|---|
| Swagger | `/docs/client` |
| OpenAPI | `/openapi/client.json` |
| Prod | `https://34-0-250-111.sslip.io` |

Misol javoblar serverdan olingan (2026-08-25); kirish bo'limi bot
oqimiga o'tgandan keyin yangilandi (2026-09-02).

---

## 1. SMS yo'q — Telegram bot

Figmada kirish telefon + SMS kod bilan chizilgan. **SMS gateway hali
yo'q**, shuning uchun mijoz **Telegram boti** orqali kiradi.

Bu vaqtinchalik protez emas: bot `request_contact` tugmasi orqali
**tasdiqlangan** raqamni qaytaradi — SMS kabi ishonchli. SMS ulanganda
ikkinchi kanal bo'lib qo'shiladi, hozirgi oqim buzilmaydi.

> Figmadagi **"SMS kirish" ekrani hozircha chizilmaydi.** Uning o'rniga
> "Telegram orqali kirish" tugmasi va kutish holati.

Xostes ilovasi bilan **bitta bot** ishlatiladi (Telegramda bir botga bir
webhook to'g'ri keladi) — bot kim kirayotganini kirish havolasidan biladi.

### Login Widget nega emas

`POST /auth/telegram` (Login Widget) endpointi ham bor va o'chirilmagan,
lekin u **veb uchun**: widget — domenga bog'langan iframe, native ilovada
ishlatib bo'lmaydi va telefon raqamini bermaydi. Mobil ilovada quyidagi
bot oqimidan foydalaning.

## 2. Oqim — uch qadam

```
1. POST /api/v1/auth/telegram/start
      → { nonce, deep_link, expires_in, poll_after_seconds }

2. deep_link ni oching (Telegram ilovasi ochiladi)
      → mehmon "Raqamni yuborish" tugmasini bosadi

3. GET /api/v1/auth/telegram/status/{nonce}   ← har 2 soniyada so'rang
      → 202  hali kutilmoqda
      → 200  sessiya tokeni
      → 404  urinish eskirgan yoki token allaqachon olingan
```

Ro'yxatdan o'tish alohida oqim emas: raqam tizimda bo'lmasa yangi hisob
o'zi yaratiladi va javobda `is_new_user: true` keladi.

### 2.1. Boshlash

`POST /api/v1/auth/telegram/start` — **tana yo'q, token kerak emas**.

```json
{
  "nonce": "kZ8s...",
  "deep_link": "https://t.me/bron_bot?start=kZ8s...",
  "expires_in": 300,
  "poll_after_seconds": 2
}
```

`deep_link` ni tashqi havola sifatida oching (iOS: `UIApplication.open`,
Android: `Intent.ACTION_VIEW`). Telegram o'rnatilmagan bo'lsa brauzerda
ochiladi va u yerda ham ishlaydi.

`expires_in: 300` — 5 daqiqa. Shundan keyin qaytadan `start` chaqiring.

### 2.2. Polling

`GET /api/v1/auth/telegram/status/{nonce}` — har 2 soniyada
(`poll_after_seconds`).

Kutish holatida `202`:

```json
{ "status": "pending", "detail": "Telegram'da raqamingizni yuboring" }
```

Raqam tasdiqlangach `200`:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 2592000,
  "is_new_user": true,
  "user": {
    "id": "d187cc27-...",
    "phone": "+998901112233",
    "name": "Aziz Karimov",
    "telegram_id": 900000001,
    "locale": "uz",
    "visits_count": 0,
    "no_show_count": 0,
    "blocked_until": null,
    "created_at": "2026-09-02T11:47:30",
    "is_blocked": false
  }
}
```

| Maydon | Izoh |
|---|---|
| `expires_in` | **30 kun** — mobil ilova uchun uzoq sessiya |
| `is_new_user` | `true` → onboarding ekranlarini ko'rsating |
| `name` | Telegram kontaktidagi ism-familiyadan yig'iladi |
| `phone` | Tasdiqlangan raqam. **Deyarli har doim to'ladi** — pastga qarang |

Token **bir marta** beriladi: `200` dan keyin o'sha `nonce` ni yana
so'rasangiz `404 login_expired`. Tokenni darhol saqlang.

### 2.3. Qachon `phone` bo'sh qoladi

Ikki holatda hisob raqamsiz ochiladi (ikkalasi ham kirishni to'xtatmaydi):

* raqam O'zbekiston formatida emas (`+998 XX XXX XX XX`);
* o'sha raqam allaqachon **boshqa** Telegram hisobiga biriktirilgan —
  raqam egasida qoladi, kiruvchiga raqamsiz hisob ochiladi.

Ya'ni `phone` ni majburiy deb hisoblamang: profil ekranida `null` ni
to'g'ri ko'rsating.

### 2.4. Xato holatlari

| Holat | Nima ko'rinadi | Ilova nima qiladi |
|---|---|---|
| Mehmon botga umuman o'tmadi | `202` cheksiz | 5 daqiqadan keyin `404` — "Qaytadan urinish" tugmasi |
| Boshqa odamning kontaktini yubordi | `202` da qoladi | Bot o'zi tushuntiradi, ilova kutaveradi |
| `nonce` eskirdi | `404 login_expired` | `start` ni qaytadan chaqiring |

Polling'ni cheksiz qilmang: `expires_in` tugagach to'xtating.

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

Bildirishnomalar bronlar va navbat modullaridan keladi (stol bo'shadi,
bron tasdiqlandi va h.k.).

### Qurilmani ro'yxatdan o'tkazing

```
POST   /api/v1/me/devices        {"token": "...", "platform": "ios"}
DELETE /api/v1/me/devices?token=...
```

Kirgandan **keyin darhol** yuboring, chiqishda o'chiring. Busiz push
manzilsiz qoladi. Har ishga tushganda yuborsangiz bo'ladi — takror
yozuv paydo bo'lmaydi.

Push provayderi (`PUSH_PROVIDER`) hali `mock`: xabar serverda saqlanadi
va shu ro'yxatda ko'rinadi, lekin qurilmaga yetkazilmaydi. FCM ulanganda
kod o'zgarmaydi — tokenlar allaqachon joyida.

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
| Kirish (Telegram bot) | ✅ |
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
