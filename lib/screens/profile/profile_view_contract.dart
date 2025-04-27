abstract class ProfileScreenContract {
  void onLoadDataSucceeded();
  void onSignOut();
  void onWaitingProgressBar();
  void onPopContext();
  void onAddVehicleSucceeded();
  void onAddVehicleFailed(String message);
}
