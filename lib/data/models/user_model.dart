import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_secure/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  static const String collectionName = 'Users';
  UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.address,
    required super.dob,
    required super.vehicleId,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final vehicleId = json['vehicleId'] as List?;
    final token = json['token'] as List?;
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      dob: (json['dob'] as Timestamp).toDate(),
      vehicleId: List.castFrom(vehicleId ?? []),
      token: List.castFrom(token ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'dob': dob,
      'vehicleId': vehicleId,
      'token': token,
    };
  }
}
