import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/data/models/vehicle_model.dart';
import 'package:motor_secure/screens/home/home_presenter.dart';
import 'package:motor_secure/screens/home/home_view_contract.dart';
import 'package:motor_secure/widgets/bottom_bar_custom.dart';
import 'package:motor_secure/widgets/util_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const String routeName = 'home_view';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> implements HomeViewContract {
  late HomePresenter _presenter;
  bool _isLoading = false;
  String _errorMessage = '';

  // Controller cho PageView
  late PageController _pageController;

  // Dữ liệu thiết bị
  List<String> _vehicleIds = [];
  List<VehicleModel> _vehicles = [];
  int _currentPage = 0;

  // Dữ liệu đường đi
  Map<String, List<Map<String, dynamic>>> _pathPointsMap = {};

  // Bản đồ markers
  Set<Marker> _markers = {};

  // Thông tin vị trí hiện tại
  Position? _currentPosition;
  GoogleMapController? _mapController;

  // Thời gian cập nhật gần nhất
  DateTime _lastUpdated = DateTime.now();

  // Tập marker tạm thời khi bấm vào bản đồ
  Marker? _tempMarker;

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
    _pageController = PageController(initialPage: 0);
    _getCurrentLocation();
    _loadUserVehicles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController?.dispose();
    _presenter.dispose();
    super.dispose();
  }

  // Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _lastUpdated = DateTime.now();
      });

      // Cập nhật bản đồ nếu đã khởi tạo
      _updateMapCamera();
    } catch (e) {
      print("Không thể lấy vị trí: $e");
    }
  }

  // Cập nhật camera bản đồ
  void _updateMapCamera() {
    if (_mapController != null && _currentVehicle != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentVehicle!.latitude, _currentVehicle!.longitude),
            zoom: 15,
          ),
        ),
      );
    } else if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  // Tải danh sách thiết bị
  Future<void> _loadUserVehicles() async {
    setState(() {
      _isLoading = true;
    });
    await _presenter.loadUserVehicles();
  }

  // Chuyển sang trang trước
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Chuyển sang trang tiếp theo
  void _nextPage() {
    if (_currentPage < _vehicleIds.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Lấy vehicle hiện tại đang hiển thị
  VehicleModel? get _currentVehicle {
    if (_vehicles.isEmpty || _currentPage >= _vehicles.length) {
      return null;
    }
    return _vehicles[_currentPage];
  }

  // Hàm lấy địa chỉ từ tọa độ
  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'MotorSecure App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Không xác định';
      } else {
        return 'Không thể lấy địa chỉ';
      }
    } catch (e) {
      print("Lỗi khi lấy địa chỉ: $e");
      return 'Không thể lấy địa chỉ';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xác định hiển thị nút điều hướng
    final bool showLeftButton = _currentPage > 0;
    final bool showRightButton = _currentPage < _vehicleIds.length - 1;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(
            FontAwesomeIcons.earthAmericas,
            color: AppPalette.primaryColor,
            size: 35,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'GPS TRACKING',
          style: AppTextStyles.profileTitle,
        ),
        centerTitle: true,
        actions: [
          // Nút làm mới vị trí
          IconButton(
            onPressed: _getCurrentLocation,
            icon: Icon(
              FontAwesomeIcons.rotateLeft,
              color: AppPalette.primaryColor,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Lỗi: $_errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                )
              : _vehicleIds.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có thiết bị nào được đăng ký. Vui lòng thêm thiết bị trong mục Cá nhân.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          physics:
                              const NeverScrollableScrollPhysics(), // Vô hiệu hóa tính năng lướt
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                            _updateMapCamera();
                          },
                          itemCount: _vehicleIds.length,
                          itemBuilder: (context, index) {
                            final vehicle =
                                _vehicles.isNotEmpty && index < _vehicles.length
                                    ? _vehicles[index]
                                    : null;
                            return _buildDevicePage(index, vehicle);
                          },
                        ),

                        // Hiển thị số trang hiện tại
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Thiết bị ${_currentPage + 1}/${_vehicleIds.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Nút điều hướng trái
                        if (showLeftButton)
                          Positioned(
                            left: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _previousPage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Nút điều hướng phải
                        if (showRightButton)
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _nextPage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
      bottomNavigationBar: const BottomBarCustom(currentIndex: 1),
    );
  }

  // Widget để hiển thị thông tin của một thiết bị
  Widget _buildDevicePage(int index, VehicleModel? vehicle) {
    return Column(
      children: [
        // Phần bản đồ
        Expanded(
          flex: 4,
          child: _buildMap(index, vehicle),
        ),

        // Phần thông tin thiết bị
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ID thiết bị và trạng thái
              Row(
                children: [
                  Icon(FontAwesomeIcons.motorcycle,
                      color: AppPalette.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ID: ${_vehicleIds[index]}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.primaryColor,
                    ),
                  ),
                  if (vehicle != null) ...[
                    const Spacer(),
                    _buildStatusIndicator(vehicle),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Thông tin chi tiết
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.location_on,
                      title: 'Vị trí',
                      value: vehicle != null
                          ? '${vehicle.latitude.toStringAsFixed(6)}, ${vehicle.longitude.toStringAsFixed(6)}'
                          : 'Không xác định',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.speed,
                      title: 'Tốc độ',
                      value: '0 km/h', // Giả định chưa có thông tin tốc độ
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.battery_full,
                      title: 'Pin',
                      value: vehicle != null
                          ? '${vehicle.battery}%${vehicle.isCharge ? " (đang sạc)" : ""}'
                          : 'Không xác định',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.update,
                      title: 'Cập nhật',
                      value: DateFormat('HH:mm:ss dd/MM/yyyy')
                          .format(_lastUpdated),
                    ),
                  ),
                ],
              ),

              // Nút xóa đường đi
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_vehicleIds.isNotEmpty &&
                        _currentPage < _vehicleIds.length) {
                      _showClearPathDialog(context);
                    }
                  },
                  icon: const Icon(Icons.timeline_outlined, size: 18),
                  label: const Text('Xóa đường đi'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppPalette.primaryColor,
                    backgroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppPalette.primaryColor),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tạo widget hiển thị bản đồ
  Widget _buildMap(int index, VehicleModel? vehicle) {
    final String vehicleId = _vehicleIds[index];
    final Set<Polyline> polylines = _createPolylines(vehicleId);

    // Tạo tập markers mới bắt đầu với marker thiết bị
    _markers = {};

    // Thêm marker tạm thời nếu có
    if (_tempMarker != null) {
      _markers.add(_tempMarker!);
    }

    if (vehicle != null) {
      _markers.add(
        Marker(
          markerId: MarkerId(_vehicleIds[index]),
          position: LatLng(vehicle.latitude, vehicle.longitude),
          infoWindow: InfoWindow(
            title: 'Vị trí thiết bị',
            snippet: 'ID: ${_vehicleIds[index]}',
          ),
          icon: _getMarkerIcon(vehicle),
        ),
      );

      // Nếu có thông tin vehicle, hiển thị vị trí của vehicle
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(vehicle.latitude, vehicle.longitude),
          zoom: 15,
        ),
        markers: _markers,
        polylines: polylines,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        trafficEnabled: false,
        onTap: (LatLng position) async {
          // Lấy khoảng cách đến thiết bị nếu có
          final String distance = _currentVehicle != null
              ? '${_calculateDistance(position, _currentVehicle!).toStringAsFixed(2)} km'
              : '';

          // Lấy địa chỉ từ vị trí
          final address = await _getAddressFromLatLng(
              position.latitude, position.longitude);

          // Tạo marker mới
          setState(() {
            _tempMarker = Marker(
              markerId: const MarkerId('selected_location'),
              position: position,
              infoWindow: InfoWindow(
                title: address,
                snippet: distance.isNotEmpty ? 'Khoảng cách: $distance' : '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet),
            );

            // Cập nhật markers và di chuyển camera
            _markers.add(_tempMarker!);
            _mapController?.animateCamera(CameraUpdate.newLatLng(position));

            // Hiển thị InfoWindow
            Future.delayed(const Duration(milliseconds: 300), () {
              _mapController
                  ?.showMarkerInfoWindow(const MarkerId('selected_location'));
            });
          });
        },
      );
    } else if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: InfoWindow(
            title: 'Vị trí hiện tại',
            snippet: 'ID: ${_vehicleIds[index]}',
          ),
        ),
      );

      // Nếu không có thông tin vehicle nhưng có vị trí hiện tại, hiển thị vị trí hiện tại
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 15,
        ),
        markers: _markers,
        polylines: polylines,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal,
        trafficEnabled: false,
        onTap: (LatLng position) async {
          // Lấy khoảng cách đến thiết bị nếu có
          final String distance = _currentVehicle != null
              ? '${_calculateDistance(position, _currentVehicle!).toStringAsFixed(2)} km'
              : '';

          // Lấy địa chỉ từ vị trí
          final address = await _getAddressFromLatLng(
              position.latitude, position.longitude);

          // Tạo marker mới
          setState(() {
            _tempMarker = Marker(
              markerId: const MarkerId('selected_location'),
              position: position,
              infoWindow: InfoWindow(
                title: address,
                snippet: distance.isNotEmpty ? 'Khoảng cách: $distance' : '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet),
            );

            // Cập nhật markers và di chuyển camera
            _markers.add(_tempMarker!);
            _mapController?.animateCamera(CameraUpdate.newLatLng(position));

            // Hiển thị InfoWindow
            Future.delayed(const Duration(milliseconds: 300), () {
              _mapController
                  ?.showMarkerInfoWindow(const MarkerId('selected_location'));
            });
          });
        },
      );
    } else {
      // Nếu không có thông tin gì, hiển thị thông báo đang tải
      return const Center(child: Text('Đang tải bản đồ...'));
    }
  }

  // Tạo polylines từ dữ liệu đường đi
  Set<Polyline> _createPolylines(String vehicleId) {
    final Set<Polyline> polylines = {};

    if (_pathPointsMap.containsKey(vehicleId) &&
        _pathPointsMap[vehicleId]!.isNotEmpty) {
      final List<Map<String, dynamic>> pathPoints = _pathPointsMap[vehicleId]!;
      final List<LatLng> points =
          pathPoints.map((point) => point['position'] as LatLng).toList();

      if (points.length > 1) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('path_$vehicleId'),
            color: AppPalette.primaryColor,
            width: 5,
            points: points,
          ),
        );
      }
    }

    return polylines;
  }

  // Lấy biểu tượng marker dựa trên trạng thái của vehicle
  BitmapDescriptor _getMarkerIcon(VehicleModel vehicle) {
    // Mặc định trả về BitmapDescriptor.defaultMarker
    // Trong thực tế, bạn có thể tạo các biểu tượng khác nhau dựa trên trạng thái
    if (vehicle.isStole) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (vehicle.isAccident) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  // Hiển thị chỉ báo trạng thái của thiết bị
  Widget _buildStatusIndicator(VehicleModel vehicle) {
    if (vehicle.isStole) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Trộm cắp',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    } else if (vehicle.isAccident) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Tai nạn',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Bình thường',
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  // Widget để hiển thị một thông tin chi tiết
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppPalette.primaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onLoadUserDataSucceeded(int tokenCount) {
    setState(() {
      _isLoading = false;
      _errorMessage = '';
    });
  }

  @override
  void onLoadUserDataFailed(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  @override
  void onLoadUserVehiclesSucceeded(List<String> vehicleIds) {
    setState(() {
      _vehicleIds = vehicleIds;
      _isLoading = false;
      _errorMessage = '';
    });
  }

  @override
  void onVehiclesDataUpdated(List<VehicleModel> vehicles) {
    setState(() {
      _vehicles = vehicles;
      _lastUpdated = DateTime.now();
    });

    // Cập nhật camera nếu cần
    _updateMapCamera();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onSendNotificationSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi thông báo khẩn cấp thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void onSendNotificationFailed(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gửi thông báo thất bại: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void onPathsUpdated(Map<String, List<Map<String, dynamic>>> pathPointsMap) {
    setState(() {
      _pathPointsMap = pathPointsMap;
    });
  }

  @override
  void onShowEmergencyDialog(
      VehicleModel vehicle, String title, String content) {
    // Đảm bảo chuyển đến trang của vehicle có tình trạng khẩn cấp
    int vehicleIndex = _vehicleIds.indexOf(vehicle.vehicleId);
    if (vehicleIndex != -1 && vehicleIndex != _currentPage) {
      _pageController.animateToPage(
        vehicleIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // Hiển thị dialog cảnh báo
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng bằng cách nhấp bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200], // Nền xám
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 3), // Viền đỏ
          ),
          title: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _presenter.resetEmergencyStatus(vehicle);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị hộp thoại xác nhận xóa đường đi
  void _showClearPathDialog(BuildContext context) {
    final String currentVehicleId = _vehicleIds[_currentPage];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa đường đi'),
          content: const Text('Bạn muốn xóa đường đi của thiết bị này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.clearVehiclePath(currentVehicleId);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _presenter.clearAllPaths();
              },
              child:
                  const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Tính khoảng cách giữa hai điểm
  double _calculateDistance(LatLng point1, VehicleModel vehicle) {
    return Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          vehicle.latitude,
          vehicle.longitude,
        ) /
        1000; // Chuyển đổi từ mét sang km
  }
}
