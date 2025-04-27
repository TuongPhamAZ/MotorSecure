import 'package:motor_secure/data/models/user_model.dart';

class UserSingleton {
  static UserSingleton? _instance;
  static UserSingleton getInstance() {
    _instance ??= UserSingleton();
    return _instance!;
  }

  UserModel? currentUser;

  bool firstEnter = true;

  Future<void> loadUser(UserModel user) async {
    currentUser = user;
    firstEnter = true;
  }

  Future<void> signOut() async {}
}
