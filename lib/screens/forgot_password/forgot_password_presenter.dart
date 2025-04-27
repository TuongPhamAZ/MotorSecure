import 'package:motor_secure/screens/forgot_password/forgot_password_contract.dart';
import 'package:motor_secure/services/authentication_service.dart';

class ForgotPasswordPresenter {
  final ForgotPasswordContract _view;
  ForgotPasswordPresenter(this._view);
  final AuthenticationService _auth = AuthenticationService();

  Future<void> resetPassword(String email) async {
    _view.onWaitingProgressBar();
    AuthResult authResult = AuthResult();
    bool? result = await _auth.checkIfEmailExists(email, authResult);

    if (result == null || result == false) {
      _view.onPopContext();
      _view.onForgotPasswordError("This email is not registered.");
      return;
    }

    String? error = await _auth.sendPasswordResetEmail(email);

    if (error == null) {
      _view.onPopContext();
      _view.onForgotPasswordSent();
    } else {
      _view.onPopContext();
      _view.onForgotPasswordError(error);
    }
  }
}
