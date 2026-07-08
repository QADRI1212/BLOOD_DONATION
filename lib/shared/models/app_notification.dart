// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String body,
    @Default('general') String type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'related_id') String? relatedId,
    @JsonKey(name: 'related_type') String? relatedType,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  bool get isEmergency => type == 'emergency';
  bool get isReminder => type == 'reminder';
  bool get isAnnouncement => type == 'announcement';
}
