class NotificationEntity {
  String id;
  String title;
  String content;
  DateTime time;
  String userId;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.userId,
  });
}
