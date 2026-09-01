# AI uchun qo'llanma — bu loyihani noldan avtonom davom ettirish

Bu fayl **sizga (AI agentga)** yozilgan. Maqsad: foydalanuvchidan qayta-
qayta so'ramasdan, Figma va backend API'ga o'zingiz ulanib, `bron_mobile`
loyihasini davom ettirish. Boshlashdan oldin shu faylni to'liq o'qing.

## 0. Loyiha nima

`bron_mobile` — Flutter loyihasi, **ikkita mustaqil ilova** bitta repoda:

- **Mijoz** (mehmon) — `lib/main.dart`, `flutter run -t lib/main.dart`
- **Xostes** (restoran xodimi) — `lib/main_staff.dart`,
  `flutter run -t lib/main_staff.dart`

Ikkalasi ham bitta backendga (`https://34-0-250-111.sslip.io`) ulanadi,
lekin sessiya/token/local storage butunlay alohida (`AppSession` vs
`StaffSession`).

## 1. Avval shularni o'qing (shu tartibda)

1. `lib/prompt/bajarilgan-ishlar.md` — nima qilingan, qanday buglar
   topilib tuzatilgan, nega ba'zi qarorlar shunday qabul qilingan
   (to'liq tarix).
2. `lib/prompt/api-integratsiya.md` — qaysi 49 ta endpoint allaqachon
   ulangan (qayta qilmang).
3. `lib/prompt/qolgan-ishlar.md` — nima qolgan, nima bloklangan.
4. `lib/prompt/00-boshlash.md` — loyihaning asl texnik topshirig'i.
5. `lib/prompt/mijoz.zip` va `xostes.zip` — har ekran uchun aniq JSON
   namunali API-hujjatlar. **Bular zip fayl** — avval oching:
   ```bash
   mkdir -p /tmp/prompt_docs && cd /tmp/prompt_docs
   unzip -o "path/to/lib/prompt/mijoz.zip" -d mijoz
   unzip -o "path/to/lib/prompt/xostes.zip" -d xostes
   ```
   **Diqqat**: bu statik hujjatlar ba'zan **eskirgan** — jonli backend
   ular yozilgandan keyin o'zgargan (masalan sharhlar API'si hujjatda
   "yo'q" deyilgan, aslida bor edi). **Har doim jonli OpenAPI'ni
   tekshiring (2-bo'lim), ziddiyat bo'lsa jonli backend haq.**

## 2. Backend API'ga qanday ulanish

- Baza: `https://34-0-250-111.sslip.io`
- Swagger UI (odam uchun): `https://34-0-250-111.sslip.io/docs#/`
- **Har ishni boshlashdan oldin jonli sxemani o'zingiz tekshiring**
  (statik hujjatga ishonmang):
  ```bash
  curl -s https://34-0-250-111.sslip.io/openapi.json -o /tmp/openapi_full.json
  curl -s https://34-0-250-111.sslip.io/openapi/client.json -o /tmp/openapi_client.json
  curl -s https://34-0-250-111.sslip.io/openapi/staff.json -o /tmp/openapi_staff.json
  ```
  Node.js bilan qulay o'qish uchun (Windows'da `/tmp` Git Bash yo'li,
  Node'ga Windows yo'lini bering — masalan
  `C:/Users/<user>/AppData/Local/Temp/openapi_full.json`):
  ```js
  const d = require('C:/Users/.../AppData/Local/Temp/openapi_full.json');
  console.log(Object.keys(d.paths)); // barcha yo'llar
  console.log(d.components.schemas.ReviewCreate); // aniq sxema
  ```
- Xato kontrakti: har doim `{code, detail}` — `NetworkException`da
  `code`/`body` maydonlari bor, shu bilan branch qiling (masalan
  `no_table_available`, `card_required`, `invalid_transition`).
- Xostes yozuv amallariga (`arrive/late/no-show/cancel/tables/time`,
  navbat 4 tasi) `Idempotency-Key` sarlavhasi majburiy — `uuid`
  paketi bilan generatsiya qilinadi, qayta urinishda saqlanadi.
- `ApiEndpoints` (`lib/core/constants/api_endpoints.dart`) — barcha
  ulangan yo'llar shu yerda. Yangi endpoint qo'shsangiz shu faylga
  qo'shing, boshqa joyda xom URL yozmang.

## 3. Figma'ga qanday ulanish

