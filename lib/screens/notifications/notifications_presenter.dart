import 'package:motor_secure/data/models/notification_model.dart';
import 'package:motor_secure/screens/notifications/notifications_view_contract.dart';
import 'package:motor_secure/services/notification_manager.dart';
import 'package:motor_secure/services/pref_service.dart';

class NotificationsPresenter {
  final NotificationsViewContract _view;
  final NotificationManager _notificationManager = NotificationManager();

  NotificationsPresenter(this._view);

  Future<void> loadNotifications() async {
    try {
      final currentUser = await PrefService.loadUserData();
      List<NotificationModel> notifications = [];

      if (currentUser != null) {
        notifications =
            await _notificationManager.getNotificationsByUserId(currentUser.id);

        if (notifications.isEmpty) {
          final allNotifications =
              await _notificationManager.getAllNotifications();

          if (allNotifications.isNotEmpty) {
            notifications = allNotifications;

            for (var notification in allNotifications) {
              if (notification.userId.isEmpty) {
                final updatedNotification = NotificationModel(
                  id: notification.id,
                  title: notification.title,
                  content: notification.content,
                  time: notification.time,
                  userId: currentUser.id,
                );

                await _notificationManager
                    .updateNotification(updatedNotification);
              }
            }
          }
        }
      }

      notifications.sort((a, b) => b.time.compareTo(a.time));

      _view.onLoadNotificationsSuccess(notifications);
    } catch (e) {
      _view.onLoadNotificationsFailed(
          'Đã xảy ra lỗi khi tải thông báo: ${e.toString()}');
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      final result = await _notificationManager.deleteNotification(id);
      return result;
    } catch (e) {
      return false;
    }
  }
}
