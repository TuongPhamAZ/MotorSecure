import 'package:motor_secure/data/models/user_model.dart';

class SessionController {
  static SessionController? _instance;
  static SessionController getInstance() {
    _instance ??= SessionController();
    return _instance!;
  }

  String? userID;

  bool firstEnter = false;

  Future<void> loadUser(UserModel user) async {
    userID = user.id;
    firstEnter = true;
  }

  Future<void> signOut() async {}

}
