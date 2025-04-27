import 'package:firebase_auth/firebase_auth.dart';
import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/repositories/auth_repository.dart';
import 'package:motor_secure/services/authentication_service.dart';
import 'package:motor_secure/services/background_service.dart';
import 'package:motor_secure/services/pref_service.dart';

abstract class LoginViewContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onLoginSuccess();
  void onLoginFailed(String message);
}

class LoginViewPresenter {
  final LoginViewContract _view;
  final AuthenticationService _auth = AuthenticationService();
  final UserRepository _userRepo = UserRepository();

  LoginViewPresenter(this._view);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _view.onWaitingProgressBar();

    try {
      final authResult = AuthResult();

      UserCredential? credential = await _auth.signInWithEmailAndPassword(
        email,
        password,
        authResult,
      );

      if (credential != null) {
        UserModel user = await _userRepo.getUserById(credential.user!.uid);
        await PrefService.saveUserData(userData: user, password: password);

        // Bắt đầu dịch vụ nền sau khi đăng nhập thành công
        await BackgroundService.startService();

        _view.onPopContext();
        _view.onLoginSuccess();
      } else {
        _view.onPopContext();
        _view.onLoginFailed(authResult.text);
      }
    } catch (e) {
      _view.onPopContext();
      _view.onLoginFailed("Đăng nhập thất bại: ${e.toString()}");
    }
  }
}
