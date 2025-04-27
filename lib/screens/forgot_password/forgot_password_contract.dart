abstract class ForgotPasswordContract {
  void onForgotPasswordSent();
  void onForgotPasswordError(String errorMessage);
  void onWaitingProgressBar();
  void onPopContext();
}