import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../models/maintenance_log.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

enum MaintenanceStatus { aman, mendekati, wajibGanti }

class VehicleProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Vehicle> _vehicles = [];
  Map<int, List<MaintenanceItem>> _maintenanceItems = {};
  Map<int, List<Map<String, dynamic>>> _distanceLogs = {}; // Changed to Map
  List<MaintenanceLog> _logs = [];

  int? _selectedVehicleId; // Track selected vehicle
  String _username = '';
  bool _isReminderEnabled = true; // Default to true

  List<Vehicle> get vehicles => _vehicles;
  List<MaintenanceLog> get logs => _logs;
  bool get isReminderEnabled => _isReminderEnabled;

  // Get currently selected vehicle
  Vehicle? get selectedVehicle {
    if (_vehicles.isEmpty) return null;
    if (_selectedVehicleId == null) return _vehicles.first;
    try {
      return _vehicles.firstWhere((v) => v.id == _selectedVehicleId);
    } catch (_) {
      return _vehicles.isNotEmpty ? _vehicles.first : null;
    }
  }

  // Get logs specific to selected vehicle
  List<MaintenanceLog> get selectedVehicleLogs {
    final vehicle = selectedVehicle;
    if (vehicle == null) return [];

    final items = _maintenanceItems[vehicle.id] ?? [];
    final itemIds = items.map((i) => i.id).toSet();

    return _logs
        .where((log) => itemIds.contains(log.maintenanceItemId))
        .toList();
  }

  // Get distance logs specific to selected vehicle
  List<Map<String, dynamic>> get distanceLogs {
    final vehicle = selectedVehicle;
    if (vehicle == null) return [];
    return _distanceLogs[vehicle.id] ?? [];
  }

  String get username => _username;

  VehicleProvider() {
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    _isReminderEnabled = prefs.getBool('isReminderEnabled') ?? true;

    // Sync notification status on load
    if (_isReminderEnabled) {
      _scheduleOdometerReminder();
    }

    // Load vehicles and maintenance data from SQLite
    await fetchVehicles();

    notifyListeners();
  }

  Future<void> setUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
    _username = name;
    notifyListeners();
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isReminderEnabled', enabled);
    _isReminderEnabled = enabled;

    if (enabled) {
      _scheduleOdometerReminder();
    } else {
      await NotificationService().cancelNotification(999);
    }

    notifyListeners();
  }

  void _scheduleOdometerReminder() {
    NotificationService().scheduleDailyReminder(
      id: 999,
      title: 'Update Odometer Anda!',
      body:
          'Jangan lupa untuk mencatat odometer kendaraan Anda hari ini agar perawatan tetap terpantau.',
    );
  }

  void selectVehicle(int vehicleId) {
    if (_vehicles.any((v) => v.id == vehicleId)) {
      _selectedVehicleId = vehicleId;
      notifyListeners();
    }
  }

  Future<void> fetchVehicles() async {
    _vehicles = await _dbService.getVehicles();

    // Auto-select first vehicle if none selected or selection invalid
    if (_vehicles.isNotEmpty) {
      if (_selectedVehicleId == null ||
          !_vehicles.any((v) => v.id == _selectedVehicleId)) {
        _selectedVehicleId = _vehicles.first.id;
      }
    } else {
      _selectedVehicleId = null;
    }

    await fetchLogs();
    for (var vehicle in _vehicles) {
      await fetchMaintenanceItems(vehicle.id!);
    }
    await _cleanUpObsoleteItems(); // Remove "Ban Depan/Belakang" if exist
    await checkMaintenanceStatus();
    notifyListeners();
  }

  Future<void> fetchLogs() async {
    _logs = await _dbService.getAllMaintenanceLogs();
    _logs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final id = await _dbService.insertVehicle(vehicle);
    final newVehicle = Vehicle(
      id: id,
      name: vehicle.name,
      type: vehicle.type,
      year: vehicle.year,
      currentOdometer: vehicle.currentOdometer,
    );
    _vehicles.add(newVehicle);
    _maintenanceItems[id] = [];

    // Auto-setup core maintenance items
    await addMaintenanceItem(
      MaintenanceItem(
        vehicleId: id,
        name: 'Oli Mesin',
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: vehicle.currentOdometer,
        intervalDistance: 2000,
        intervalMonth: 2,
        iconCode: 0xe463, // oil_barrel
      ),
    );
    // Keep only Tekanan Ban as requested
    await addMaintenanceItem(
      MaintenanceItem(
        vehicleId: id,
        name: 'Tekanan Ban',
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: vehicle.currentOdometer,
        intervalDistance: 500, // Irrelevant, strictly recurring check
        intervalMonth: 1,
        iconCode: 0xf0289,
      ),
    );
    await addMaintenanceItem(
      MaintenanceItem(
        vehicleId: id,
        name: 'Kampas Rem',
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: vehicle.currentOdometer,
        intervalDistance: 8000,
        intervalMonth: 8,
        iconCode: 0xf89c, // minor_crash - usually used for brakes
      ),
    );
    await addMaintenanceItem(
      MaintenanceItem(
        vehicleId: id,
        name: 'Filter Udara',
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: vehicle.currentOdometer,
        intervalDistance: 10000,
        intervalMonth: 12,
        iconCode: 0xf552, // air
      ),
    );
    await addMaintenanceItem(
      MaintenanceItem(
        vehicleId: id,
        name: vehicle.type == VehicleType.motor ? 'Rantai / CVT' : 'Fan Belt',
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: vehicle.currentOdometer,
        intervalDistance: 15000,
        intervalMonth: 18,
        iconCode: 0xf895, // settings_suggest (gear)
      ),
    );
    await addMaintenanceItem(
      MaintenanceItem(
        vehicleId: id,
        name: 'Aki',
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: vehicle.currentOdometer,
        intervalDistance: 15000,
        intervalMonth: 18,
        iconCode: 0xf5a2, // battery_charging_full
      ),
    );

    notifyListeners();
  }

  Future<void> updateOdometer(int vehicleId, double newOdometer) async {
    int index = _vehicles.indexWhere((v) => v.id == vehicleId);

    if (index == -1) {
      print('Error: Vehicle not found with id: $vehicleId');
      return;
    }

    Vehicle v = _vehicles[index];
    double added = newOdometer - v.currentOdometer;

    // Create updated vehicle
    Vehicle updated = Vehicle(
      id: v.id,
      name: v.name,
      type: v.type,
      year: v.year,
      currentOdometer: newOdometer,
    );

    try {
      // Update database first and wait for completion
      await _dbService.updateVehicle(updated);

      // Update local state only after database update succeeds
      _vehicles[index] = updated;

      // Log Distance (Spec 4.3 & 7)
      if (added > 0) {
        final dateStr = DateTime.now().toIso8601String();
        await _dbService.insertDistanceLog(
          vehicleId,
          dateStr,
          v.currentOdometer,
          newOdometer,
          added,
        );

        // Update local state for HistoryScreen
        if (!_distanceLogs.containsKey(vehicleId)) {
          _distanceLogs[vehicleId] = [];
        }
        _distanceLogs[vehicleId]!.insert(0, {
          'date': dateStr,
          'previousOdometer': v.currentOdometer,
          'newOdometer': newOdometer,
          'addedDistance': added,
        });
      }

      // Check for maintenance alerts after odometer update
      await checkMaintenanceStatus();

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print('Error updating odometer: $e');
      // Revert local state if database update failed
      rethrow;
    }
  }

  Future<void> fetchMaintenanceItems(int vehicleId) async {
    final items = await _dbService.getMaintenanceItems(vehicleId);
    _maintenanceItems[vehicleId] = items;
    await fetchDistanceLogs(vehicleId);
    notifyListeners();
  }

  Future<void> fetchDistanceLogs(int vehicleId) async {
    final logs = await _dbService.getDistanceLogs(vehicleId);
    _distanceLogs[vehicleId] = logs;
    notifyListeners(); // Careful, this might trigger rebuilds during loop
  }

  Future<void> logMaintenance(MaintenanceLog log) async {
    await _dbService.insertMaintenanceLog(log);
    _logs.insert(0, log); // Update local state

    // Find vehicleId from maintenanceItemId
    int? vehicleId;
    _maintenanceItems.forEach((vid, items) {
      if (items.any((i) => i.id == log.maintenanceItemId)) {
        vehicleId = vid; // Found the vehicle
      }
    });

    if (vehicleId != null) {
      await fetchMaintenanceItems(vehicleId!);
    }

    notifyListeners();
  }

  Future<void> resetData() async {
    await _dbService.clearAllData();
    _vehicles = [];
    _maintenanceItems = {};
    _logs = [];
    _distanceLogs = {};
    _selectedVehicleId = null;
    _username = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');

    notifyListeners();
  }

  Future<void> addMaintenanceItem(MaintenanceItem item) async {
    final id = await _dbService.insertMaintenanceItem(item);
    final newItem = MaintenanceItem(
      id: id,
      vehicleId: item.vehicleId,
      name: item.name,
      lastServiceDate: item.lastServiceDate,
      lastServiceOdometer: item.lastServiceOdometer,
      intervalDistance: item.intervalDistance,
      intervalMonth: item.intervalMonth,
    );
    if (_maintenanceItems.containsKey(item.vehicleId)) {
      _maintenanceItems[item.vehicleId]!.add(newItem);
    } else {
      _maintenanceItems[item.vehicleId] = [newItem];
    }
    notifyListeners();
  }

  List<MaintenanceItem> getItemsForVehicle(int vehicleId) {
    return _maintenanceItems[vehicleId] ?? [];
  }

  bool hasMaintenanceItem(int vehicleId, String name) {
    final items = getItemsForVehicle(vehicleId);
    return items.any((item) => item.name.toLowerCase() == name.toLowerCase());
  }

  MaintenanceStatus getStatus(MaintenanceItem item, double currentOdometer) {
    double health = getItemHealth(item, currentOdometer);

    if (health <= 0.1) {
      return MaintenanceStatus.wajibGanti;
    } else if (health <= 0.3) {
      return MaintenanceStatus.mendekati;
    } else {
      return MaintenanceStatus.aman;
    }
  }

  double getItemHealth(MaintenanceItem item, double currentOdometer) {
    // Defensive check: distance
    double distProgress = 1.0;
    if (item.intervalDistance > 0) {
      double distanceDiff = currentOdometer - item.lastServiceOdometer;
      distProgress = 1.0 - (distanceDiff / item.intervalDistance);
    }

    // Defensive check: time
    double timeProgress = 1.0;
    if (item.intervalMonth > 0) {
      int daysPassed = DateTime.now().difference(item.lastServiceDate).inDays;
      timeProgress = 1.0 - (daysPassed / (item.intervalMonth * 30));
    }

    // Use whichever is lower (more critical)
    double health = distProgress < timeProgress ? distProgress : timeProgress;
    return health.clamp(0.0, 1.0);
  }

  Color getItemHealthColor(double health) {
    if (health > 0.5) return const Color(0xFF34C759); // iosGreen
    if (health > 0.2) return const Color(0xFFFF9500); // iosOrange
    return const Color(0xFFFF3B30); // iosRed
  }

  double calculateHealthScore(int vehicleId) {
    final items = getItemsForVehicle(vehicleId);
    if (items.isEmpty) return 100.0;

    double totalScore = 0;
    final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);

    for (var item in items) {
      final status = getStatus(item, vehicle.currentOdometer);
      if (status == MaintenanceStatus.aman) {
        totalScore += 100;
      } else if (status == MaintenanceStatus.mendekati) {
        totalScore += 50;
      } else {
        totalScore += 0;
      }
    }

    return totalScore / items.length;
  }

  Future<void> updateMaintenanceItem(
    int id, {
    String? name,
    double? intervalDistance,
    DateTime? lastServiceDate,
    double? lastServiceOdometer,
    String? oilBrand,
    String? oilVolume,
  }) async {
    // Find the item and its vehicleId
    int vehicleId = -1;
    MaintenanceItem? oldItem;
    for (var vid in _maintenanceItems.keys) {
      final idx = _maintenanceItems[vid]!.indexWhere((i) => i.id == id);
      if (idx != -1) {
        vehicleId = vid;
        oldItem = _maintenanceItems[vid]![idx];
        break;
      }
    }

    if (oldItem != null && vehicleId != -1) {
      final newItem = MaintenanceItem(
        id: oldItem.id,
        vehicleId: oldItem.vehicleId,
        name: name ?? oldItem.name,
        lastServiceDate: lastServiceDate ?? oldItem.lastServiceDate,
        lastServiceOdometer: lastServiceOdometer ?? oldItem.lastServiceOdometer,
        intervalDistance: intervalDistance ?? oldItem.intervalDistance,
        intervalMonth: oldItem.intervalMonth,
        iconCode: oldItem.iconCode,
        oilBrand: oilBrand ?? oldItem.oilBrand,
        oilVolume: oilVolume ?? oldItem.oilVolume,
      );

      await _dbService.updateMaintenanceItem(newItem);

      // Update local state
      final itemIdx = _maintenanceItems[vehicleId]!.indexWhere(
        (i) => i.id == id,
      );
      _maintenanceItems[vehicleId]![itemIdx] = newItem;

      notifyListeners();
    }
  }

  MaintenanceLog? getLatestLogForItem(int itemId) {
    try {
      return _logs.firstWhere((log) => log.maintenanceItemId == itemId);
    } catch (_) {
      return null;
    }
  }

  Future<void> completeMaintenance(
    int itemId,
    String notes, {
    String? oilBrand,
    String? oilVolume,
    double? customOdometer,
  }) async {
    // Find item
    int vehicleId = -1;
    MaintenanceItem? item;
    for (var vid in _maintenanceItems.keys) {
      final idx = _maintenanceItems[vid]!.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        vehicleId = vid;
        item = _maintenanceItems[vid]![idx];
        break;
      }
    }

    if (item != null && vehicleId != -1) {
      final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);
      final completionOdometer = customOdometer ?? vehicle.currentOdometer;

      // Update item
      final updatedItem = MaintenanceItem(
        id: item.id,
        vehicleId: item.vehicleId,
        name: item.name,
        lastServiceDate: DateTime.now(),
        lastServiceOdometer: completionOdometer,
        intervalDistance: item.intervalDistance,
        intervalMonth: item.intervalMonth,
        iconCode: item.iconCode,
      );

      await _dbService.updateMaintenanceItem(updatedItem);

      // Update local state
      final itemIdx = _maintenanceItems[vehicleId]!.indexWhere(
        (i) => i.id == itemId,
      );
      _maintenanceItems[vehicleId]![itemIdx] = updatedItem;

      // Add log
      final log = MaintenanceLog(
        maintenanceItemId: itemId,
        date: DateTime.now(),
        odometer: completionOdometer,
        notes: notes,
        oilBrand: oilBrand,
        oilVolume: oilVolume,
      );
      await _dbService.insertMaintenanceLog(log);
      _logs.insert(0, log);

      notifyListeners();
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    await _dbService.deleteVehicle(vehicleId);
    _vehicles.removeWhere((v) => v.id == vehicleId);
    _maintenanceItems.remove(vehicleId);
    notifyListeners();
  }

  Future<void> deleteMaintenanceItem(int itemId) async {
    await _dbService.deleteMaintenanceItem(itemId);
    for (var vid in _maintenanceItems.keys) {
      _maintenanceItems[vid]!.removeWhere((i) => i.id == itemId);
    }
    notifyListeners();
  }

  MaintenanceItem? getMaintenanceItemByName(int vehicleId, String name) {
    if (!_maintenanceItems.containsKey(vehicleId)) return null;
    try {
      return _maintenanceItems[vehicleId]!.firstWhere(
        (i) => i.name.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  MaintenanceItem? getMaintenanceItemById(int id) {
    for (var items in _maintenanceItems.values) {
      try {
        return items.firstWhere((i) => i.id == id);
      } catch (_) {
        // Continue searching
      }
    }
    return null;
  }

  String getMaintenanceStatusText(int vehicleId, String itemName) {
    final item = getMaintenanceItemByName(vehicleId, itemName);
    if (item == null) return 'Belum diatur';

    final vehicle = _vehicles.firstWhere((v) => v.id == vehicleId);

    // Distance calculation
    final distanceDiff = vehicle.currentOdometer - item.lastServiceOdometer;
    final distRemaining = item.intervalDistance - distanceDiff;

    // Time calculation
    final diffDays = DateTime.now().difference(item.lastServiceDate).inDays;
    final totalDaysAvailable = item.intervalMonth * 30;
    final daysRemaining = totalDaysAvailable - diffDays;

    // Determine which status to display based on urgency
    if (distRemaining <= 0 || daysRemaining <= 0) {
      return 'WAJIB GANTI';
    }

    // If it's a "Tekanan Ban" or similar time-sensitive item, prefer showing days
    // or if the time is closer than the distance proportional to their intervals
    double distProgress = distRemaining / item.intervalDistance;
    double timeProgress = daysRemaining / totalDaysAvailable;

    if (timeProgress < distProgress) {
      if (daysRemaining < 7) return '$daysRemaining hari lagi';
      final weeks = (daysRemaining / 7).floor();
      if (weeks < 4) return '$weeks minggu lagi';
      return '${(daysRemaining / 30).floor()} bulan lagi';
    }

    return '${distRemaining.toInt()} km lagi';
  }

  Future<void> checkMaintenanceStatus() async {
    if (_vehicles.isEmpty) return;

    // Only check for the primary/first vehicle for now to avoid spam
    final vehicle = _vehicles.first;
    final items = await getItemsForVehicle(vehicle.id!);

    for (var item in items) {
      final status = getStatus(item, vehicle.currentOdometer);
      if (status == MaintenanceStatus.wajibGanti) {
        NotificationService().showNotification(
          id: item.id ?? 0,
          title: 'Perawatan Diperlukan!',
          body:
              '${item.name} pada ${vehicle.name} perlu segera diganti/servis.',
        );
      } else if (status == MaintenanceStatus.mendekati) {
        // Optional: reduce frequency for "Approaching"
      }
    }
  }

  MaintenanceItem? getOilItem(int vehicleId) =>
      getMaintenanceItemByName(vehicleId, 'oli');
  String getOilStatusText(int vehicleId) =>
      getMaintenanceStatusText(vehicleId, 'oli');

  Future<void> _cleanUpObsoleteItems() async {
    bool changed = false;
    for (var vehicleId in _maintenanceItems.keys) {
      final toRemove = _maintenanceItems[vehicleId]!.where((item) {
        final name = item.name.toLowerCase();
        return name == 'ban depan' || name == 'ban belakang';
      }).toList();

      for (var item in toRemove) {
        if (item.id != null) {
          await _dbService.deleteMaintenanceItem(item.id!);
          _maintenanceItems[vehicleId]!.remove(item);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }
}
