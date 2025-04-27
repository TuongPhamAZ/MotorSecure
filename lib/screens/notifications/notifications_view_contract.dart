import 'package:motor_secure/data/models/notification_model.dart';

abstract class NotificationsViewContract {
  void onLoadNotificationsSuccess(List<NotificationModel> notifications);
  void onLoadNotificationsFailed(String message);
  void onWaitingProgressBar();
  void onPopContext();
}
