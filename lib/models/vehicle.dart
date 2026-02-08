enum VehicleType { motor, mobil }

class Vehicle {
  final int? id;
  final String name;
  final VehicleType type;
  final int year;
  final double currentOdometer;

  Vehicle({
    this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.currentOdometer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'year': year,
      'currentOdometer': currentOdometer,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      type: VehicleType.values[map['type']],
      year: map['year'],
      currentOdometer: (map['currentOdometer'] as num).toDouble(),
    );
  }
}
