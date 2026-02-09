import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'edit_maintenance_screen.dart';
import 'add_maintenance_screen.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getScaffoldDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Maintenance'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
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

                return GlassContainer(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  padding: EdgeInsets.zero, // ListTile has its own padding
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
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(iconData, color: categoryColor, size: 24),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Interval
                        Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              size: 14,
                              color: AppTheme.iosGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (item.intervalDay > 0 ||
                                      item.name.toLowerCase().contains('ban'))
                                  ? 'Interval: Setiap ${item.intervalDay == 0 ? 1 : item.intervalDay} Hari'
                                  : 'Interval: ${item.intervalDistance.toInt()} KM',
                              style: const TextStyle(
                                color: AppTheme.iosGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Last Service Date & Odometer
                        Row(
                          children: [
                            const Icon(
                              Icons.history,
                              size: 14,
                              color: AppTheme.iosGrey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Servis: ${_formatDate(item.lastServiceDate)} • ${item.lastServiceOdometer.toInt()} KM',
                                style: const TextStyle(
                                  color: AppTheme.iosGrey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Accumulated Distance
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              size: 14,
                              color: AppTheme.iosGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (item.intervalDay > 0 ||
                                      item.name.toLowerCase().contains('ban'))
                                  ? 'Terakhir Cek: ${DateTime.now().difference(item.lastServiceDate).inDays} Hari lalu'
                                  : 'Jarak Tempuh: ${(currentOdo - item.lastServiceOdometer).toInt()} KM',
                              style: TextStyle(
                                color:
                                    (item.intervalDay > 0 ||
                                        item.name.toLowerCase().contains('ban'))
                                    ? AppTheme.iosOrange
                                    : AppTheme.iosBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 32,
                      height: 32,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(
                            value: 1.0,
                            color: AppTheme.iosLightGrey,
                            strokeWidth: 4,
                          ),
                          Builder(
                            builder: (context) {
                              final health = provider.getItemHealth(
                                item,
                                currentOdo,
                              );
                              Color dynamicColor = provider.getItemHealthColor(
                                health,
                              );

                              return CircularProgressIndicator(
                                value: health,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMaintenanceScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.iosBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
