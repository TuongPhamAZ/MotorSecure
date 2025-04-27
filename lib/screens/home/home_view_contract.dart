import 'package:motor_secure/data/models/vehicle_model.dart';

abstract class HomeViewContract {
  void onLoadUserDataSucceeded(int tokenCount);
  void onLoadUserDataFailed(String message);
  void onWaitingProgressBar();
  void onPopContext();
  void onSendNotificationSuccess();
  void onSendNotificationFailed(String message);
  void onLoadUserVehiclesSucceeded(List<String> vehicleIds);
  void onVehiclesDataUpdated(List<VehicleModel> vehicles);
  void onPathsUpdated(Map<String, List<Map<String, dynamic>>> pathPointsMap);
  void onShowEmergencyDialog(
      VehicleModel vehicle, String title, String content);
}
