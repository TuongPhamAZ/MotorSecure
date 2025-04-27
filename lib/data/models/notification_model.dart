import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_secure/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  static const String collectionName = 'Notifications';

  NotificationModel({
    required super.id,
    required super.title,
    required super.content,
    required super.time,
    required super.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      time: (json['time'] as Timestamp).toDate(),
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'time': time,
      'userId': userId,
    };
  }

  static NotificationModel create({
    required String title,
    required String content,
    required String userId,
  }) {
    final String id =
        FirebaseFirestore.instance.collection(collectionName).doc().id;
    return NotificationModel(
      id: id,
      title: title,
      content: content,
      time: DateTime.now(),
      userId: userId,
    );
  }
}
