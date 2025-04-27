import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:motor_secure/screens/notifications/notifications_view.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Giữ ID của thông báo hiện tại để theo dõi
  static int _notificationId = 0;
  static bool _isRepeatingActive = false;

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
          navigatorKey.currentState?.pushNamed(NotificationsView.routeName);
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
        showHighPriorityNotification(
          title: message.notification!.title ?? 'Cảnh báo khẩn cấp',
          body: message.notification!.body ?? 'Kiểm tra ngay lập tức!',
          payload: 'notification_payload',
        );
      }
    });
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

  static Future<void> sendHighPriorityNotificationToTokens(
    List<String> tokens, {
    required String title,
    required String body,
  }) async {
    _isRepeatingActive = true;

    await showHighPriorityNotification(
      title: title,
      body: body,
      payload: 'notification_payload',
    );

    _startRepeatingSound(title, body);
  }

  static void _startRepeatingSound(String title, String body) async {
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
          payload: 'notification_payload',
        );

        _startRepeatingSound(title, body);
      } else {
        _isRepeatingActive = false;
      }
    }
  }
}