Figma MCP server allaqachon ulangan (`mcp__plugin_figma_figma__*`
vositalar). Foydalanuvchi hisobi (`nurmuxammadzoyidov@gmail.com`) shu
fayl uchun **edit access**ga ega:

- **Fayl kaliti**: `i8FGYLF28h8GYXQgd1Pczf`
  (`https://www.figma.com/design/i8FGYLF28h8GYXQgd1Pczf/...`)
- **Mijoz canvasi**: node `0:1` — nomi "✦ ・Mijoz mobil", 57 ta
  ekranning barchasi shu bitta canvasda (bo'limlar: `1 · ONBOARDING`,
  `2 · BRON QILISH`, `3 · BRONLARIM`, `4 · QIDIRUV`, `5 · PROFIL`,
  `6 · HOLATLAR` — yuklanmoqda/bo'sh/xato holatlari shu yerda).
- **Xostes canvasi**: hali topilmagan/ochilmagan. `get_metadata`ni
  `fileKey` bilan, **nodeId'siz** chaqirsangiz faqat "Cover" (89:2)
  sahifasini ko'rsatadi — bu **ishonchsiz/to'liq emas** (quyidagi
  ogohlantirishga qarang). Xostes canvasini topish uchun: foydalanuvchi
  Figma'da "Xostes mobil" sahifasini ochib, uning URL'idagi
  `node-id=X-Y`ni sizga bersin, keyin `X:Y` ko'rinishida
  `get_metadata`/`get_design_context`ga bering.

### Muhim ogohlantirish — `get_metadata` bugi

`get_metadata(fileKey)` (nodeId'siz) faylning **barcha** sahifalarini
ko'rsatishi kerak, lekin bu loyihada faqat "Cover"ni qaytardi —
garchi "Mijoz mobil" canvasi (`0:1`) haqiqatda mavjud va to'liq
kontentga ega bo'lsa ham. **Yechim**: agar foydalanuvchi biror Figma
URL bersa va u yerda `node-id=X-Y` bo'lsa, **to'g'ridan-to'g'ri o'sha
node-id bilan** `get_metadata`/`get_design_context` chaqiring — sahifa
ro'yxatiga ishonmang, u yolg'on-bo'sh natija berishi mumkin.

### Ekranni kodga aylantirish tartibi

1. **MAJBURIY**: `Skill({skill: "figma-design-to-code"})` chaqiring —
   `get_design_context`dan oldin shart, aks holda tool xato beradi.
2. `mcp__plugin_figma_figma__get_metadata(fileKey, nodeId)` — ekran
   tuzilishini (frame nomlari, o'lchamlar) ko'rish uchun, ekranni
   topgach.
3. `mcp__plugin_figma_figma__get_design_context(fileKey, nodeId,
   clientFrameworks: "flutter", clientLanguages: "dart", skillNames:
   "figma-design-to-code")` — React+Tailwind **referens** kodi +
   skrinshot + rang/shrift token'lari qaytadi. Buni **so'zma-so'z
   nusxalamang** — Flutter'ga, loyihaning mavjud pattern'lariga
   (4-bo'limga qarang) moslab yozing.
4. Ikonkalar/rasmlar uchun `mcp__plugin_figma_figma__download_assets`
   — lekin **avval** `assets/icons/`ni tekshiring, ehtimol kerakli
   ikonka allaqachon bor (5-bo'limga qarang).

### Dizayn tizimi haqida allaqachon ma'lum bo'lganlar

- Ikonkalar **Remix Icon** kutubxonasidan (`remixicon` npm paketi,
  MIT litsenziya, `search-2-line`, `arrow-right-s-line` kabi nomlar).
  Yangi ikonka kerak bo'lsa, avval Figma'dan aniq nomini toping, keyin
  ochiq manbadan yuklab oling (Figma eksportidan ustunroq — toza,
  `currentColor` bilan, tinting'ga qulay):
  ```bash
  curl -s -o assets/icons/<nom>.svg \
    "https://cdn.jsdelivr.net/npm/remixicon@4.9.1/icons/<Kategoriya>/<nom>.svg"
  ```
  Kategoriya nomini bilmasangiz avval to'liq ro'yxatni oling:
  `https://unpkg.com/remixicon@4.9.1/icons/?meta` (JSON, har bir
  faylning to'liq yo'lini beradi).
- Ranglar: fon `#f7f7f7` (`bg/weak-50`), skelet/kulrang `#ebebeb`
  (`bg/soft-200`), asosiy brend rangi to'q to'q-qizil/apelsin
  (`AppColors.primary`, taxminan `#DC3009`/`#FB4B23`).
- Shriftlar: sarlavha `GoogleFonts.unbounded`, matn
  `GoogleFonts.plusJakartaSans`.

## 4. Kod yozish konvensiyalari (bularni buzmang)

- **Tarmoq**: dio/http YO'Q. Xom `dart:io HttpClient`
  (`lib/core/network/api_client.dart` — `StandardApiClient`).
  `ApiResult<T>` (`Success`/`Failure` sealed klass) har bir repository
  metodidan qaytadi.
- **State-management paketi YO'Q** — oddiy `StatefulWidget` + `setState`.
- **Qatlamlar**: `entity` → `model` (`fromJson`, qo'lda) → `datasource`
  (xom `apiClient.get/post/patch/delete` chaqiruvi) → `repository`
  (`ApiResult<T>` qaytaradi, try/catch bilan `NetworkException`ga
  o'raydi) → `screen` (repository konstruktorga inject qilinadi,
  `initState`da `AppSession.apiClient`/`StaffSession.apiClient` bilan
  default yaratiladi).
- **HECH QACHON** ekran ichida yangi `StandardApiClient()` yaratmang —
  bu token yo'qolishiga olib keladi (avval haqiqiy bug bo'lgan). Har
  doim `AppSession.apiClient` (mijoz) yoki `StaffSession.apiClient`
  (xostes) ishlatiladi.
- **Ikonkalar**: `Icon(Icons.x)` EMAS — `AppIcon(AppAssets.iconX)`
  ishlatiladi (`lib/core/widgets/app_icon.dart`,
  `lib/core/constants/app_assets.dart`). Xuddi shu `size`/`color`
  parametrlar bilan ishlaydi.
- **Yuklanish holati**: xom `CircularProgressIndicator` EMAS —
  `lib/core/widgets/shimmer_skeleton.dart`dagi `VenueListSkeleton`
  (kartochka-ro'yxat), `ListRowSkeletonGroup` (oddiy ro'yxat),
  `DetailScreenSkeleton` (tafsilot ekrani) ishlatiladi. Mos kelmasa,
  shu fayldagi `ShimmerBox`/`AppShimmer` bilan yangisini yozing —
  ranglar avtomatik to'g'ri (`#ebebeb`/`#f7f7f7`).
- `flutter_screenutil` (`.w`/`.h`/`.r`/`.sp`), `gap` paketi
  (`Gap(16.h)`), matnlar to'g'ridan-to'g'ri o'zbekcha literal (
  `AppStrings.tr()` tizimi bor, lekin aksariyat ekran undan
  foydalanmaydi — mavjud konvensiyaga ergashing).

## 5. Ish boshlashdan oldin — 3 ta tekshiruv

1. `flutter analyze` ishga tushiring — hozir **0 xato** (faqat ~15 ta
   kichik lint-info). Har o'zgarishdan keyin qayta tekshiring.
2. Yangi ekran/funksiya qo'shishdan oldin `lib/prompt/
   api-integratsiya.md`ni qarang — kerakli endpoint allaqachon
   `ApiEndpoints`da bormi, tekshiring.
3. Ikonka kerak bo'lsa avval `assets/icons/`, `assets/icons/
   main_icons/`, `assets/icons/nav_icons/`ni ko'ring — ehtimol
   kerakli glif allaqachon bor.

## 6. Nima bilan boshlash kerak (ustuvorlik)

`lib/prompt/qolgan-ishlar.md`dagi ro'yxatga qarang. Eng katta blok —
**Telegram bot** (mijoz ilovasiga umuman kirib bo'lmaydi, bot
username + domen kerak, bu sizning ixtiyoringizda emas — foydalanuvchi
bilan aniqlashtiring). Undan keyingi eng foydali ish — Xostes
canvasini Figma'da topib (yuqoridagi 3-bo'lim), Xostes ekranlarini
Mijoz kabi piksel darajasida solishtirib chiqish.

## 7. Ishni tugatgach

`lib/prompt/bajarilgan-ishlar.md`ga yangi bo'lim qo'shing (nima
qilindi, qanday bug topildi/tuzatildi, nega shunday qaror qabul
qilindi) — keyingi AI/odam shu yozuvdan foydalanadi. Yangi endpoint
ulasangiz `api-integratsiya.md`ni, ochiq ish tugatsangiz
`qolgan-ishlar.md`ni yangilang.
