/// Mijoz ilovasi Telegram Login Widget sozlamalari
/// (mijoz/00-kirish-va-profil.md §1, `POST /api/v1/auth/telegram`).
///
/// 2026-08-31: tasdiqlandi — Xostes va Mijoz **bitta botni** ishlatadi
/// (`bron_staff_bot`). Xostesda bot chat/deep-link rejimida
/// (`/start` + `request_contact`), Mijozda esa xuddi shu botning
/// **Login Widget** rejimida ishlatiladi — bittasi ikkalasiga ham
/// @BotFather orqali sozlanishi mumkin.
///
/// **Hali noaniq** — `widgetOriginUrl`: bu bot uchun @BotFather'da
/// `/setdomain` bilan qaysi domen ro'yxatdan o'tkazilgani hali
/// tasdiqlanmagan (Telegram widget domenni tekshiradi, mos kelmasa
/// kirish ishlamaydi). Hozircha ma'lum bo'lgan yagona domen —
/// backend serveri — qo'yilgan; agar kirishda "domain invalid" kabi
/// xato chiqsa, shu qiymatni to'g'ri domenga almashtiring.
///
/// Jonli serverning OpenAPI sxemasi (`/openapi/client.json`,
/// 2026-08-31 tekshirilgan) `TelegramAuthIn`da `id`dan boshqa hamma
/// maydonni (`hash`, `auth_date`, `phone` shu jumladan) ixtiyoriy deb
/// belgilagan, lekin amalda `hash` bo'lmasa `401 telegram_hash_missing`
/// qaytaradi — ya'ni haqiqiy, Telegram imzolagan javob shart.
class TelegramConfig {
  TelegramConfig._();

  /// 2026-08-31: `bron_staff_bot` sinaldi — Telegramning o'zi
  /// (`oauth.telegram.org/embed/bron_staff_bot`) "Username invalid"
  /// qaytargan (haqiqiy `@BotFather`/boshqa botlar esa "Bot domain
  /// invalid" qaytaradi — farqli xato, botning oʻzi widget tizimida
  /// koʻrinmayotganini bildiradi). Keyin bot butunlay oʻchirildi.
  /// Yangi/tuzatilgan bot tayyor boʻlgach shu yerga yozing.
  static const String botUsername = '';

  /// Widget yuklanadigan sahifaning "asosiy URL"i — WebView shu domenni
  /// sahifa manzili deb hisoblaydi (`webview_flutter`ning
  /// `loadHtmlString(..., baseUrl: ...)` parametri). Botga @BotFather
  /// orqali ro'yxatdan o'tkazilgan domen bilan bir xil bo'lishi shart —
  /// hali tasdiqlanmagan, yuqoridagi izohga qarang.
  static const String widgetOriginUrl = 'https://34-0-250-111.sslip.io';

  static bool get isConfigured => botUsername.isNotEmpty;
}
