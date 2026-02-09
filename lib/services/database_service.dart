import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../models/maintenance_log.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'drivesafe.db');
    return await openDatabase(
      path,
      version: 7, // Increment version to force retry
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      // Add intervalDay column to existing table
      // Check if column exists first to be safe, or just add it
      // Simple migration:
      try {
        await db.execute(
          'ALTER TABLE maintenance_items ADD COLUMN intervalDay INTEGER DEFAULT 0',
        );
      } catch (e) {
        // Ignore if column already exists (e.g. dev fluctuations)
        print('Error adding column: $e');
      }
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type INTEGER,
        year INTEGER,
        currentOdometer REAL
      )
    ''');

    // Spec 4.3 & 7: distance_logs
    await db.execute('''
      CREATE TABLE distance_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        date TEXT,
        previousOdometer REAL,
        newOdometer REAL,
        addedDistance REAL,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER,
        name TEXT,
        lastServiceDate TEXT,
        lastServiceOdometer REAL,
        intervalDistance REAL,
        intervalMonth INTEGER,
        intervalDay INTEGER,
        iconCode INTEGER,
        oilBrand TEXT,
        oilVolume TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        maintenanceItemId INTEGER,
        date TEXT,
        odometer REAL,
        notes TEXT,
        oilBrand TEXT,
        oilVolume TEXT,
        FOREIGN KEY (maintenanceItemId) REFERENCES maintenance_items (id) ON DELETE CASCADE
      )
    ''');
  }

  // Vehicle CRUD
  Future<int> insertVehicle(Vehicle vehicle) async {
    Database db = await database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getVehicles() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('vehicles');
    return List.generate(maps.length, (i) => Vehicle.fromMap(maps[i]));
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    Database db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    Database db = await database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // Maintenance Item CRUD
  Future<int> insertMaintenanceItem(MaintenanceItem item) async {
    Database db = await database;
    return await db.insert('maintenance_items', item.toMap());
  }

  Future<int> updateMaintenanceItem(MaintenanceItem item) async {
    Database db = await database;
    return await db.update(
      'maintenance_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<List<MaintenanceItem>> getMaintenanceItems(int vehicleId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'maintenance_items',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
    );
    return List.generate(maps.length, (i) => MaintenanceItem.fromMap(maps[i]));
  }

  Future<int> deleteMaintenanceItem(int id) async {
    Database db = await database;
    return await db.delete(
      'maintenance_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('vehicles');
    await db.delete('maintenance_items');
    await db.delete('maintenance_logs');
  }

  Future<void> insertDistanceLog(
    int vehicleId,
    String date,
    double prevOdo,
    double newOdo,
    double added,
  ) async {
    Database db = await database;
    await db.insert('distance_logs', {
      'vehicleId': vehicleId,
      'date': date,
      'previousOdometer': prevOdo,
      'newOdometer': newOdo,
      'addedDistance': added,
    });
  }

  Future<List<Map<String, dynamic>>> getDistanceLogs(int vehicleId) async {
    Database db = await database;
    return await db.query(
      'distance_logs',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
  }

  // Maintenance Log CRUD
  Future<int> insertMaintenanceLog(MaintenanceLog log) async {
    Database db = await database;
    return await db.insert('maintenance_logs', log.toMap());
  }

  Future<List<MaintenanceLog>> getMaintenanceLogs(int itemId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'maintenance_logs',
      where: 'maintenanceItemId = ?',
      whereArgs: [itemId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => MaintenanceLog.fromMap(maps[i]));
  }

  Future<List<MaintenanceLog>> getAllMaintenanceLogs() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'maintenance_logs',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => MaintenanceLog.fromMap(maps[i]));
  }
}
