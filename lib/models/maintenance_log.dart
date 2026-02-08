class MaintenanceLog {
  final int? id;
  final int maintenanceItemId;
  final DateTime date;
  final double odometer;
  final String notes;
  final String? oilBrand;
  final String? oilVolume;

  MaintenanceLog({
    this.id,
    required this.maintenanceItemId,
    required this.date,
    required this.odometer,
    required this.notes,
    this.oilBrand,
    this.oilVolume,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maintenanceItemId': maintenanceItemId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'notes': notes,
      'oilBrand': oilBrand,
      'oilVolume': oilVolume,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['id'],
      maintenanceItemId: map['maintenanceItemId'],
      date: DateTime.parse(map['date']),
      odometer: map['odometer'],
      notes: map['notes'],
      oilBrand: map['oilBrand'],
      oilVolume: map['oilVolume'],
    );
  }
}
