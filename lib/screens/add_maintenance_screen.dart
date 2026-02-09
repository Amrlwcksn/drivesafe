import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/maintenance_item.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AddMaintenanceScreen extends StatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _nameController = TextEditingController();
  final _intervalController = TextEditingController();
  final _brandController = TextEditingController();
  final _volumeController = TextEditingController(); // For oil
  bool _isOil = false;

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    _brandController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getScaffoldDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Tambah Item Maintenance'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppTheme.iosBlue),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () => _save(context),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: AppTheme.iosBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              'NAMA KOMPONEN',
              _nameController,
              hint: 'Contoh: Busi, Kampas Rem',
              onChanged: (val) {
                setState(() {
                  _isOil =
                      val.toLowerCase().contains('oli') ||
                      val.toLowerCase().contains('oil');
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'INTERVAL SERVIS (KM)',
              _intervalController,
              isNumber: true,
              hint: 'Contoh: 5000',
            ),

            if (_isOil) ...[
              const SizedBox(height: 16),
              _buildTextField(
                'MERK OLI',
                _brandController,
                hint: 'Contoh: Shell, Pertamina',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'VOLUME (ML)',
                _volumeController,
                isNumber: true,
                hint: 'Contoh: 800',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    String? hint,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.iosGrey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _save(BuildContext context) {
    if (_nameController.text.isEmpty || _intervalController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon lengkapi data')));
      return;
    }

    final provider = Provider.of<VehicleProvider>(context, listen: false);
    if (provider.vehicles.isEmpty) return;

    final vehicle = provider.vehicles.first; // Default to first vehicle for now

    final newItem = MaintenanceItem(
      vehicleId: vehicle.id!,
      name: _nameController.text,
      lastServiceDate: DateTime.now(),
      lastServiceOdometer: vehicle.currentOdometer,
      intervalDistance: double.tryParse(_intervalController.text) ?? 5000,
      intervalMonth: 6, // Default default
      iconCode: 0xe318, // build_circle
      oilBrand: _brandController.text.isNotEmpty ? _brandController.text : null,
      oilVolume: _volumeController.text.isNotEmpty
          ? _volumeController.text
          : null,
    );

    provider.addMaintenanceItem(newItem);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Komponen berhasil ditambahkan')),
    );
  }
}
