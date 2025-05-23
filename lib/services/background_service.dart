import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/models/vehicle_model.dart';
import 'package:motor_secure/firebase_options.dart';
import 'package:motor_secure/services/notification_manager.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:motor_secure/services/vehicle_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dịch vụ chạy nền để theo dõi trạng thái xe
class BackgroundService {
  static const String _notificationChannelId = 'motor_secure_channel';
  static const int _notificationId = 888;

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Yêu cầu quyền vô hiệu hóa tối ưu hóa pin
    await _requestBatteryOptimizationPermission();

    // Thiết lập kênh thông báo cho thông báo foreground service
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      'Motor Secure Service',
      description: 'Dịch vụ giám sát xe máy của bạn',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Cấu hình dịch vụ nền
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: false,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Motor Secure đang chạy',
        initialNotificationContent: 'Đang giám sát phương tiện của bạn...',
        foregroundServiceNotificationId: _notificationId,
        autoStartOnBoot: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// Yêu cầu người dùng vô hiệu hóa tối ưu hóa pin cho ứng dụng
  static Future<void> _requestBatteryOptimizationPermission() async {
    if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  /// Bắt đầu dịch vụ nền
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  /// Dừng dịch vụ nền
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  /// Kiểm tra dịch vụ có đang chạy không
  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  /// Hàm này chạy trong foreground service trên iOS
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    return true;
  }

  /// Hàm này chạy trong background service
  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    // Khởi tạo DartPluginRegistrant để đảm bảo plugin hoạt động trong isolate
    DartPluginRegistrant.ensureInitialized();

    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (service is AndroidServiceInstance) {
      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // Đảm bảo dịch vụ chạy ở chế độ nền kể cả khi ứng dụng đóng
      await service.setAsForegroundService();
    }

    // Đường dẫn đến notification icon trong thư mục drawable
    const String notificationIconName = 'ic_bg_service_small';

    // Map lưu trạng thái khẩn cấp đã xử lý
    final Map<String, bool> emergencyHandled = {};

    // Khởi tạo service
    final vehicleService = VehicleService();
    final notificationManager = NotificationManager();

    // Cơ chế kiểm tra và khởi động lại định kỳ
    bool isServiceRunning = true;

    // Interval cập nhật thông báo (mỗi 15 giây)
    const updateInterval = Duration(seconds: 15);

    // Trình kiểm tra kết nối và tự khởi động lại sau 1 phút nếu kết nối bị mất
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!isServiceRunning) {
        // Khởi tạo lại Firebase nếu cần
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          isServiceRunning = true;
          print("Đã khởi động lại kết nối Firebase");
        } catch (e) {
          print("Lỗi khởi động lại kết nối: $e");
        }
      }
    });

    // Cập nhật thông báo foreground mỗi 15 giây
    Timer.periodic(updateInterval, (timer) async {
      try {
        if (service is AndroidServiceInstance) {
          // Cập nhật notification
          await service.setForegroundNotificationInfo(
            title: "Motor Secure đang giám sát",
            content:
                "Đang giám sát vào lúc ${DateTime.now().hour}:${DateTime.now().minute}",
          );
        }

        // Tải dữ liệu người dùng từ SharedPreferences
        UserModel? userData = await PrefService.loadUserData();

        if (userData != null && userData.vehicleId.isNotEmpty) {
          // Tạo stream lắng nghe thay đổi dữ liệu vehicle
          final vehicleIds = userData.vehicleId;

          // Lấy dữ liệu vehicle hiện tại
          vehicleService.getVehiclesStreamByIds(vehicleIds).listen((vehicles) {
            // Kiểm tra từng xe
            for (var vehicle in vehicles) {
              _checkEmergencyStatus(
                vehicle,
                emergencyHandled,
                userData,
                notificationManager,
                service,
              );
            }
          }, onError: (error) {
            print("Lỗi khi lắng nghe dữ liệu xe: $error");
            isServiceRunning = false; // đánh dấu để khởi động lại kết nối
          });
        }
      } catch (e) {
        print("Lỗi trong Timer kiểm tra: $e");
        isServiceRunning = false; // đánh dấu để khởi động lại kết nối
      }
    });

    // Ghi nhận thông tin khởi động dịch vụ
    print("Dịch vụ chạy nền Motor Secure đã được khởi động");
  }

  /// Kiểm tra trạng thái khẩn cấp của xe và gửi thông báo nếu cần
  static Future<void> _checkEmergencyStatus(
    VehicleModel vehicle,
    Map<String, bool> emergencyHandled,
    UserModel userData,
    NotificationManager notificationManager,
    ServiceInstance service,
  ) async {
    final String vehicleId = vehicle.vehicleId;
    final bool hasEmergency = vehicle.isAccident || vehicle.isStole;

    // Nếu không có tình trạng khẩn cấp, hoặc đã xử lý rồi, thì bỏ qua
    if (!hasEmergency || emergencyHandled[vehicleId] == true) {
      return;
    }

    // Đánh dấu là đã xử lý để tránh gửi thông báo nhiều lần
    emergencyHandled[vehicleId] = true;

    // Xác định loại khẩn cấp
    String emergencyType = "";
    if (vehicle.isAccident && vehicle.isStole) {
      emergencyType = "TAI NẠN VÀ TRỘM CƯỚP";
    } else if (vehicle.isAccident) {
      emergencyType = "TAI NẠN";
    } else if (vehicle.isStole) {
      emergencyType = "TRỘM CƯỚP";
    }

    // Tạo nội dung thông báo
    final String title = "CẢNH BÁO $emergencyType";
    final String content =
        "Phương tiện $vehicleId của bạn gặp $emergencyType tại vị trí ${vehicle.latitude.toStringAsFixed(6)}, ${vehicle.longitude.toStringAsFixed(6)}.";

    try {
      // Gửi thông báo khẩn cấp nếu có token
      if (userData.token.isNotEmpty) {
        await notificationManager.sendEmergencyNotification(
          title: title,
          content: content,
          tokens: userData.token,
          userId: userData.id,
          vehicleId: vehicleId,
        );

        print("Đã gửi thông báo khẩn cấp cho vehicleId: $vehicleId");
      }
    } catch (e) {
      print("Lỗi khi gửi thông báo khẩn cấp: $e");

      // Đặt lại trạng thái để thử lại sau
      emergencyHandled[vehicleId] = false;
    }
  }

  /// Kiểm tra và mở màn hình cài đặt để vô hiệu hóa tối ưu hóa pin
  static Future<void> openBatteryOptimizationSettings() async {
    if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
      // Mở màn hình cài đặt pin
      await AppSettings.openAppSettings();
    }
  }

  /// Mở cài đặt khởi động tự động (cho các thiết bị Xiaomi, Huawei, Samsung...)
  static Future<void> openAutoStartSettings() async {
    // Mở cài đặt ứng dụng
    await AppSettings.openAppSettings();
  }
}
