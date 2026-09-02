import '../../domain/entities/notification_item_entity.dart';

class NotificationItemModel extends NotificationItemEntity {
  const NotificationItemModel({
    required super.id,
    required super.type,
    required super.channel,
    required super.payload,
    super.sentAt,
    super.readAt,
    required super.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      channel: json['channel'] as String? ?? 'push',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : const {},
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at'] as String) : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class NotificationListResponse {
  final List<NotificationItemModel> items;
  final int total;

  const NotificationListResponse({required this.items, required this.total});

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      items: (json['items'] as List? ?? [])
          .map((item) => NotificationItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}
