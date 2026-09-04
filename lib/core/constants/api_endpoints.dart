class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://34-0-250-111.sslip.io';

  // Health check
  static const String health = '$baseUrl/health';

  // Client Auth — Telegram bot (00-boshlash.md, mijoz/00-kirish-va-profil.md)
  static const String telegramAuthStart = '$baseUrl/api/v1/auth/telegram/start';
  static String telegramAuthStatus(String nonce) => '$baseUrl/api/v1/auth/telegram/status/$nonce';
  static const String logout = '$baseUrl/api/v1/auth/logout';

  // Client Profile & Devices
  static const String me = '$baseUrl/api/v1/me';
  static const String devices = '$baseUrl/api/v1/me/devices';

  // Client Cards
  static const String cards = '$baseUrl/api/v1/me/cards';
  static const String cardsConfirm = '$baseUrl/api/v1/me/cards/confirm';
  static String cardById(String cardId) => '$baseUrl/api/v1/me/cards/$cardId';

  // Notifications
  static const String notifications = '$baseUrl/api/v1/me/notifications';
  static String notificationRead(String id) => '$baseUrl/api/v1/me/notifications/$id/read';
  static const String notificationsReadAll = '$baseUrl/api/v1/me/notifications/read';

  // Admin — barcha foydalanuvchilarga push yuborish. Bu maxsus backend
  // emas, Firebase Cloud Function (`functions/index.js`, shu loyihaning
  // "e-bron" Firebase proyektida) — {title, body} qabul qilib,
  // Admin SDK orqali `all_devices` topic'iga yuboradi. `x-admin-secret`
  // header orqali himoyalangan (qiymat ilovaga yozilmaydi, forma orqali
  // qo'lda kiritiladi).
  static const String broadcastNotification =
      'https://us-central1-e-bron.cloudfunctions.net/broadcastNotification';

  // Venues
  static const String venues = '$baseUrl/api/v1/venues';
  static const String venuesMap = '$baseUrl/api/v1/venues/map';
  static String venueById(String venueId) => '$baseUrl/api/v1/venues/$venueId';
  static String venueMenu(String venueId) => '$baseUrl/api/v1/venues/$venueId/menu';
  static String venueAvailability(String venueId) => '$baseUrl/api/v1/venues/$venueId/availability';
  static String venueAvailabilityDays(String venueId) => '$baseUrl/api/v1/venues/$venueId/availability/days';
  static String venueReviews(String venueId) => '$baseUrl/api/v1/venues/$venueId/reviews';

  // Bookings
  static const String bookings = '$baseUrl/api/v1/bookings';
  static String bookingById(String bookingId) => '$baseUrl/api/v1/bookings/$bookingId';
  static String bookingQr(String bookingId) => '$baseUrl/api/v1/bookings/$bookingId/qr';
  static String bookingCancel(String bookingId) => '$baseUrl/api/v1/bookings/$bookingId/cancel';
  static String bookingTime(String bookingId) => '$baseUrl/api/v1/bookings/$bookingId/time';
  static String bookingReview(String bookingId) => '$baseUrl/api/v1/bookings/$bookingId/review';

  // Waitlist
  static const String waitlist = '$baseUrl/api/v1/waitlist';
  static String waitlistConfirm(String entryId) => '$baseUrl/api/v1/waitlist/$entryId/confirm';
  static String waitlistDelete(String entryId) => '$baseUrl/api/v1/waitlist/$entryId';

  // Xostes (staff) — 01-kirish.md
  static const String staffAuthTelegramStart = '$baseUrl/api/v1/staff/auth/telegram/start';
  static String staffAuthTelegramStatus(String nonce) => '$baseUrl/api/v1/staff/auth/telegram/status/$nonce';
  static const String staffVenues = '$baseUrl/api/v1/staff/venues';
  static const String staffMe = '$baseUrl/api/v1/staff/me';
  static const String staffDevices = '$baseUrl/api/v1/staff/devices';

  // Xostes — Bugun, bron detali, QR (02-bugun-va-qr.md)
  static const String staffBookings = '$baseUrl/api/v1/staff/bookings';
  static String staffBookingById(String id) => '$baseUrl/api/v1/staff/bookings/$id';
  static String staffBookingArrive(String id) => '$baseUrl/api/v1/staff/bookings/$id/arrive';
  static String staffBookingLate(String id) => '$baseUrl/api/v1/staff/bookings/$id/late';
  static String staffBookingNoShow(String id) => '$baseUrl/api/v1/staff/bookings/$id/no-show';
  static String staffBookingCancel(String id) => '$baseUrl/api/v1/staff/bookings/$id/cancel';
  static String staffBookingTables(String id) => '$baseUrl/api/v1/staff/bookings/$id/tables';
  static String staffBookingTime(String id) => '$baseUrl/api/v1/staff/bookings/$id/time';
  static const String staffBookingScan = '$baseUrl/api/v1/staff/bookings/scan';
  static const String staffZal = '$baseUrl/api/v1/staff/zal';
  static const String staffZalAvailability = '$baseUrl/api/v1/staff/zal/availability';

  // Xostes — Smena yakuni (04-smena-yakuni.md)
  static const String staffShiftSummary = '$baseUrl/api/v1/staff/shift/summary';

  // Xostes — Navbat (03-navbat.md)
  static const String staffWaitlist = '$baseUrl/api/v1/staff/waitlist';
  static String staffWaitlistCall(String id) => '$baseUrl/api/v1/staff/waitlist/$id/call';
  static String staffWaitlistSeat(String id) => '$baseUrl/api/v1/staff/waitlist/$id/seat';
  static String staffWaitlistDelete(String id) => '$baseUrl/api/v1/staff/waitlist/$id';
}
