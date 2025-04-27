import 'package:motor_secure/builders/model_builder_interface.dart';
import 'package:motor_secure/data/models/user_model.dart';

class UserBuilder implements ModelBuilderInterface<UserModel> {
  late UserModel _model;

  UserBuilder() {
    reset();
  }

  void setUserID(String id) {
    _model.id = id;
  }

  void setName(String name) {
    _model.name = name;
  }

  void setEmail(String email) {
    _model.email = email;
  }

  void setPhone(String phone) {
    _model.phone = phone;
  }

  void setDateOfBirth(DateTime date) {
    _model.dob = date;
  }

  void setAddress(String address) {
    _model.address = address;
  }

  void setVehicleId(List<String> vehicleId) {
    _model.vehicleId = vehicleId;
  }

  void setToken(List<String> token) {
    _model.token = token;
  }

  @override
  UserModel createModel() {
    return _model;
  }

  @override
  void reset() {
    _model = UserModel(
      id: "",
      name: "",
      email: "",
      phone: "",
      dob: DateTime.now(),
      address: "",
      vehicleId: [],
      token: [],
    );
  }
}
