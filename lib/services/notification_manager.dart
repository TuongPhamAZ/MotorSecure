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
    String? vehicleId,
  }) async {
    try {
      // Lấy userId từ người dùng hiện tại nếu không được cung cấp
      final String actualUserId =
          userId ?? UserSingleton.getInstance().currentUser?.id ?? '';

      print("Xử lý thông báo khẩn cấp với userId: $actualUserId");

      // Tìm kiếm thông báo cùng loại gần đây
      // (cùng tiêu đề, nội dung và người dùng trong khoảng thời gian ngắn)
      final recentNotifications =
          await _repository.getRecentEmergencyNotifications(
        userId: actualUserId,
        title: title,
        content: content,
        timeFrame: const Duration(minutes: 10), // Trong khoảng 10 phút
        vehicleId: vehicleId,
      );

      // Chỉ tạo thông báo mới trong database nếu không tìm thấy thông báo tương tự gần đây
      if (recentNotifications.isEmpty) {
        print("Tạo thông báo mới trong database");
        final notification = NotificationModel.create(
          title: title,
          content: content,
          userId: actualUserId,
        );

        await _repository.addNotification(notification);
      } else {
        print(
            "Đã tìm thấy thông báo tương tự gần đây, bỏ qua việc tạo thông báo mới");
      }

      // Luôn gửi FCM notification để đảm bảo người dùng nhận được cảnh báo
      await NotificationService.sendHighPriorityNotificationToTokens(
        tokens,
        title: title,
        body: content,
        vehicleId: vehicleId,
      );
    } catch (e) {
      print("Lỗi khi gửi thông báo khẩn cấp: ${e.toString()}");
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
