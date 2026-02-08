class MaintenanceItem {
  final int? id;
  final int vehicleId;
  final String name;
  final DateTime lastServiceDate;
  final double lastServiceOdometer;
  final double intervalDistance;
  final int intervalMonth;

  final int iconCode;

  MaintenanceItem({
    this.id,
    required this.vehicleId,
    required this.name,
    required this.lastServiceDate,
    required this.lastServiceOdometer,
    required this.intervalDistance,
    required this.intervalMonth,
    this.iconCode = 0xe1ab, // Default build icon
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'name': name,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'lastServiceOdometer': lastServiceOdometer,
      'intervalDistance': intervalDistance,
      'intervalMonth': intervalMonth,
      'iconCode': iconCode,
    };
  }

  factory MaintenanceItem.fromMap(Map<String, dynamic> map) {
    return MaintenanceItem(
      id: map['id'],
      vehicleId: map['vehicleId'],
      name: map['name'],
      lastServiceDate: DateTime.parse(map['lastServiceDate']),
      lastServiceOdometer: map['lastServiceOdometer'],
      intervalDistance: map['intervalDistance'],
      intervalMonth: map['intervalMonth'],
      iconCode: map['iconCode'] ?? 0xe1ab,
    );
  }
}
