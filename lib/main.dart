import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motor_secure/firebase_options.dart';
import 'package:motor_secure/routes.dart';
import 'package:motor_secure/screens/no_internet/dependency_injection.dart';
import 'package:motor_secure/screens/splash/splash_view.dart';
import 'package:motor_secure/controller/session_controller.dart';
import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/screens/home/home_view.dart';
import 'package:motor_secure/services/authentication_service.dart';
import 'package:motor_secure/services/background_service.dart';
import 'package:motor_secure/services/notification_service.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification != null) {
    await NotificationService.showHighPriorityNotification(
      title: message.notification!.title ?? 'Cảnh báo khẩn cấp',
      body: message.notification!.body ?? 'Kiểm tra ngay lập tức!',
      payload: 'notification_payload',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  DependencyInjection.init();
  await NotificationService.initialize();

  // Yêu cầu các quyền cần thiết
  await requestRequiredPermissions();

  // Khởi tạo dịch vụ nền
  await BackgroundService.initialize();

  // Bắt đầu dịch vụ nền nếu người dùng đã đăng nhập
  bool isLoggedIn = await checkLoginStatus();
  if (isLoggedIn) {
    await BackgroundService.startService();

    // Hiển thị hướng dẫn mở cài đặt tối ưu hóa pin nếu cần
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      // Sẽ hiển thị hướng dẫn sau khi ứng dụng khởi động
      _showBatteryOptimizationGuideAfterAppStart = true;
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkLoginStatus() async {
  UserModel? loggedUser = await PrefService.loadUserData();
  if (loggedUser == null) {
    return false;
  }

  User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

  if (currentFirebaseUser == null) {
    return false;
  }

  return true;
}

/// Yêu cầu các quyền cần thiết
Future<void> requestRequiredPermissions() async {
  // Yêu cầu quyền thông báo
  await NotificationService.requestNotificationPermissions();

  // Yêu cầu quyền vị trí
  await Permission.location.request();

  // Yêu cầu quyền vị trí nền (chỉ yêu cầu nếu đã cấp quyền vị trí)
  if (await Permission.location.isGranted) {
    await Permission.locationAlways.request();
  }

  // Yêu cầu quyền vô hiệu hóa tối ưu pin
  if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}

// Biến để kiểm soát hiển thị hướng dẫn sau khi ứng dụng khởi động
bool _showBatteryOptimizationGuideAfterAppStart = false;

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Motor Secure',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      routes: appRoutes,
      home: isLoggedIn ? const HomeView() : const SplashView(),
    );
  }
}
