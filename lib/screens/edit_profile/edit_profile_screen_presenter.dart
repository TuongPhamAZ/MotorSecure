import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/repositories/auth_repository.dart';
import 'package:motor_secure/screens/edit_profile/edit_profile_screen_contract.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:motor_secure/singleton/user_singleton.dart';

class EditProfileScreenPresenter {
  final EditProfileScreenContract _view;
  EditProfileScreenPresenter(this._view);

  final UserRepository _userRepo = UserRepository();

  UserModel? user;

  Future<void> getData() async {
    user = await PrefService.loadUserData();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleSave({
    required String name,
    required DateTime dob,
    required String address,
    required String phone,
  }) async {
    _view.onWaitingProgressBar();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      _view.onPopContext();
      _view.onSaveFailed("Please complete all required fields");
      return;
    }

    user!.name = name;
    user!.phone = phone;
    user!.dob = dob;
    user!.address = address;

    await _userRepo.updateUser(user!);
    await PrefService.saveUserData(userData: user!);
    UserSingleton.getInstance().currentUser = user;
    _view.onPopContext();
    _view.onSaveSucceeded();
  }
}
