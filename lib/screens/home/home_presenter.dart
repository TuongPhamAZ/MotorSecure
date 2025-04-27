import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/screens/home/home_view_contract.dart';
import 'package:motor_secure/services/notification_manager.dart';
import 'package:motor_secure/services/pref_service.dart';

class HomePresenter {
  final HomeViewContract _view;
  final NotificationManager _notificationManager = NotificationManager();

  HomePresenter(this._view);

  Future<void> loadUserTokenCount() async {
    try {
      UserModel? userData = await PrefService.loadUserData();

      if (userData != null) {
        int tokenCount = userData.token.length;
        _view.onLoadUserDataSucceeded(tokenCount);
      } else {
        _view.onLoadUserDataFailed("Không tìm thấy dữ liệu người dùng");
      }
    } catch (e) {
      _view.onLoadUserDataFailed("Đã xảy ra lỗi: ${e.toString()}");
    }
  }

  Future<void> sendEmergencyNotification() async {
    try {
      _view.onWaitingProgressBar();

      UserModel? userData = await PrefService.loadUserData();

      if (userData != null && userData.token.isNotEmpty) {
        await _notificationManager.sendEmergencyNotification(
          title: "CẢNH BÁO KHẨN CẤP!",
          content:
              "Phát hiện có bất thường với phương tiện của bạn (trộm). Kiểm tra ngay!",
          tokens: userData.token,
          userId: userData.id,
        );

        _view.onPopContext();
        _view.onSendNotificationSuccess();
      } else {
        _view.onPopContext();
        _view.onSendNotificationFailed("Không tìm thấy FCM token nào");
      }
    } catch (e) {
      _view.onPopContext();
      _view.onSendNotificationFailed("Đã xảy ra lỗi: ${e.toString()}");
    }
  }
}
