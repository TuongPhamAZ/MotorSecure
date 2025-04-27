import 'dart:async';
import 'package:motor_secure/data/models/vehicle_model.dart';
import 'package:motor_secure/data/repositories/vehicle_repository.dart';

class VehicleService {
  final VehicleRepository _repository = VehicleRepository();

  static final VehicleService _instance = VehicleService._internal();

  factory VehicleService() {
    return _instance;
  }

  VehicleService._internal();

  Stream<List<VehicleModel>> getAllVehiclesStream() {
    return _repository.getAllVehiclesStream();
  }

  Stream<VehicleModel?> getVehicleStreamById(String vehicleId) {
    return _repository.getVehicleStreamById(vehicleId);
  }

  Stream<List<VehicleModel>> getVehiclesStreamByIds(List<String> vehicleIds) {
    return _repository.getVehiclesStreamByIds(vehicleIds);
  }

  Future<bool> updateVehicleStatus({
    required String vehicleId,
    bool? isAccident,
    bool? isStole,
  }) async {
    return await _repository.updateVehicleStatus(
      vehicleId: vehicleId,
      isAccident: isAccident,
      isStole: isStole,
    );
  }
}
