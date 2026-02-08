class DistanceLog {
  final int id;
  final int vehicleId;
  final DateTime date;
  final double previousOdometer;
  final double newOdometer;
  final double addedDistance;

  DistanceLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.previousOdometer,
    required this.newOdometer,
    required this.addedDistance,
  });

  factory DistanceLog.fromMap(Map<String, dynamic> map) {
    return DistanceLog(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: DateTime.parse(map['date']),
      previousOdometer: map['previousOdometer'],
      newOdometer: map['newOdometer'],
      addedDistance: map['addedDistance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'previousOdometer': previousOdometer,
      'newOdometer': newOdometer,
      'addedDistance': addedDistance,
    };
  }
}
