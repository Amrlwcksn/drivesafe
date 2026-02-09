import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: AppTheme.getScaffoldDecoration(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Riwayat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: const TabBar(
              labelColor: AppTheme.iosBlue,
              unselectedLabelColor: AppTheme.iosGrey,
              indicatorColor: AppTheme.iosBlue,
              tabs: [
                Tab(text: 'Perawatan'),
                Tab(text: 'Jarak Tempuh'),
              ],
            ),
          ),
          body: Consumer<VehicleProvider>(
            builder: (context, provider, child) {
              return TabBarView(
                children: [
                  _buildMaintenanceLogs(provider.selectedVehicleLogs, provider),
                  _buildDistanceLogs(
                    provider.distanceLogs,
                  ), // New getter already returns filtered
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceLogs(List<dynamic> logs, VehicleProvider provider) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat perawatan.',
          style: TextStyle(color: AppTheme.iosGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.iosBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForName(
                    provider
                            .getMaintenanceItemById(log.maintenanceItemId)
                            ?.name ??
                        '',
                  ),
                  color: AppTheme.iosBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider
                              .getMaintenanceItemById(log.maintenanceItemId)
                              ?.name ??
                          'Komponen Terhapus',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(log.date)} • ${log.odometer.toInt()} KM',
                      style: const TextStyle(
                        color: AppTheme.iosGrey,
                        fontSize: 12,
                      ),
                    ),
                    if (log.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(log.notes, style: const TextStyle(fontSize: 13)),
                    ],
                    if (log.oilBrand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Oli: ${log.oilBrand} (${log.oilVolume ?? "-"} ml)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDistanceLogs(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat jarak tempuh.',
          style: TextStyle(color: AppTheme.iosGrey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final date = DateTime.parse(log['date']);
        final added = (log['addedDistance'] as num).toDouble();
        final newOdo = (log['newOdometer'] as num).toDouble();

        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.speed, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Posisi: ${newOdo.toInt()} KM',
                      style: const TextStyle(
                        color: AppTheme.iosGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${added.toInt()} KM',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('oli') || n.contains('oil')) return Icons.water_drop_rounded;
    if (n.contains('ban') || n.contains('tire'))
      return Icons.tire_repair_rounded;
    if (n.contains('rem') || n.contains('brake')) {
      return Icons.settings_backup_restore_rounded;
    }
    if (n.contains('aki') || n.contains('battery')) {
      return Icons.battery_charging_full_rounded;
    }
    if (n.contains('filter') || n.contains('air')) return Icons.air_rounded;
    if (n.contains('busi') || n.contains('spark'))
      return Icons.flash_on_rounded;
    if (n.contains('rantai') || n.contains('chain')) return Icons.link_rounded;
    if (n.contains('gir') || n.contains('gear')) {
      return Icons.settings_suggest_rounded;
    }
    if (n.contains('radiator') || n.contains('coolant')) {
      return Icons.ac_unit_rounded;
    }
    return Icons.build_circle_rounded;
  }
}
