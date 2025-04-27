abstract class HomeViewContract {
  void onLoadUserDataSucceeded(int tokenCount);
  void onLoadUserDataFailed(String message);
  void onWaitingProgressBar();
  void onPopContext();
  void onSendNotificationSuccess();
  void onSendNotificationFailed(String message);
}
