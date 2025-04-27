import 'package:motor_secure/data/models/notification_model.dart';
import 'package:motor_secure/data/repositories/notification_repository.dart';
import 'package:motor_secure/services/notification_service.dart';
import 'package:motor_secure/singleton/user_singleton.dart';

class NotificationManager {
  final NotificationRepository _repository = NotificationRepository();

  Future<void> sendEmergencyNotification({
    required String title,
    required String content,
    required List<String> tokens,
    String? userId,
  }) async {
    try {
      // Lấy userId từ người dùng hiện tại nếu không được cung cấp
      final String actualUserId =
          userId ?? UserSingleton.getInstance().currentUser?.id ?? '';

      print("Tạo thông báo với userId: $actualUserId");

      final notification = NotificationModel.create(
        title: title,
        content: content,
        userId: actualUserId,
      );

      await _repository.addNotification(notification);

      await NotificationService.sendHighPriorityNotificationToTokens(
        tokens,
        title: title,
        body: content,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    return await _repository.getAllNotifications();
  }

  Future<List<NotificationModel>> getNotificationsByUserId(
      String userId) async {
    return await _repository.getNotificationsByUserId(userId);
  }

  Future<NotificationModel?> getNotificationById(String id) async {
    return await _repository.getNotificationById(id);
  }

  Future<bool> deleteNotification(String id) async {
    return await _repository.deleteNotification(id);
  }

  Future<bool> updateNotification(NotificationModel notification) async {
    return await _repository.updateNotification(notification);
  }
}
