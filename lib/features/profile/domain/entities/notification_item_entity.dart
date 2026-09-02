enum NotificationType {
  booking,
  bonus,
  promo,
  system,
}

class NotificationItemEntity {
  final String id;
  final String type;
  final String channel;
  final Map<String, dynamic> payload;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationItemEntity({
    required this.id,
    required this.type,
    required this.channel,
    required this.payload,
    this.sentAt,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  String get title => payload['title'] as String? ?? '';
  String get message => payload['message'] as String? ?? payload['body'] as String? ?? '';

  NotificationType get notificationType {
    switch (type) {
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'booking_reminder':
      case 'booking':
        return NotificationType.booking;
      case 'bonus':
      case 'cashback':
        return NotificationType.bonus;
      case 'promo':
      case 'promotion':
        return NotificationType.promo;
      default:
        return NotificationType.system;
    }
  }
}
