class VehicleEntity {
  final String vehicleId;
  final double latitude;
  final double longitude;
  final int battery;
  final bool isCharge;
  final bool isStole;
  final bool isAccident;

  VehicleEntity({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.battery,
    required this.isCharge,
    required this.isStole,
    required this.isAccident,
  });
}
