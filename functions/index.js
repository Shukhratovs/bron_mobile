const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Deploydan oldin sozlanadi:
//   firebase functions:secrets:set BROADCAST_ADMIN_SECRET
// Ilova tomonida shu qiymat "Barchaga xabar yuborish" formasiga qo'lda
// kiritiladi — kodga yozilmaydi, shuning uchun APK/IPA'ni dekompilyatsiya
// qilib olib bo'lmaydi.
const ADMIN_SECRET = defineSecret("BROADCAST_ADMIN_SECRET");

/**
 * POST /broadcastNotification
 * Headers: x-admin-secret: <BROADCAST_ADMIN_SECRET>
 * Body:    { "title": "...", "body": "..." }
 *
 * `all_devices` topic'iga (mijoz ilovasi PushNotificationService.init()
 * ichida shu topic'ga obuna bo'ladi) push yuboradi — shunday qilib token
 * ro'yxatini saqlash/yig'ish shart bo'lmaydi.
 */
exports.broadcastNotification = onRequest(
  {secrets: [ADMIN_SECRET], region: "us-central1", cors: false},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({success: false, error: "Faqat POST"});
      return;
    }

    const providedSecret = req.get("x-admin-secret");
    if (!providedSecret || providedSecret !== ADMIN_SECRET.value()) {
      res.status(403).json({success: false, error: "Ruxsat yo'q"});
      return;
    }

    const {title, body} = req.body || {};
    if (typeof title !== "string" || !title.trim() || typeof body !== "string" || !body.trim()) {
      res.status(400).json({success: false, error: "title va body majburiy"});
      return;
    }

    try {
      const messageId = await getMessaging().send({
        topic: "all_devices",
        notification: {title: title.trim(), body: body.trim()},
      });
      res.status(200).json({success: true, messageId});
    } catch (err) {
      console.error("broadcastNotification xato:", err);
      res.status(500).json({success: false, error: err.message});
    }
  },
);
