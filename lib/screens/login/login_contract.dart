abstract class LoginViewContract {
  void onLoginFailed();
  void onLoginSucceeded();
  void onError(String message);
  void onWaitingProgressBar();
  void onPopContext();
}
