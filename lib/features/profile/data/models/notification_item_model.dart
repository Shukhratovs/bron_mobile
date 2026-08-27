import '../../domain/entities/notification_item_entity.dart';

class NotificationItemModel extends NotificationItemEntity {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required super.message,
    required super.time,
    required super.type,
    super.isRead,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      time: json['time'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time,
      'type': type.name,
      'is_read': isRead,
    };
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'booking':
        return NotificationType.booking;
      case 'bonus':
        return NotificationType.bonus;
      case 'promo':
        return NotificationType.promo;
      default:
        return NotificationType.system;
    }
  }
}
