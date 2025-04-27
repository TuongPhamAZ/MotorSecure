import 'package:motor_secure/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static Future<void> saveUserData(
      {required UserModel userData, String? password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('userID', userData.id);
    if (password != null) {
      prefs.setString('password', password);
    }
    prefs.setString('name', userData.name);
    prefs.setString('email', userData.email);
    prefs.setString('DOB', userData.dob.toString());
    prefs.setString('phone', userData.phone.toString());
    prefs.setString('location', userData.address);
    prefs.setStringList('vehicleId', userData.vehicleId);
    prefs.setStringList('token', userData.token);
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userID');
    await prefs.remove('password');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('DOB');
    await prefs.remove('phone');
    await prefs.remove('location');
    await prefs.remove('vehicleId');
    await prefs.remove('token');
  }

  static Future<UserModel?> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('DOB') == null) {
      return null;
    }

    UserModel model = UserModel(
      id: prefs.getString('userID')!,
      name: prefs.getString('name')!,
      email: prefs.getString('email')!,
      dob: DateTime.parse(prefs.getString('DOB')!),
      phone: prefs.getString('phone')!,
      address: prefs.getString('location')!,
      vehicleId: prefs.getStringList('vehicleId') ?? [],
      token: prefs.getStringList('token') ?? [],
    );

    return model;
  }

  static Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password') ?? "";
  }
}
