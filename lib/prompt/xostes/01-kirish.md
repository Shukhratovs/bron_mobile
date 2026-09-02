# Xostes ilovasi — kirish oqimi

Xostes mobil ilovasini quruvchi dasturchi uchun. Ilova **ikki o'lchamda**
ishlaydi: telefon (402×874) va **planshet** (1194×834) — ish joyidagi stend.
API ikkalasi uchun bir xil.

| | |
|---|---|
| Swagger | `/docs/staff` |
| OpenAPI | `/openapi/staff.json` |
| Prefiks | `/api/v1/staff/*` |
| Prod | `https://34-0-250-111.sslip.io` |

Veb admin ham shu API'dan foydalanadi (`docs/frontend/veb-admin/01-integratsiya.md`) —
auth va scope qoidalari umumiy, lekin ekranlar boshqa.

---

## 1. SMS yo'q — Telegram bor

Figmada kirish ekrani telefon + SMS kod bilan chizilgan. **SMS gateway hali
yo'q**, shuning uchun kirish Telegram boti orqali ishlaydi.

Bu vaqtinchalik protez emas: bot `request_contact` tugmasi orqali
**tasdiqlangan** raqamni qaytaradi — SMS kabi ishonchli. SMS ulanganda
ikkinchi kanal bo'lib qo'shiladi, hozirgi oqim buzilmaydi.

Ya'ni Figmadagi **"SMS tasdiqlash" ekrani hozircha chizilmaydi**. Uning
o'rniga "Telegram orqali kirish" tugmasi va kutish holati.

## 2. Oqim — uch qadam

```
1. POST /staff/auth/telegram/start
      → { nonce, deep_link, expires_in, poll_after_seconds }

2. deep_link ni oching (Telegram ilovasi ochiladi)
      → xodim "Raqamni yuborish" tugmasini bosadi

3. GET /staff/auth/telegram/status/{nonce}   ← har 2 soniyada so'rang
      → 202  hali kutilmoqda
      → 200  sessiya tokeni
      → 404  raqam topilmadi yoki urinish eskirgan
```

### 2.1. Boshlash

`POST /api/v1/staff/auth/telegram/start` — **tana yo'q, token kerak emas**.

```json
{
  "nonce": "kZ8s...",
  "deep_link": "https://t.me/bron_staff_bot?start=kZ8s...",
  "expires_in": 300,
  "poll_after_seconds": 2
}
```

`deep_link` ni tashqi havola sifatida oching (iOS: `UIApplication.open`,
Android: `Intent.ACTION_VIEW`). Telegram o'rnatilmagan bo'lsa brauzerda
ochiladi va u yerda ham ishlaydi.

`expires_in: 300` — 5 daqiqa. Shundan keyin qaytadan `start` chaqiring.

### 2.2. Polling

To'liq yo'l: `GET /api/v1/staff/auth/telegram/status/{nonce}`.

> `start` — POST, holat esa GET. Ikkalasi turli yo'lda, shuning uchun
> brauzerda `/telegram/start` ni ochsangiz hech narsa ishlamaydi.

| Status | Tana | Nima qilish |
|---|---|---|
| `202` | `{"status":"pending","detail":"..."}` | 2 soniyadan keyin qayta so'rang |
| `200` | `StaffTokenOut` | Sessiyani saqlang, asosiy ekranga o'ting |
| `404` `staff_not_found` | | **"Bu raqam tizimda topilmadi"** ekrani |
| `404` `login_expired` | | Qaytadan `start` dan boshlang |

