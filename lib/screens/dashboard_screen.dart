import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../theme/app_theme.dart';
import 'add_maintenance_screen.dart';
import 'edit_maintenance_screen.dart';
import 'profile_screen.dart'; // Ensure this import exists or pointing to correct file

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        if (provider.vehicles.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.iosLightGrey,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_crash, size: 64, color: AppTheme.iosGrey),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada kendaraan',
                    style: TextStyle(color: AppTheme.iosGrey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProfileScreen(), // Redirect to profile to add vehicle
                        ),
                      );
                    },
                    child: const Text('Tambah Kendaraan'),
                  ),
                ],
              ),
            ),
          );
        }

        final vehicle = provider.vehicles.first;
        final items = provider.getItemsForVehicle(vehicle.id!);
        // Calculate status counts
        final criticalItems = items
            .where(
              (i) =>
                  provider.getStatus(i, vehicle.currentOdometer) ==
                  MaintenanceStatus.wajibGanti,
            )
            .toList();
        final warningItems = items
            .where(
              (i) =>
                  provider.getStatus(i, vehicle.currentOdometer) ==
                  MaintenanceStatus.mendekati,
            )
            .toList();

        final isHealthy = criticalItems.isEmpty && warningItems.isEmpty;

        return Scaffold(
          backgroundColor: AppTheme.iosLightGrey,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, provider.username, vehicle),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 1. Status Hero Card
                      _buildStatusHero(
                        isHealthy,
                        criticalItems.length,
                        warningItems.length,
                      ),
                      const SizedBox(height: 16),
                      // 2. Odometer Action
                      _buildOdometerAction(context, vehicle, provider),
                      const SizedBox(height: 24),
                      // 3. Maintenance Grid Header
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'KOMPONEN',
                          style: TextStyle(
                            color: AppTheme.iosGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              // 4. Maintenance Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0, // Square aesthetic
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return _buildGridItem(context, item, provider, vehicle);
                  }, childCount: items.length),
                ),
              ),
            ],
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
        );
      },
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    String username,
    Vehicle vehicle,
  ) {
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: AppTheme.iosLightGrey,
      elevation: 0,
      floating: true,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $username',
            style: const TextStyle(
              color: AppTheme.iosGrey,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Row(
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.iosBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppTheme.iosGrey),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatusHero(bool isHealthy, int criticalCount, int warningCount) {
    Color bgColor = isHealthy
        ? AppTheme.iosGreen
        : (criticalCount > 0 ? AppTheme.iosRed : Colors.orange);
    String title = isHealthy
        ? 'Semua Sistem Aman'
        : (criticalCount > 0 ? 'Perhatian Diperlukan' : 'Perawatan Mendekati');
    String subtitle = isHealthy
        ? 'Siap berkendara! Kendaraan dalam kondisi prima.'
        : '$criticalCount komponen wajib ganti, $warningCount mendekati jadwal.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy ? Icons.check_circle : Icons.warning_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerAction(
    BuildContext context,
    Vehicle vehicle,
    VehicleProvider provider,
  ) {
    final formatter = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JARAK TEMPUH',
                  style: TextStyle(
                    color: AppTheme.iosGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatter.format(vehicle.currentOdometer.toInt()),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        'KM',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.iosGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showUpdateOdoDialog(context, provider, vehicle),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.iosLightGrey,
              foregroundColor: AppTheme.iosBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    MaintenanceItem item,
    VehicleProvider provider,
    Vehicle vehicle,
  ) {
    final status = provider.getStatus(item, vehicle.currentOdometer);
    final statusColor = AppTheme.getStatusColor(status);
    final iconData = _getAestheticIcon(item.name);

    // Calculate progress (1.0 = fresh, 0.0 = expired)
    double distanceDiff = vehicle.currentOdometer - item.lastServiceOdometer;
    double progress = 1.0 - (distanceDiff / item.intervalDistance);
    progress = progress.clamp(0.0, 1.0); // Ensure between 0 and 1

    // Dynamic Color Logic based on Progress
    Color dynamicColor;
    if (progress > 0.5) {
      dynamicColor = AppTheme.iosGreen;
    } else if (progress > 0.2) {
      dynamicColor = AppTheme.iosOrange;
    } else {
      dynamicColor = AppTheme.iosRed;
    }

    return GestureDetector(
      onTap: () {
        _showItemDetailDialog(context, item, provider, vehicle);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Interactive Icon Health Bar
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Skeleton Layer (Grey Background)
                  Icon(
                    iconData,
                    color: AppTheme.iosGrey.withOpacity(
                      0.3,
                    ), // Darker grey for better visibility
                    size: 48,
                  ),
                  // 2. Health Layer (Colored Fill using ShaderMask)
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, dynamicColor],
                        stops: [1.0 - progress, 1.0 - progress],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Icon(
                      iconData,
                      color:
                          dynamicColor, // Color here is overridden by shader, but good for fallback
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              provider.getMaintenanceStatusText(vehicle.id!, item.name),
              style: TextStyle(
                color: status == MaintenanceStatus.aman
                    ? AppTheme.iosGrey
                    : statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAestheticIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('oli') || n.contains('oil')) return Icons.water_drop_rounded;
    if (n.contains('ban') || n.contains('tire'))
      return Icons.tire_repair_rounded;
    if (n.contains('rem') || n.contains('brake'))
      return Icons.settings_backup_restore_rounded;
    if (n.contains('aki') || n.contains('battery'))
      return Icons.battery_charging_full_rounded;
    if (n.contains('filter') || n.contains('air')) return Icons.air_rounded;
    if (n.contains('busi') || n.contains('spark'))
      return Icons.flash_on_rounded;
    if (n.contains('rantai') || n.contains('chain')) return Icons.link_rounded;
    if (n.contains('gir') || n.contains('gear'))
      return Icons.settings_suggest_rounded;
    if (n.contains('radiator') || n.contains('coolant'))
      return Icons.ac_unit_rounded;
    return Icons.build_circle_rounded;
  }

  void _showItemDetailDialog(
    BuildContext context,
    MaintenanceItem item,
    VehicleProvider provider,
    Vehicle vehicle,
  ) {
    final status = provider.getStatus(item, vehicle.currentOdometer);
    final statusColor = AppTheme.getStatusColor(status);
    final remainingText = provider.getMaintenanceStatusText(
      vehicle.id!,
      item.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getAestheticIcon(item.name), color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Status', status.name.toUpperCase(), statusColor),
            const SizedBox(height: 8),
            _buildDialogRow(
              'Interval',
              '${item.intervalDistance.toInt()} KM',
              AppTheme.iosGrey,
            ),
            const SizedBox(height: 8),
            _buildDialogRow('Sisa Jarak', remainingText, Colors.black87),
            const SizedBox(height: 16),
            const Text(
              'Detail Terakhir:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Servis terakhir pada ${DateFormat('dd MMM yyyy').format(item.lastServiceDate)} di ${item.lastServiceOdometer.toInt()} KM.',
              style: const TextStyle(fontSize: 13, color: AppTheme.iosGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: AppTheme.iosGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMaintenanceScreen(
                    item: item,
                    vehicleId: vehicle.id!,
                    currentOdometer: vehicle.currentOdometer,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.iosBlue,
              foregroundColor: Colors.white, // Explicitly set white text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.iosGrey, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showUpdateOdoDialog(
    BuildContext context,
    VehicleProvider provider,
    Vehicle vehicle,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Jarak Tempuh'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Odometer Baru (KM)',
            hintText: 'Contoh: 15000',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newOdo = double.tryParse(controller.text);
              if (newOdo != null) {
                if (newOdo < vehicle.currentOdometer) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Odometer baru tidak boleh lebih kecil!'),
                    ),
                  );
                } else {
                  provider.updateOdometer(vehicle.id!, newOdo);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
