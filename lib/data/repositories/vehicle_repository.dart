import 'package:firebase_database/firebase_database.dart';
import 'package:motor_secure/data/models/vehicle_model.dart';

class VehicleRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Lấy stream danh sách tất cả các vehicle
  Stream<List<VehicleModel>> getAllVehiclesStream() {
    final vehiclesRef = _database.child(VehicleModel.collectionName);

    return vehiclesRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      final Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;

      if (values == null || values.isEmpty) {
        return [];
      }

      List<VehicleModel> vehicles = [];
      values.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          // Chuyển Map<dynamic, dynamic> sang Map<String, dynamic>
          final Map<String, dynamic> vehicleData = {};
          value.forEach((k, v) {
            vehicleData[k.toString()] = v;
          });

          vehicles.add(VehicleModel.fromJson(key.toString(), vehicleData));
        }
      });

      return vehicles;
    });
  }

  // Lấy stream thông tin của một vehicle cụ thể theo ID
  Stream<VehicleModel?> getVehicleStreamById(String vehicleId) {
    final vehicleRef =
        _database.child('${VehicleModel.collectionName}/$vehicleId');

    return vehicleRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      final Map<dynamic, dynamic>? value = dataSnapshot.value as Map?;

      if (value == null || value.isEmpty) {
        return null;
      }

      // Chuyển Map<dynamic, dynamic> sang Map<String, dynamic>
      final Map<String, dynamic> vehicleData = {};
      value.forEach((k, v) {
        vehicleData[k.toString()] = v;
      });

      return VehicleModel.fromJson(vehicleId, vehicleData);
    });
  }

  // Lấy stream các vehicle theo danh sách ID
  Stream<List<VehicleModel>> getVehiclesStreamByIds(List<String> vehicleIds) {
    if (vehicleIds.isEmpty) {
      return Stream.value([]);
    }

    final vehiclesRef = _database.child(VehicleModel.collectionName);

    return vehiclesRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      final Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;

      if (values == null || values.isEmpty) {
        return [];
      }

      List<VehicleModel> vehicles = [];
      for (String id in vehicleIds) {
        if (values.containsKey(id)) {
          final value = values[id];
          if (value is Map<dynamic, dynamic>) {
            // Chuyển Map<dynamic, dynamic> sang Map<String, dynamic>
            final Map<String, dynamic> vehicleData = {};
            value.forEach((k, v) {
              vehicleData[k.toString()] = v;
            });

            vehicles.add(VehicleModel.fromJson(id, vehicleData));
          }
        }
      }

      return vehicles;
    });
  }

  // Cập nhật trạng thái của vehicle trong Firebase
  Future<bool> updateVehicleStatus({
    required String vehicleId,
    bool? isAccident,
    bool? isStole,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (isAccident != null) {
        updates['isAccident'] = isAccident;
      }

      if (isStole != null) {
        updates['isStole'] = isStole;
      }

      if (updates.isEmpty) {
        return false;
      }

      await _database
          .child('${VehicleModel.collectionName}/$vehicleId')
          .update(updates);

      return true;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái vehicle: $e');
      return false;
    }
  }
}
