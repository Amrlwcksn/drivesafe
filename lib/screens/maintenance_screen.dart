import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import 'edit_maintenance_screen.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return const Center(child: Text('Belum ada kendaraan.'));
          }
          final vehicle = provider.selectedVehicle;
          if (vehicle == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final vehicleId = vehicle.id!;
          final items = provider.getItemsForVehicle(vehicleId);
          final currentOdo = vehicle.currentOdometer;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              final categoryColor = _getCategoryColor(item.name);
              final iconData = _getAestheticIcon(item.name);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMaintenanceScreen(
                          item: item,
                          vehicleId: vehicleId,
                          currentOdometer: currentOdo,
                        ),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(iconData, color: categoryColor, size: 24),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.straighten, size: 12, color: AppTheme.iosGrey),
                      const SizedBox(width: 4),
                      Text(
                        'Interval: ${item.intervalDistance.toInt()} KM',
                        style: const TextStyle(
                          color: AppTheme.iosGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 1.0,
                          color: AppTheme.iosLightGrey,
                          strokeWidth: 4,
                        ),
                        Builder(
                          builder: (context) {
                            double distanceDiff =
                                currentOdo - item.lastServiceOdometer;
                            double progress =
                                1.0 - (distanceDiff / item.intervalDistance);
                            progress = progress.clamp(0.0, 1.0);

                            Color dynamicColor;
                            if (progress > 0.5) {
                              dynamicColor = AppTheme.iosGreen;
                            } else if (progress > 0.2) {
                              dynamicColor = AppTheme.iosOrange;
                            } else {
                              dynamicColor = AppTheme.iosRed;
                            }

                            return CircularProgressIndicator(
                              value: progress,
                              color: dynamicColor,
                              strokeWidth: 4,
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic would go here
        },
        backgroundColor: AppTheme.iosBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getAestheticIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('oli') || n.contains('oil')) return Icons.oil_barrel_rounded;
    if (n.contains('ban') || n.contains('tire'))
      return Icons.tire_repair_rounded;
    if (n.contains('rem') || n.contains('brake'))
      return Icons.album; // Disc brake look-alike
    if (n.contains('aki') || n.contains('battery'))
      return Icons.battery_charging_full_rounded;
    if (n.contains('filter')) return Icons.air_rounded;
    if (n.contains('busi') || n.contains('spark'))
      return Icons.flash_on_rounded;
    if (n.contains('rantai') ||
        n.contains('chain') ||
        n.contains('cvt') ||
        n.contains('gir') ||
        n.contains('gear'))
      return Icons.settings_rounded; // Gear icon
    if (n.contains('radiator') || n.contains('coolant'))
      return Icons.ac_unit_rounded;
    return Icons.build_circle_rounded;
  }

  Color _getCategoryColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('oli') || n.contains('oil')) return Colors.orange;
    if (n.contains('ban') || n.contains('tire')) return Colors.blue;
    if (n.contains('rem') || n.contains('brake')) return Colors.red;
    if (n.contains('aki') || n.contains('battery')) return Colors.purple;
    if (n.contains('filter')) return Colors.teal;
    if (n.contains('busi') || n.contains('spark')) return Colors.amber;
    if (n.contains('rantai') || n.contains('chain')) return Colors.brown;
    if (n.contains('gir') || n.contains('gear')) return Colors.blueGrey;
    return AppTheme.iosBlue;
  }
}
