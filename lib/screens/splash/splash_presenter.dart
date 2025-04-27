import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motor_secure/screens/splash/splash_view_contract.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashPresenter {
  final SplashViewContract _view;
  SplashPresenter(this._view);

  Future<void> requestNotificationPermissionOnce() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? askedPermission = prefs.getBool('askedNotificationPermission');

      if (askedPermission != true) {
        // Chưa xin quyền lần nào
        NotificationSettings settings =
            await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('Đã được cấp quyền thông báo');
          _view.onNotificationPermissionGranted();
        } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
          print('Người dùng từ chối quyền thông báo');
          _view.onNotificationPermissionDenied();
        }

        // Ghi nhớ là đã hỏi rồi
        await prefs.setBool('askedNotificationPermission', true);
      } else {
        print('Đã từng xin quyền thông báo, không hỏi lại');
      }
    } catch (e) {
      print('Lỗi khi xin quyền thông báo: $e');
    }
  }

  Future<void> requestLocationPermissionOnce() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? askedPermission = prefs.getBool('askedLocationPermission');

      if (askedPermission != true) {
        // Chưa xin quyền vị trí lần nào
        PermissionStatus status = await Permission.locationWhenInUse.request();

        if (status.isGranted) {
          print('Đã được cấp quyền vị trí');
          _view.onLocationPermissionGranted();
        } else if (status.isDenied) {
          print('Người dùng từ chối quyền vị trí');
          _view.onLocationPermissionDenied();
        } else if (status.isPermanentlyDenied) {
          print('Quyền vị trí bị chặn vĩnh viễn, cần mở trong cài đặt');
          _view.onLocationPermissionDenied();
          // Không tự động mở setting ở đây, có thể hiển thị dialog hướng dẫn sau
        }

        // Ghi nhớ là đã hỏi rồi
        await prefs.setBool('askedLocationPermission', true);
      } else {
        print('Đã từng xin quyền vị trí, không hỏi lại');
      }
    } catch (e) {
      print('Lỗi khi xin quyền vị trí: $e');
    }
  }
}
