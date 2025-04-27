import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:motor_secure/builders/user_builder.dart';
import 'package:motor_secure/controller/register_controller.dart';
import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/repositories/auth_repository.dart';
import 'package:motor_secure/screens/user_information/user_information_contract.dart';
import 'package:motor_secure/services/authentication_service.dart';
import 'package:motor_secure/singleton/user_singleton.dart';
import '../../../services/pref_service.dart';

class UserInformationPresenter {
  final UserInformationContract _view;
  UserInformationPresenter(this._view);

  final RegisterController _registerController =
      RegisterController.getInstance();
  final UserRepository _userRepo = UserRepository();
  final AuthenticationService _auth = AuthenticationService();

  String getEmail() {
    return _registerController.email!;
  }

  Future<void> handleConfirm({
    required String name,
    required String email,
    required String phone,
    required String location,
    required DateTime? birthDate,
    required String password,
    required String rePassword,
  }) async {
    _view.onWaitingProgressBar();

    if (name.isEmpty ||
        phone.isEmpty ||
        location.isEmpty ||
        password.isEmpty ||
        rePassword.isEmpty ||
        birthDate == null) {
      _view.onPopContext();
      _view.onConfirmFailed("Please complete all required fields");
      return;
    }

    if (password.length < 8) {
      _view.onPopContext();
      _view.onConfirmFailed("Password must be equal or more than 8 characters");
      return;
    }

    if (password != rePassword) {
      _view.onPopContext();
      _view.onConfirmFailed("Passwords do not match");
      return;
    }

    try {
      UserCredential? userCredential =
          await _auth.signUpWithEmailAndPassword(email, password);
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (userCredential == null) {
        _view.onPopContext();
        _view.onConfirmFailed("Something was wrong. Please try again.");
        return;
      }
      _registerController.reset();
      UserBuilder builder = _registerController.getBuilder();
      builder.setUserID(userCredential.user!.uid);
      builder.setName(name);
      builder.setEmail(email);
      builder.setDateOfBirth(birthDate);
      builder.setPhone(phone);
      builder.setAddress(location);
      builder.setVehicleId([]);
      builder.setToken([token!]);
      UserModel user = builder.createModel();
      
      _userRepo.addUserToFirestore(user);
      await PrefService.saveUserData(userData: user, password: password);
      UserSingleton.getInstance().loadUser(user);
      _view.onPopContext();
      _view.onConfirmSucceeded();
    } catch (e) {
      _view.onPopContext();
      _view.onConfirmFailed("Something was wrong. Please try again.");
    }
  }
}
