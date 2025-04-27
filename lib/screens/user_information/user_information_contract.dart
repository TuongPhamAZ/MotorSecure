abstract class UserInformationContract {
  void onConfirmSucceeded();
  void onConfirmFailed(String message);
  void onWaitingProgressBar();
  void onPopContext();
}