`200` javobi:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 86400,
  "role": "xostes",
  "organization_id": "21b1235d-...",
  "venue_id": "dec218a9-..."
}
```

**Token bir marta beriladi** — ikkinchi polling `404 login_expired` qaytaradi.
Birinchi `200` ni oldingizda saqlang.

> Ilova fonga o'tib qaytganda pollingni davom ettiring. Foydalanuvchi
> Telegramda 30 soniya sarflashi mumkin — 5 daqiqalik oyna shuning uchun.

### 2.3. Administratorlar mobil ilovadan kira olmaydi

`org_admin` va `branch_admin` — veb panel rollari. Ular Telegram orqali
**faqat taklifni qabul qilib, email va parol o'rnatgandan keyin** kira
oladi. Aks holda bot tushuntiradi va `status` `404 staff_not_found`
qaytaradi.

Amalda bu kamdan-kam uchraydi: mobil ilova `xostes`, `usta` va
`qabulxona` uchun.

### 2.4. "Raqam topilmadi" holati

Xodim raqamini **administrator qo'shadi** (veb admin panelida). Ro'yxatdan
o'tish yo'q. Shuning uchun `staff_not_found` odatiy holat, xato emas —
Figmadagi `Raqam topilmadi` ekranini ko'rsating:

> Xodim raqami administrator tomonidan tizimga qo'shiladi. Raqamingizni
> tekshiring yoki administratorga murojaat qiling.

## 3. Muassasa tanlash

Bir xodim bir necha filialda ishlashi mumkin. Kirgandan keyin
`GET /api/v1/staff/venues` ro'yxatini oling:

```json
[{ "id": "dec218a9-...", "name": "Osteria Da Vinci", "kind": "restoran",
   "district": "Chilonzor", "status": "faol", "is_primary": true }]
```

Ro'yxatda **bittadan ko'p** bo'lsa — Figmadagi `Qaysi joyda ishlaysiz?`
ekranini ko'rsating. Bitta bo'lsa, o'tkazib yuboring.

Tanlangan filial keyingi har bir so'rovda sarlavhada ketadi:

```
X-Venue-Id: dec218a9-af7b-4c7b-a5fe-1bec10569e14
```

Xostes uchun bu sarlavha aslida majburiy emas (backend baribir uning
filialini biladi), lekin **yuborib turing** — bir necha filialli xodim
uchun to'g'ri kontekst shu bilan aniqlanadi.

## 4. Sessiya

`expires_in: 86400` — 24 soat. Smena tugagach xodim chiqadi yoki token
o'z-o'zidan eskiradi.

| Status | Ma'nosi | Nima qilish |
|---|---|---|
| `401` | Token eskirgan yoki **hisob bloklangan** | Kirish ekraniga qayting |
| `403` | Huquq yo'q (masalan begona filial) | **Kirish ekraniga QAYTMANG** — xato holatini ko'rsating |

Xato formati hamma joyda bir xil: `{ "code": "...", "detail": "..." }`.
`detail` — foydalanuvchiga ko'rsatiladigan o'zbekcha matn.

## 5. Hozircha yo'q narsalar

Kirish oqimi tayyor, **qolgan hamma narsa hali qurilmagan**:

| Ekran | Holat |
|---|---|
| Bugun (bronlar ro'yxati) | Yo'q |
| Zal (stollar) | Yo'q |
| Navbat | Yo'q |
| QR skanerlash | Yo'q |
| Smena yakuni | Yo'q |
| Profil | Qisman — `GET /staff/me` bor |

Ya'ni hozir **kirish + muassasa tanlash + profil** ekranlarini qurish
mumkin. Qolganlari bronlar domeni qurilgach ochiladi.

## 6. Offline rejim — oldindan bilib qo'ying

Dizaynda alohida ekran bor: *"Internet yo'q — offline rejim · 19:04 dagi
holat · **3 o'zgarish yuborilmadi**"*.

Ya'ni xostes internetsiz "mehmon keldi" deb belgilaydi, ilova buni navbatga
qo'yadi va ulanish tiklanganda yuboradi.

Backend tomonda buning uchun **idempotentlik kalitlari** bo'ladi: har bir
yozuv so'roviga ilova o'zi hosil qilgan `Idempotency-Key` (UUID) qo'shadi,
va qayta yuborilganda server o'sha natijani qaytaradi — bitta bron ikki
marta belgilanmaydi.

Bu hali yozilmagan, lekin **ilova arxitekturasini shunga tayyorlang**:
har bir offline amalga yaratilish paytida UUID bering va qayta yuborishda
**o'sha UUID ni saqlang**, yangisini hosil qilmang.

## 7. Ishni qayerdan boshlash

1. `POST /staff/auth/telegram/start` + deep-link ochish
2. Polling (2 soniya, 5 daqiqa oynasi, fon/oldinga o'tishni hisobga olib)
3. `Raqam topilmadi` ekrani
4. `GET /staff/venues` → `Qaysi joyda ishlaysiz?` (agar bittadan ko'p bo'lsa)
5. Token saqlash + `401` interceptor
6. Offline navbat skeleti (UUID kalitlari bilan) — hozirdan
