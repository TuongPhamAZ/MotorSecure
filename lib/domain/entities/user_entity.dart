class UserEntity {
  String id;
  String name;
  String phone;
  String email;
  String address;
  DateTime dob;
  List<String> vehicleId;
  List<String> token;

  UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.dob,
    required this.vehicleId,
    required this.token,
  });
}
