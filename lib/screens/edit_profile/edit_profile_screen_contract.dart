abstract class EditProfileScreenContract {
  void onLoadDataSucceeded();
  void onSaveSucceeded();
  void onPickAvatar();
  void onSaveFailed(String message);
  void onWaitingProgressBar();
  void onPopContext();
}