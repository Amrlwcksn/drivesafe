import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/maintenance_item.dart';
import '../models/maintenance_log.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class EditMaintenanceScreen extends StatefulWidget {
  final MaintenanceItem item;
  final int vehicleId;
  final double currentOdometer;

  const EditMaintenanceScreen({
    super.key,
    required this.item,
    required this.vehicleId,
    required this.currentOdometer,
  });

  @override
  State<EditMaintenanceScreen> createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  late TextEditingController _nameController;
  late TextEditingController _intervalController;
  late TextEditingController _intervalDayController; // New controller
  late TextEditingController _lastOdoController;
  late TextEditingController _brandController;
  late TextEditingController _volumeController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _intervalController = TextEditingController(
      text: widget.item.intervalDistance.toInt().toString(),
    );
    _intervalDayController = TextEditingController(
      text: widget.item.intervalDay.toString(),
    );
    _lastOdoController = TextEditingController(
      text: widget.item.lastServiceOdometer.toInt().toString(),
    );

    // We'll need to fetch the latest brand/volume from the actual item model if we add those fields there,
    // or from the latest log. For now, let's assume we might want to edit these.
    _brandController = TextEditingController(text: widget.item.oilBrand ?? '');
    _volumeController = TextEditingController(
      text: widget.item.oilVolume ?? '',
    );
    _selectedDate = widget.item.lastServiceDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    _intervalDayController.dispose();
    _lastOdoController.dispose();
    _brandController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.iosBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final isOil = widget.item.name.toLowerCase().contains('oli');
    final isDayInterval = widget.item.intervalDay > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Maintenance'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _lastOdoController.text = widget.currentOdometer
                    .toInt()
                    .toString();
                _selectedDate = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data servis di-reset ke saat ini'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppTheme.iosBlue,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<VehicleProvider>(
                context,
                listen: false,
              );

              // 1. Update the Item (Definition & Status)
              provider.updateMaintenanceItem(
                widget.item.id!,
                name: _nameController.text,
                intervalDistance:
                    double.tryParse(_intervalController.text) ??
                    widget.item.intervalDistance,
                intervalDay:
                    int.tryParse(_intervalDayController.text) ??
                    widget.item.intervalDay,
                lastServiceOdometer:
                    double.tryParse(_lastOdoController.text) ??
                    widget.item.lastServiceOdometer,
                lastServiceDate: _selectedDate,
                oilBrand: _brandController.text,
                oilVolume: _volumeController.text,
              );

              // 2. Check if this counts as a "New Service" (Log it)
              // If the Last Service Odometer or Date has changed, we assume it's a service entry.
              final newLastOdo =
                  double.tryParse(_lastOdoController.text) ??
                  widget.item.lastServiceOdometer;

              if (newLastOdo != widget.item.lastServiceOdometer ||
                  _selectedDate != widget.item.lastServiceDate) {
                final log = MaintenanceLog(
                  maintenanceItemId: widget.item.id!,
                  date: _selectedDate,
                  odometer: newLastOdo,
                  notes: 'Pembaruan manual',
                  oilBrand: isOil ? _brandController.text : null,
                  oilVolume: isOil ? _volumeController.text : null,
                );

                provider.logMaintenance(log);
              }

              Navigator.pop(context);
            },
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
        children: [
          const SizedBox(height: 32),
          _buildSection('INFORMASI UMUM'),
          _buildTextField('NAMA KOMPONEN', _nameController),
          // Conditionally show Interval field based on type
          if (isDayInterval)
            _buildTextField(
              'INTERVAL (HARI)',
              _intervalDayController,
              isNumber: true,
            )
          else
            _buildTextField(
              'INTERVAL (KM)',
              _intervalController,
              isNumber: true,
            ),

          const SizedBox(height: 32),
          _buildSection('TERAKHIR SERVIS'),
          _buildTextField('KM SAAT SERVIS', _lastOdoController, isNumber: true),
          ListTile(
            tileColor: Theme.of(context).cardColor,
            title: const Text(
              'TANGGAL SERVIS',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: const TextStyle(color: AppTheme.iosGrey),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.iosGrey),
              ],
            ),
            onTap: () => _selectDate(context),
          ),

          if (isOil) ...[
            const SizedBox(height: 32),
            _buildSection('DETAIL OLI'),
            _buildTextField('MERK OLI', _brandController),
            _buildTextField('VOLUME (ML)', _volumeController, isNumber: true),
          ],

          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                final provider = Provider.of<VehicleProvider>(
                  context,
                  listen: false,
                );
                provider.deleteMaintenanceItem(widget.item.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: AppTheme.iosRed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: const Text(
                'Hapus Komponen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.iosGrey,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.iosGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
