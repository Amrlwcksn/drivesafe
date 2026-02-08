import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';

class VehicleDetailScreen extends StatelessWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          final vehicle = provider.vehicles.firstWhere(
            (v) => v.id == vehicleId,
            orElse: () => Vehicle(
              name: '',
              type: VehicleType.motor,
              year: 0,
              currentOdometer: 0,
            ),
          );

          if (vehicle.name.isEmpty) {
            return const Center(child: Text('Kendaraan tidak ditemukan'));
          }

          final items = provider.getItemsForVehicle(vehicleId);
          final sortedItems = List<MaintenanceItem>.from(items)
            ..sort((a, b) {
              final aIsOil = a.name.toLowerCase().contains('oli');
              final bIsOil = b.name.toLowerCase().contains('oli');
              if (aIsOil && !bIsOil) return -1;
              if (!aIsOil && bIsOil) return 1;
              return 0;
            });
          final healthScore = provider.calculateHealthScore(vehicleId);

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(
                  vehicle.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_road),
                    onPressed: () => _showUpdateOdometerDialog(context),
                    tooltip: 'Update Odometer',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDeleteVehicle(context, provider),
                    tooltip: 'Hapus Kendaraan',
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(vehicle, healthScore),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.build_circle_outlined,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Daftar Perawatan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (items.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada item perawatan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = sortedItems[index];
                      final status = provider.getStatus(
                        item,
                        vehicle.currentOdometer,
                      );
                      return _buildMaintenanceCardWrapper(
                        context,
                        provider,
                        item,
                        status,
                        vehicle.currentOdometer,
                      );
                    }, childCount: sortedItems.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        label: const Text('Tambah Item'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _confirmDeleteVehicle(BuildContext context, VehicleProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kendaraan?'),
        content: const Text(
          'Seluruh data perawatan untuk kendaraan ini juga akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteVehicle(vehicleId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCardWrapper(
    BuildContext context,
    VehicleProvider provider,
    MaintenanceItem item,
    MaintenanceStatus status,
    double odo,
  ) {
    return Dismissible(
      key: Key('item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteMaintenanceItem(item.id!);
      },
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Item?'),
            content: Text('Hapus "${item.name}" dari daftar perawatan?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
      },
      child: _buildMaintenanceCard(context, item, status, odo),
    );
  }

  Widget _buildHeader(Vehicle vehicle, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildHeaderStat(
              icon: Icons.speed,
              label: 'ODOMETER',
              value: '${vehicle.currentOdometer.toInt()}',
              unit: 'km',
              color: Colors.blueAccent,
            ),
          ),
          Container(height: 40, width: 1, color: Colors.white10),
          Expanded(
            child: _buildHeaderStat(
              icon: Icons.favorite,
              label: 'KESEHATAN',
              value: '${score.toInt()}',
              unit: '%',
              color: _getScoreColor(score),
            ),
          ),
          Container(height: 40, width: 1, color: Colors.white10),
          Expanded(
            child: _buildHeaderStat(
              icon: Icons.calendar_month,
              label: 'TAHUN',
              value: '${vehicle.year}',
              unit: '',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(
    BuildContext context,
    MaintenanceItem item,
    MaintenanceStatus status,
    double currentOdometer,
  ) {
    final distanceDiff = currentOdometer - item.lastServiceOdometer;
    final progress = (distanceDiff / item.intervalDistance).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconData(item.iconCode, fontFamily: 'MaterialIcons'),
                    color: AppTheme.getStatusColor(status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: AppTheme.getStatusColor(status),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubStat(
                  'Terakhir',
                  '${item.lastServiceOdometer.toInt()} km',
                ),
                _buildSubStat(
                  'Interval',
                  '${item.intervalDistance.toInt()} km',
                ),
                _buildSubStat(
                  'Sisa',
                  '${(item.intervalDistance - distanceDiff).toInt()} km',
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCompleteMaintenanceDialog(context, item),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Selesaikan Perawatan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getStatusColor(
                    status,
                  ).withOpacity(0.15),
                  foregroundColor: AppTheme.getStatusColor(status),
                  elevation: 0,
                  side: BorderSide(
                    color: AppTheme.getStatusColor(status).withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteMaintenanceDialog(
    BuildContext context,
    MaintenanceItem item,
  ) {
    final notesController = TextEditingController();
    final provider = Provider.of<VehicleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selesaikan ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Konfirmasi pemeliharaan telah selesai dilakukan pada odometer saat ini.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.completeMaintenance(item.id!, notesController.text);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MaintenanceStatus status) {
    String text = 'AMAN';
    Color color = Colors.greenAccent;
    if (status == MaintenanceStatus.mendekati) {
      text = 'MENDEKATI';
      color = Colors.orangeAccent;
    } else if (status == MaintenanceStatus.wajibGanti) {
      text = 'WAJIB GANTI';
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _showUpdateOdometerDialog(BuildContext context) {
    final controller = TextEditingController();
    final provider = Provider.of<VehicleProvider>(context, listen: false);
    final vehicle = provider.vehicles.firstWhere((v) => v.id == vehicleId);
    controller.text = vehicle.currentOdometer.toInt().toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Odometer'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'km'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateOdometer(vehicleId, double.parse(controller.text));
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final distController = TextEditingController();
    final monthController = TextEditingController();
    final provider = Provider.of<VehicleProvider>(context, listen: false);
    int selectedIconCode = 0xe1ab; // Default build icon

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Kategori Perawatan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih kategori untuk mengisi data otomatis atau masukkan manual.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryItem(
                      'Oli Mesin',
                      Icons.oil_barrel,
                      2000,
                      6,
                      nameController,
                      distController,
                      monthController,
                      provider.hasMaintenanceItem(vehicleId, 'Oli Mesin'),
                      (code) => setModalState(() => selectedIconCode = code),
                    ),
                    _buildCategoryItem(
                      'Service',
                      Icons.build,
                      5000,
                      6,
                      nameController,
                      distController,
                      monthController,
                      provider.hasMaintenanceItem(vehicleId, 'Service'),
                      (code) => setModalState(() => selectedIconCode = code),
                    ),
                    _buildCategoryItem(
                      'Ban',
                      Icons.tire_repair,
                      20000,
                      24,
                      nameController,
                      distController,
                      monthController,
                      provider.hasMaintenanceItem(vehicleId, 'Ban'),
                      (code) => setModalState(() => selectedIconCode = code),
                    ),
                    _buildCategoryItem(
                      'Aki',
                      Icons.battery_charging_full,
                      15000,
                      18,
                      nameController,
                      distController,
                      monthController,
                      provider.hasMaintenanceItem(vehicleId, 'Aki'),
                      (code) => setModalState(() => selectedIconCode = code),
                    ),
                    _buildCategoryItem(
                      'Rem',
                      Icons.handyman,
                      10000,
                      12,
                      nameController,
                      distController,
                      monthController,
                      provider.hasMaintenanceItem(vehicleId, 'Rem'),
                      (code) => setModalState(() => selectedIconCode = code),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Item',
                  hintText: 'Misal: Ganti Filter Udara',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: distController,
                      decoration: const InputDecoration(
                        labelText: 'Interval (km)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: monthController,
                      decoration: const InputDecoration(
                        labelText: 'Bulan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    if (provider.hasMaintenanceItem(
                      vehicleId,
                      nameController.text,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${nameController.text}" sudah ada!'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final vehicle = provider.vehicles.firstWhere(
                      (v) => v.id == vehicleId,
                    );
                    final item = MaintenanceItem(
                      vehicleId: vehicleId,
                      name: nameController.text,
                      lastServiceDate: DateTime.now(),
                      lastServiceOdometer: vehicle.currentOdometer,
                      intervalDistance: double.parse(distController.text),
                      intervalMonth: int.parse(monthController.text),
                      iconCode: selectedIconCode,
                    );
                    provider.addMaintenanceItem(item);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Konfigurasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    IconData icon,
    double dist,
    int month,
    TextEditingController nCtrl,
    TextEditingController dCtrl,
    TextEditingController mCtrl,
    bool exists,
    Function(int) onSelect,
  ) {
    return Opacity(
      opacity: exists ? 0.4 : 1.0,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: InkWell(
          onTap: exists
              ? null
              : () {
                  nCtrl.text = name;
                  dCtrl.text = dist.toInt().toString();
                  mCtrl.text = month.toString();
                  onSelect(icon.codePoint);
                },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: exists
                      ? Colors.white10
                      : Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: exists
                      ? null
                      : Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: exists ? Colors.grey : Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: exists ? Colors.grey : null,
                  decoration: exists ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
