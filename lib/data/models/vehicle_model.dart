import 'package:motor_secure/domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  static const String collectionName = 'alarts';

  VehicleModel({
    required super.vehicleId,
    required super.latitude,
    required super.longitude,
    required super.battery,
    required super.isCharge,
    required super.isStole,
    required super.isAccident,
  });

  factory VehicleModel.fromJson(String id, Map<String, dynamic> json) {
    return VehicleModel(
      vehicleId: id,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      battery: json['battery'] as int,
      isCharge: json['isCharge'] as bool,
      isStole: json['isStole'] as bool,
      isAccident: json['isAccident'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'latitude': latitude,
      'longitude': longitude,
      'battery': battery,
      'isCharge': isCharge,
      'isStole': isStole,
      'isAccident': isAccident,
    };
  }

  VehicleModel copyWith({
    String? vehicleId,
    double? latitude,
    double? longitude,
    int? battery,
    bool? isCharge,
    bool? isStole,
    bool? isAccident,
  }) {
    return VehicleModel(
      vehicleId: vehicleId ?? this.vehicleId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      battery: battery ?? this.battery,
      isCharge: isCharge ?? this.isCharge,
      isStole: isStole ?? this.isStole,
      isAccident: isAccident ?? this.isAccident,
    );
  }
}
