import 'package:motor_secure/data/models/user_model.dart';
import 'package:motor_secure/data/repositories/auth_repository.dart';
import 'package:motor_secure/screens/profile/profile_view_contract.dart';
import 'package:motor_secure/services/authentication_service.dart';
import 'package:motor_secure/services/pref_service.dart';
import 'package:motor_secure/singleton/user_singleton.dart';

class ProfileScreenPresenter {
  final ProfileScreenContract _view;
  ProfileScreenPresenter(this._view);

  UserModel? user;

  final AuthenticationService _auth = AuthenticationService();
  final UserRepository _userRepo = UserRepository();

  Future<void> getData() async {
    user = await PrefService.loadUserData();
    _view.onLoadDataSucceeded();
  }

  Future<void> signOut() async {
    _view.onWaitingProgressBar();
    await _auth.signOut();
    await PrefService.clearUserData();
    await UserSingleton.getInstance().signOut();
    _view.onPopContext();
    _view.onSignOut();
  }

  Future<void> addVehicle(String vehicleId) async {
    _view.onWaitingProgressBar();

    if (vehicleId.isEmpty) {
      _view.onPopContext();
      _view.onAddVehicleFailed("Mã phương tiện không được để trống");
      return;
    }

    try {
      // Kiểm tra xem mã phương tiện đã tồn tại chưa
      if (user!.vehicleId.contains(vehicleId)) {
        _view.onPopContext();
        _view.onAddVehicleFailed("Mã phương tiện đã tồn tại");
        return;
      }

      // Thêm mã phương tiện vào danh sách
      user!.vehicleId.add(vehicleId);

      // Cập nhật dữ liệu trên Firestore
      bool updateSuccess = await _userRepo.updateUser(user!);

      if (!updateSuccess) {
        _view.onPopContext();
        _view.onAddVehicleFailed("Cập nhật thông tin thất bại");
        return;
      }

      // Lấy dữ liệu mới nhất từ Firestore
      user = await _userRepo.getUserById(user!.id);

      // Cập nhật dữ liệu local với dữ liệu mới nhất
      await PrefService.saveUserData(userData: user!);

      // Cập nhật singleton
      UserSingleton.getInstance().loadUser(user!);

      _view.onPopContext();
      _view.onAddVehicleSucceeded();
    } catch (e) {
      _view.onPopContext();
      _view.onAddVehicleFailed("Đã xảy ra lỗi: ${e.toString()}");
    }
  }
}
