import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:motor_secure/controller/session_controller.dart';
import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/repositories/auth_repository.dart';
import 'package:motor_secure/screens/login/login_contract.dart';
import 'package:motor_secure/services/authentication_service.dart';
import 'package:motor_secure/services/pref_service.dart';

class LoginPresenter {
  final LoginViewContract _view;
  LoginPresenter(this._view);
  final AuthenticationService _authService = AuthenticationService();
  final UserRepository _userRepo = UserRepository();
  final SessionController _sessionController = SessionController.getInstance();

  Future<void> login(String email, String password) async {
    try {
      _view.onWaitingProgressBar();
      AuthResult authResult = AuthResult();
      UserCredential? userCredential = await _authService
          .signInWithEmailAndPassword(email, password, authResult);

      if (authResult.code == AuthResult.WrongPassword ||
          authResult.code == AuthResult.UserNotFound ||
          authResult.code == AuthResult.InvalidCredential) {
        _view.onPopContext();
        _view.onLoginFailed();
        return;
      } else if (authResult.code == AuthResult.NetworkRequestFailed) {
        _view.onPopContext();
        _view.onError(authResult.text);
        return;
      } else if (authResult.code == AuthResult.UnknownError) {
        _view.onPopContext();
        _view.onError("Login failed.");
      }

      // Lấy thông tin người dùng từ cơ sở dữ liệu
      UserModel userData =
          await _userRepo.getUserById(userCredential!.user!.uid);

      // Lấy FCM token hiện tại
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? currentToken = await messaging.getToken();

      // Kiểm tra và cập nhật token nếu cần
      if (currentToken != null) {
        // Kiểm tra nếu token chưa tồn tại trong danh sách token của người dùng
        if (!userData.token.contains(currentToken)) {
          // Thêm token mới vào danh sách
          userData.token.add(currentToken);

          // Cập nhật dữ liệu người dùng trên Firestore
          await _userRepo.updateUser(userData);
        }
      }

      // Tiếp tục quy trình đăng nhập
      await _sessionController.loadUser(userData);
      await PrefService.saveUserData(userData: userData, password: password);
    } catch (e) {
      _view.onPopContext();
      _view.onError("Something was wrong. Please try again.");
      return;
    }
    _view.onPopContext();
    _view.onLoginSucceeded();
  }
}
