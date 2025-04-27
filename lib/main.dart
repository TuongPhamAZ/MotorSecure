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
import 'package:motor_secure/services/notification_service.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool isLoggedIn = await checkLoginStatus();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkLoginStatus() async {
  UserModel? loggedUser = await PrefService.loadUserData();
  if (loggedUser == null) {
    return false;
  }

  String password = await PrefService.getPassword();
  final AuthenticationService _auth = AuthenticationService();
  UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
      loggedUser.email, password, AuthResult());

  if (userCredential != null) {
    SessionController.getInstance().loadUser(loggedUser);
    return true;
  }

  return false;
}

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
