import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/models/vehicle_model.dart';
import 'package:motor_secure/screens/home/home_view_contract.dart';
import 'package:motor_secure/services/notification_manager.dart';
import 'package:motor_secure/services/notification_service.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:motor_secure/services/vehicle_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class HomePresenter {
  final HomeViewContract _view;
  final NotificationManager _notificationManager = NotificationManager();
  final VehicleService _vehicleService = VehicleService();

  StreamSubscription? _vehiclesSubscription;
  Timer? _locationUpdateTimer;

  // Lưu trữ đường đi cho mỗi vehicle
  final Map<String, List<Map<String, dynamic>>> _pathPointsMap = {};

  // Theo dõi trạng thái khẩn cấp đã xử lý
  final Map<String, bool> _emergencyHandled = {};

  HomePresenter(this._view);

  void dispose() {
    _vehiclesSubscription?.cancel();
    _locationUpdateTimer?.cancel();
  }

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

  Future<void> loadUserVehicles() async {
    try {
      UserModel? userData = await PrefService.loadUserData();

      if (userData != null) {
        List<String> vehicleIds = userData.vehicleId;
        _view.onLoadUserVehiclesSucceeded(vehicleIds);

        // Đăng ký stream để lắng nghe thay đổi dữ liệu về vehicles
        _subscribeToVehiclesUpdates(vehicleIds);

        // Khởi tạo mảng lưu đường đi cho mỗi thiết bị
        for (String id in vehicleIds) {
          if (!_pathPointsMap.containsKey(id)) {
            _pathPointsMap[id] = [];
          }

          // Khởi tạo trạng thái xử lý khẩn cấp
          _emergencyHandled[id] = false;
        }
      } else {
        _view.onLoadUserDataFailed("Không tìm thấy dữ liệu người dùng");
      }
    } catch (e) {
      _view.onLoadUserDataFailed("Đã xảy ra lỗi: ${e.toString()}");
    }
  }

  void _subscribeToVehiclesUpdates(List<String> vehicleIds) {
    // Hủy đăng ký stream cũ nếu có
    _vehiclesSubscription?.cancel();
    _locationUpdateTimer?.cancel();

    if (vehicleIds.isEmpty) {
      return;
    }

    // Đăng ký stream mới
    _vehiclesSubscription =
        _vehicleService.getVehiclesStreamByIds(vehicleIds).listen((vehicles) {
      // Cập nhật đường đi cho mỗi thiết bị
      for (var vehicle in vehicles) {
        _updateVehiclePath(vehicle);

        // Kiểm tra tình trạng khẩn cấp
        _checkEmergencyStatus(vehicle);
      }

      // Gửi dữ liệu vehicles và đường đi về view
      _view.onVehiclesDataUpdated(vehicles);
      _view.onPathsUpdated(_pathPointsMap);
    }, onError: (error) {
      _view.onLoadUserDataFailed(
          "Lỗi khi cập nhật dữ liệu: ${error.toString()}");
    });
  }

  // Cập nhật đường đi cho một vehicle
  void _updateVehiclePath(VehicleModel vehicle) {
    final String vehicleId = vehicle.vehicleId;
    final now = DateTime.now();
    final LatLng newPosition = LatLng(vehicle.latitude, vehicle.longitude);

    // Tạo mảng mới nếu chưa có
    if (!_pathPointsMap.containsKey(vehicleId)) {
      _pathPointsMap[vehicleId] = [];
    }

    final List<Map<String, dynamic>> pathPoints = _pathPointsMap[vehicleId]!;

    // Kiểm tra điểm cuối cùng (nếu có) để tránh thêm nhiều điểm trùng nhau
    if (pathPoints.isNotEmpty) {
      final lastPoint = pathPoints.last;
      final LatLng lastPosition = lastPoint['position'] as LatLng;

      // Tính khoảng cách giữa vị trí mới và vị trí cuối cùng
      final double distance = Geolocator.distanceBetween(lastPosition.latitude,
          lastPosition.longitude, newPosition.latitude, newPosition.longitude);

      // Chỉ thêm điểm mới nếu khoảng cách > 3 mét (tránh thêm quá nhiều điểm khi thiết bị đứng yên)
      if (distance <= 3) {
        return;
      }
    }

    // Thêm điểm mới
    pathPoints.add({
      'timestamp': now,
      'position': newPosition,
    });

    // Loại bỏ các điểm cũ hơn 1 giờ
    pathPoints.removeWhere((point) =>
        now.difference(point['timestamp'] as DateTime).inMinutes > 60);

    // Giới hạn số lượng điểm để đảm bảo hiệu suất
    if (pathPoints.length > 500) {
      // Lọc thưa bớt: giữ lại mỗi điểm thứ 2
      List<Map<String, dynamic>> sampledPoints = [];
      for (int i = 0; i < pathPoints.length; i += 2) {
        sampledPoints.add(pathPoints[i]);
      }
      _pathPointsMap[vehicleId] = sampledPoints;
    }
  }

  // Kiểm tra tình trạng khẩn cấp của xe
  void _checkEmergencyStatus(VehicleModel vehicle) async {
    final String vehicleId = vehicle.vehicleId;
    final bool hasEmergency = vehicle.isAccident || vehicle.isStole;

    // Nếu không có tình trạng khẩn cấp, hoặc đã xử lý rồi, thì bỏ qua
    if (!hasEmergency || _emergencyHandled[vehicleId] == true) {
      return;
    }

    // Đánh dấu là đã xử lý để tránh hiển thị thông báo nhiều lần
    _emergencyHandled[vehicleId] = true;

    // Xác định loại khẩn cấp
    String emergencyType = "";
    if (vehicle.isAccident && vehicle.isStole) {
      emergencyType = "TAI NẠN VÀ TRỘM CƯỚP";
    } else if (vehicle.isAccident) {
      emergencyType = "TAI NẠN";
    } else if (vehicle.isStole) {
      emergencyType = "TRỘM CƯỚP";
    }

    // Định dạng thời gian
    final String formattedTime =
        DateFormat('HH:mm:ss dd/MM/yyyy').format(DateTime.now());

    // Tạo nội dung thông báo
    final String title = "CẢNH BÁO $emergencyType";
    final String content =
        "Phương tiện $vehicleId của bạn gặp $emergencyType tại vị trí ${vehicle.latitude.toStringAsFixed(6)}, ${vehicle.longitude.toStringAsFixed(6)} vào lúc $formattedTime.";

    // Lấy dữ liệu người dùng để gửi thông báo
    UserModel? userData = await PrefService.loadUserData();

    if (userData != null && userData.token.isNotEmpty) {
      try {
        // Gửi thông báo khẩn cấp
        await _notificationManager.sendEmergencyNotification(
          title: title,
          content: content,
          tokens: userData.token,
          userId: userData.id,
        );

        // Hiển thị dialog thông báo khẩn cấp trên màn hình
        _view.onShowEmergencyDialog(vehicle, title, content);
      } catch (e) {
        print("Lỗi khi gửi thông báo khẩn cấp: $e");
      }
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

  // Làm sạch đường đi của một thiết bị
  void clearVehiclePath(String vehicleId) {
    if (_pathPointsMap.containsKey(vehicleId)) {
      _pathPointsMap[vehicleId]?.clear();
      _view.onPathsUpdated(_pathPointsMap);
    }
  }

  // Làm sạch tất cả đường đi
  void clearAllPaths() {
    _pathPointsMap.forEach((key, value) {
      value.clear();
    });
    _view.onPathsUpdated(_pathPointsMap);
  }

  // Cập nhật trạng thái khẩn cấp của xe
  Future<void> resetEmergencyStatus(VehicleModel vehicle) async {
    try {
      final String vehicleId = vehicle.vehicleId;
      bool? isAccident = vehicle.isAccident ? false : null;
      bool? isStole = vehicle.isStole ? false : null;

      // Chỉ cập nhật nếu có trạng thái cần reset
      if (isAccident != null || isStole != null) {
        bool success = await _vehicleService.updateVehicleStatus(
          vehicleId: vehicleId,
          isAccident: isAccident,
          isStole: isStole,
        );

        if (success) {
          // Reset trạng thái đã xử lý để có thể nhận thông báo mới (nếu có)
          _emergencyHandled[vehicleId] = false;
        }
      }
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái khẩn cấp: $e");
    }
  }
}
