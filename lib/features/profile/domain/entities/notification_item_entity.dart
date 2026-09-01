enum NotificationType {
  booking,
  bonus,
  promo,
  system,
}

class NotificationItemEntity {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isRead;

  const NotificationItemEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}
