import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivesafe'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return _buildEmptyState();
          }

          final vehicle = provider.vehicles.first;
          final items = provider.getItemsForVehicle(vehicle.id!);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Odometer Section
                    _buildOdometerCard(context, vehicle, provider),
                    const SizedBox(height: 24),
                    const Text(
                      'RINGKASAN KENDARAAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.iosGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85, // More vertical cards
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildSummaryCard(
                      context,
                      items[index],
                      vehicle.currentOdometer,
                      provider,
                    );
                  }, childCount: items.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOdometerCard(
    BuildContext context,
    Vehicle vehicle,
    VehicleProvider provider,
  ) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ODOMETER',
                    style: TextStyle(
                      color: AppTheme.iosGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _showUpdateOdoDialog(context, provider, vehicle),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        color: AppTheme.iosBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.decimalPattern().format(
                      vehicle.currentOdometer,
                    ),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      'KM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.iosGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: -20,
          bottom: -20,
          child: Opacity(
            opacity: 0.05,
            child: Icon(
              vehicle.type == VehicleType.motor
                  ? Icons.motorcycle_rounded
                  : Icons.directions_car_rounded,
              size: 120,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    MaintenanceItem item,
    double currentOdometer,
    VehicleProvider provider,
  ) {
    final distanceRemaining =
        item.intervalDistance - (currentOdometer - item.lastServiceOdometer);
    final monthsPassed =
        DateTime.now().difference(item.lastServiceDate).inDays ~/ 30;

    // Determine which limit is closer (%)
    final distanceProgress =
        (currentOdometer - item.lastServiceOdometer) / item.intervalDistance;
    final timeProgress = monthsPassed / item.intervalMonth;
    final isDistanceCloser = distanceProgress >= timeProgress;

    final iconData = _getAestheticIcon(item.name);
    final categoryColor = _getCategoryColor(item.name);
    final status = provider.getStatus(item, currentOdometer);
    final statusColor = AppTheme.getStatusColor(status);

    return InkWell(
      onTap: () =>
          _showMaintenanceInfoDialog(context, item, provider, currentOdometer),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: categoryColor,
                size: 32, // Larger icon
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDistanceCloser ? Icons.speed : Icons.calendar_month,
                  size: 13,
                  color: AppTheme.iosGrey,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    distanceRemaining <= 0
                        ? 'Servis!'
                        : '${(distanceRemaining / 1000).toStringAsFixed(1)}k KM',
                    style: TextStyle(
                      color: distanceRemaining <= 0
                          ? AppTheme.iosRed
                          : AppTheme.iosGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Minimalist health dot
            Container(
              width: 24,
              height: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateOdoDialog(
    BuildContext context,
    VehicleProvider provider,
    Vehicle vehicle,
  ) {
    final controller = TextEditingController(
      text: vehicle.currentOdometer.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Odometer'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'KM'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                provider.updateOdometer(vehicle.id!, val);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Belum ada kendaraan.'));
  }

  void _showMaintenanceInfoDialog(
    BuildContext context,
    MaintenanceItem item,
    VehicleProvider provider,
    double currentOdo,
  ) {
    final status = provider.getStatus(item, currentOdo);
    final statusColor = AppTheme.getStatusColor(status);
    final remaining =
        item.intervalDistance - (currentOdo - item.lastServiceOdometer);
    final lastServiceDate = DateFormat(
      'dd MMM yyyy',
    ).format(item.lastServiceDate);

    final iconData = _getAestheticIcon(item.name);
    final categoryColor = _getCategoryColor(item.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.iosLightGrey,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: categoryColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        remaining <= 0 ? 'STATUS: WAJIB GANTI' : 'STATUS: AMAN',
                        style: TextStyle(
                          color: remaining <= 0
                              ? AppTheme.iosRed
                              : AppTheme.iosGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow(
              Icons.calendar_month,
              'Terakhir Servis',
              lastServiceDate,
            ),
            _buildInfoRow(
              Icons.history,
              'Odo Terakhir',
              '${item.lastServiceOdometer.toInt()} KM',
            ),
            _buildInfoRow(
              Icons.straighten,
              'Interval Servis',
              '${item.intervalDistance.toInt()} KM',
            ),
            _buildInfoRow(
              Icons.timer,
              'Sisa Jarak',
              remaining <= 0 ? '0 KM' : '${remaining.toInt()} KM',
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Ubah data melalui menu Maintenance',
                style: TextStyle(
                  color: AppTheme.iosGrey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.iosBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAestheticIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('oli') || n.contains('oil')) return Icons.opacity_rounded;
    if (n.contains('ban') || n.contains('tire'))
      return Icons.tire_repair_rounded;
    if (n.contains('rem') || n.contains('brake'))
      return Icons.settings_backup_restore_rounded;
    if (n.contains('aki') || n.contains('battery'))
      return Icons.battery_charging_full_rounded;
    if (n.contains('filter')) return Icons.air_rounded;
    if (n.contains('busi') || n.contains('spark'))
      return Icons.flash_on_rounded;
    if (n.contains('rantai') || n.contains('chain')) return Icons.link_rounded;
    if (n.contains('gir') || n.contains('gear'))
      return Icons.settings_suggest_rounded;
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.iosGrey.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppTheme.iosGrey, fontSize: 15),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
