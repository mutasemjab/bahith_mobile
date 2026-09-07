import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.type,
    super.isRead,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: json['type'],
        isRead: json['is_read'] ?? false,
        createdAt: json['created_at'],
      );
}
