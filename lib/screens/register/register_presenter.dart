import 'package:motor_secure/controller/register_controller.dart';
import 'package:motor_secure/services/authentication_service.dart';
import 'package:string_validator/string_validator.dart';

import 'register_contract.dart';

class RegisterPresenter {
  final RegisterViewContract? _view;
  final AuthenticationService _authService = AuthenticationService();
  final RegisterController _registerController =
      RegisterController.getInstance();
  RegisterPresenter(this._view);

  String? validateEmail(String? email) {
    email = email?.trim();
    if (email == null || email.isEmpty) {
      return "Please enter your email!";
    } else if (!isEmail(email)) {
      return "Email is not in the correct format!";
    }
    return null;
  }

  Future<void> register(String email) async {
    email = email.trim();
    _view?.onWaitingProgressBar();
    AuthResult authResult = AuthResult();
    bool? result = await _authService.checkIfEmailExists(email, authResult);
    _view?.onPopContext();

    if (result == true) {
      _view?.onEmailAlreadyInUse();
    } else if (result == false) {
      _registerController.email = email;
      _view?.onRegisterSucceeded();
    } else if (result == null) {
      _view?.onRegisterFailed();
    }
  }
}
