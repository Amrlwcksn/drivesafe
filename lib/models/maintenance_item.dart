class MaintenanceItem {
  final int? id;
  final int vehicleId;
  final String name;
  final DateTime lastServiceDate;
  final double lastServiceOdometer;
  final double intervalDistance;
  final int intervalMonth;
  final int intervalDay; // New field for daily checks

  final int iconCode;
  final String? oilBrand;
  final String? oilVolume;

  MaintenanceItem({
    this.id,
    required this.vehicleId,
    required this.name,
    required this.lastServiceDate,
    required this.lastServiceOdometer,
    required this.intervalDistance,
    required this.intervalMonth,
    this.intervalDay = 0,
    this.iconCode = 0xe1ab, // Default build icon
    this.oilBrand,
    this.oilVolume,
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
      'intervalDay': intervalDay,
      'iconCode': iconCode,
      'oilBrand': oilBrand,
      'oilVolume': oilVolume,
    };
  }

  factory MaintenanceItem.fromMap(Map<String, dynamic> map) {
    return MaintenanceItem(
      id: map['id'],
      vehicleId: map['vehicleId'],
      name: map['name'],
      lastServiceDate: DateTime.parse(map['lastServiceDate']),
      lastServiceOdometer:
          (map['lastServiceOdometer'] as num?)?.toDouble() ?? 0.0,
      intervalDistance: (map['intervalDistance'] as num?)?.toDouble() ?? 0.0,
      intervalMonth: map['intervalMonth'] ?? 0,
      intervalDay: map['intervalDay'] ?? 0,
      iconCode: map['iconCode'] ?? 0xe1ab,
      oilBrand: map['oilBrand'],
      oilVolume: map['oilVolume'],
    );
  }
}
