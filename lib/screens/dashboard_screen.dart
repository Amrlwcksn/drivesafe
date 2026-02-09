import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'edit_maintenance_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getScaffoldDecoration(context),
      child: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.no_crash,
                        size: 64,
                        color: AppTheme.iosGrey,
                      ),
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
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const Text('Tambah Kendaraan'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final vehicle = provider.selectedVehicle;
          if (vehicle == null) {
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final items = provider.getItemsForVehicle(vehicle.id!);
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
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, provider, vehicle),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildOdometerAction(context, vehicle, provider),
                        const SizedBox(height: 16),
                        _buildStatusHero(
                          context,
                          isHealthy,
                          criticalItems.length,
                          warningItems.length,
                        ),
                        const SizedBox(height: 16),
                        GlassContainer(
                          padding: const EdgeInsets.all(12),
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : AppTheme.iosBlue.withOpacity(0.04),
                          borderColor: isDark
                              ? Colors.white.withOpacity(0.05)
                              : AppTheme.iosBlue.withOpacity(0.08),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: isDark
                                    ? AppTheme.iosBlue
                                    : AppTheme.iosBlue.withOpacity(0.7),
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Aplikasi hanya alat bantu. Selalu cek kondisi fisik kendaraan secara langsung sebelum berkendara.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withOpacity(0.5),
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
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
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    VehicleProvider provider,
    Vehicle vehicle,
  ) {
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: Colors.transparent, // Transparent for gradient
      elevation: 0,
      floating: true,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${provider.username}',
            style: const TextStyle(
              color: AppTheme.iosGrey,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
          if (provider.vehicles.length > 1)
            PopupMenuButton<int>(
              onSelected: (int id) {
                provider.selectVehicle(id);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vehicle.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.iosBlue,
                    size: 20,
                  ),
                ],
              ),
              itemBuilder: (BuildContext context) {
                return provider.vehicles.map((v) {
                  return PopupMenuItem<int>(
                    value: v.id,
                    child: Text(
                      v.name,
                      style: TextStyle(
                        fontWeight: v.id == vehicle.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: v.id == vehicle.id
                            ? AppTheme.iosBlue
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList();
              },
            )
          else
            Text(
              vehicle.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          icon: provider.profilePhotoPath != null
              ? CircleAvatar(
                  backgroundImage: FileImage(File(provider.profilePhotoPath!)),
                )
              : CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: AppTheme.iosBlue,
                  child: const Icon(Icons.person),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusHero(
    BuildContext context,
    bool isHealthy,
    int criticalCount,
    int warningCount,
  ) {
    Color bgColor = isHealthy
        ? AppTheme.iosGreen
        : (criticalCount > 0 ? AppTheme.iosRed : Colors.orange);
    String title = isHealthy
        ? 'Semua Komponen Aman'
        : (criticalCount > 0 ? 'Perhatian Diperlukan' : 'Perawatan Mendekati');
    String subtitle = isHealthy
        ? 'Siap berkendara! Kendaraan dalam kondisi prima.'
        : '$criticalCount komponen wajib ganti, $warningCount mendekati jadwal.';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(isDark ? 0.35 : 0.75),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(isDark ? 0.15 : 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              bgColor.withOpacity(isDark ? 0.4 : 0.8),
              bgColor.withOpacity(isDark ? 0.2 : 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                isHealthy
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                size: 140,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
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
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withOpacity(0.1),
                    borderColor: Colors.white.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOdometerAction(
    BuildContext context,
    Vehicle vehicle,
    VehicleProvider provider,
  ) {
    final formatter = NumberFormat('#,###');

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.iosBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: AppTheme.iosBlue,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'JARAK TEMPUH',
                style: TextStyle(
                  color: AppTheme.iosGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatter.format(vehicle.currentOdometer.toInt()),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'KM',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showUpdateOdoDialog(context, provider, vehicle),
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.iosBlue.withOpacity(0.1),
                        foregroundColor: AppTheme.iosBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          AppTheme.iosBlue.withOpacity(0.1),
                        ),
                      ),
                  child: const Text(
                    'Update',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
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

    final progress = provider.getItemHealth(item, vehicle.currentOdometer);
    final dynamicColor = provider.getItemHealthColor(progress);

    return GestureDetector(
      onTap: () {
        _showItemDetailDialog(context, item, provider, vehicle);
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    iconData,
                    color: dynamicColor.withOpacity(0.15),
                    size: 40,
                  ),
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
                    child: Icon(iconData, color: dynamicColor, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 4,
                width: 60,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: dynamicColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(dynamicColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.getMaintenanceStatusText(vehicle.id!, item.name),
              style: TextStyle(
                color: status == MaintenanceStatus.aman
                    ? AppTheme.iosGrey
                    : statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
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
    if (n.contains('oli') || n.contains('oil')) return Icons.oil_barrel_rounded;
    if (n.contains('ban') || n.contains('tire'))
      return Icons.tire_repair_rounded;
    if (n.contains('rem') || n.contains('brake')) return Icons.album_rounded;
    if (n.contains('aki') || n.contains('battery'))
      return Icons.battery_charging_full_rounded;
    if (n.contains('filter') || n.contains('air')) return Icons.air_rounded;
    if (n.contains('busi') || n.contains('spark'))
      return Icons.flash_on_rounded;
    if (n.contains('rantai') ||
        n.contains('chain') ||
        n.contains('cvt') ||
        n.contains('gir') ||
        n.contains('gear'))
      return Icons.settings_rounded;
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
    final progress = provider.getItemHealth(item, vehicle.currentOdometer);
    final diffDays = DateTime.now().difference(item.lastServiceDate).inDays;

    String healthDesc = 'Sangat Baik';
    if (progress < 0.2)
      healthDesc = 'Kritis (Segera Ganti)';
    else if (progress < 0.5)
      healthDesc = 'Perhatian';
    else if (progress < 0.8)
      healthDesc = 'Baik';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Icon(
                      _getAestheticIcon(item.name),
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).hintColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'KONDISI SAAT INI',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          healthDesc,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% Health Score',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    remainingText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: statusColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 24),
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                context,
                'Interval Servis',
                '${NumberFormat('#,###').format(item.intervalDistance)} KM',
              ),
              _buildInfoRow(
                context,
                'Terakhir Servis',
                '${DateFormat('dd MMM yyyy').format(item.lastServiceDate)}',
              ),
              _buildInfoRow(
                context,
                'KM Terakhir',
                '${NumberFormat('#,###').format(item.lastServiceOdometer)} KM',
              ),
              _buildInfoRow(context, 'Usia Pemakaian', '$diffDays Hari'),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: Theme.of(context).hintColor,
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Service',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight
                  ? AppTheme.iosBlue
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
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
