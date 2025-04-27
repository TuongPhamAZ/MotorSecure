import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:motor_secure/screens/home/home_view.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static int _notificationId = 0;
  static bool _isRepeatingActive = false;

  // Theo dõi các thông báo khẩn cấp đã gửi để tránh trùng lặp
  static final Map<String, DateTime> _sentEmergencyNotifications = {};

  // Thời gian minimum giữa các thông báo giống nhau (5 phút)
  static const Duration _minimumNotificationInterval = Duration(minutes: 5);

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          _isRepeatingActive = false;
          await cancelAllNotifications();

          // Xử lý payload có chứa vehicleId
          _handleNotificationPayload(response.payload!);
        }
      },
    );

    final AndroidNotificationChannelGroup channelGroup =
        AndroidNotificationChannelGroup(
      'emergency_group',
      'Emergency Notifications',
      description: 'Nhóm thông báo khẩn cấp với âm thanh báo động',
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannelGroup(channelGroup);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Kênh thông báo ưu tiên cao cho cảnh báo khẩn',
      groupId: 'emergency_group',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 0, 0),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final String vehicleId = message.data['vehicleId'] as String? ?? '';

        showHighPriorityNotification(
          title: message.notification!.title ?? 'Cảnh báo khẩn cấp',
          body: message.notification!.body ?? 'Kiểm tra ngay lập tức!',
          payload: vehicleId.isNotEmpty
              ? 'vehicle:$vehicleId'
              : 'notification_payload',
        );
      }
    });
  }

  /// Yêu cầu quyền thông báo
  static Future<void> requestNotificationPermissions() async {
    // Yêu cầu quyền FCM
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  // Xử lý payload từ thông báo
  static void _handleNotificationPayload(String payload) {
    if (payload.startsWith('vehicle:')) {
      // Trích xuất vehicleId
      final String vehicleId = payload.substring(8);

      // Chuyển đến HomeView với vehicleId
      navigatorKey.currentState?.pushNamed(
        HomeView.routeName,
        arguments: {'targetVehicleId': vehicleId},
      );
    } else {
      // Chuyển đến HomeView mà không có arguments cụ thể
      navigatorKey.currentState?.pushNamed(HomeView.routeName);
    }
  }

  static Future<void> showHighPriorityNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final Int64List vibrationPattern =
        Int64List.fromList([0, 500, 1000, 500, 1000, 500]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // id kênh
      'High Importance Notifications', // tên kênh
      channelDescription: 'Kênh thông báo ưu tiên cao cho cảnh báo khẩn',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      ticker: 'ticker',
      autoCancel: false,
      ongoing: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      color: const Color.fromARGB(255, 255, 0, 0),
      colorized: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    _notificationId++;

    await _notificationsPlugin.show(
      _notificationId,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<bool> sendHighPriorityNotificationToTokens(
    List<String> tokens, {
    required String title,
    required String body,
    String? vehicleId,
  }) async {
    // Tạo notificationKey để theo dõi thông báo đã gửi
    final String notificationKey = '$title:$body:${vehicleId ?? ""}';

    // Kiểm tra xem thông báo tương tự đã gửi gần đây chưa
    final lastSentTime = _sentEmergencyNotifications[notificationKey];
    final now = DateTime.now();

    if (lastSentTime != null &&
        now.difference(lastSentTime) < _minimumNotificationInterval) {
      print('Bỏ qua thông báo trùng lặp: $notificationKey');
      return false; // Bỏ qua thông báo trùng lặp gửi quá sớm
    }

    // Ghi nhận thời gian gửi thông báo
    _sentEmergencyNotifications[notificationKey] = now;

    // Giới hạn kích thước của Map theo dõi để tránh tràn bộ nhớ
    if (_sentEmergencyNotifications.length > 100) {
      // Xóa các mục cũ nhất
      final entries = _sentEmergencyNotifications.entries.toList();
      entries.sort((a, b) => a.value.compareTo(b.value));
      final oldestKeys = entries
          .take(_sentEmergencyNotifications.length - 50)
          .map((e) => e.key)
          .toList();

      for (var key in oldestKeys) {
        _sentEmergencyNotifications.remove(key);
      }
    }

    _isRepeatingActive = true;

    final String payload =
        vehicleId != null ? 'vehicle:$vehicleId' : 'notification_payload';

    await showHighPriorityNotification(
      title: title,
      body: body,
      payload: payload,
    );

    _startRepeatingSound(title, body, payload);

    return true;
  }

  static void _startRepeatingSound(
      String title, String body, String payload) async {
    if (!_isRepeatingActive) return;

    await Future.delayed(const Duration(seconds: 5));

    if (_isRepeatingActive) {
      final activeNotifications = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();

      if (activeNotifications != null && activeNotifications.isNotEmpty) {
        await showHighPriorityNotification(
          title: title,
          body: body,
          payload: payload,
        );

        _startRepeatingSound(title, body, payload);
      } else {
        _isRepeatingActive = false;
      }
    }
  }
}
