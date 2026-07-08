import '../../../shared/models/app_notification.dart';

class NotificationDto {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String? relatedId;
  final String? relatedType;
  final String createdAt;

  const NotificationDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    this.relatedId,
    this.relatedType,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> map) {
    return NotificationDto(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: map['type'] as String? ?? 'general',
      isRead: map['is_read'] as bool? ?? false,
      relatedId: map['related_id'] as String?,
      relatedType: map['related_type'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  AppNotification toDomain() {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead,
      relatedId: relatedId,
      relatedType: relatedType,
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead,
      'related_id': relatedId,
      'related_type': relatedType,
      'created_at': createdAt,
    };
  }
}
