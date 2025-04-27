import 'package:motor_secure/builders/user_builder.dart';

class RegisterController {
  static RegisterController? _registerController;

  static getInstance() {
    _registerController ??= RegisterController();
    return _registerController;
  }

  RegisterController();

  String? email;
  final UserBuilder _builder = UserBuilder();

  void reset() {
    _builder.reset();
  }

  UserBuilder getBuilder() {
    return _builder;
  }
}
