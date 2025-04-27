import 'package:motor_secure/services/authentication_service.dart';
import 'package:motor_secure/services/background_service.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:motor_secure/singleton/user_singleton.dart';

abstract class LogoutViewContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onLogoutSuccess();
  void onLogoutFailed(String message);
}

class LogoutPresenter {
  final LogoutViewContract _view;
  final AuthenticationService _auth = AuthenticationService();

  LogoutPresenter(this._view);

  Future<void> signOut() async {
    _view.onWaitingProgressBar();

    try {
      // Dừng dịch vụ nền trước khi đăng xuất
      await BackgroundService.stopService();

      // Đăng xuất khỏi tài khoản Firebase
      await _auth.signOut();

      // Xóa dữ liệu người dùng lưu trữ cục bộ
      await PrefService.clearUserData();

      // Xóa dữ liệu người dùng trong singleton
      await UserSingleton.getInstance().signOut();

      _view.onPopContext();
      _view.onLogoutSuccess();
    } catch (e) {
      _view.onPopContext();
      _view.onLogoutFailed("Đăng xuất thất bại: ${e.toString()}");
    }
  }
}
