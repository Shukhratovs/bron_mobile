class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://34-0-250-111.sslip.io';

  // Health check
  static const String health = '$baseUrl/health';

  // Client Auth
  static const String telegramAuth = '$baseUrl/api/v1/auth/telegram';
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
}
