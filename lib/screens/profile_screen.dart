import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iosLightGrey,
      appBar: AppBar(title: const Text('Profil'), centerTitle: true),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              // User Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 64,
                        color: AppTheme.iosGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.username.isEmpty
                          ? 'Driver DriveSafe'
                          : provider.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSection('PROFIL PENGGUNA'),
              _buildSettingsTile(
                icon: Icons.edit_rounded,
                title: 'Edit Nama Profil',
                onTap: () => _showEditUsernameDialog(context, provider),
              ),
              const SizedBox(height: 24),

              _buildSection('KENDARAAN SAYA'),
              if (provider.vehicles.isNotEmpty) ...[
                ...provider.vehicles.map(
                  (vehicle) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.white,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.iosBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          vehicle.type == VehicleType.motor
                              ? Icons.motorcycle_rounded
                              : Icons.directions_car_rounded,
                          color: AppTheme.iosBlue,
                        ),
                      ),
                      title: Text(
                        vehicle.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${vehicle.year} | ${vehicle.type.name.toUpperCase()}',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.iosGrey,
                      ),
                      onTap: () {
                        // Optional: Navigate to vehicle detail or edit
                      },
                    ),
                  ),
                ),
              ] else ...[
                _buildEmptyPlaceholder(),
              ],
              _buildAddVehicleTile(context),

              const SizedBox(height: 32),
              _buildSection('PENGATURAN'),
              _buildSettingsTile(
                icon: Icons.notifications_rounded,
                title: 'Notifikasi Update Odometer',
                trailing: Switch.adaptive(
                  value: provider.isReminderEnabled,
                  onChanged: (val) => provider.setReminderEnabled(val),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.delete_forever_rounded,
                title: 'Reset Semua Data',
                textColor: AppTheme.iosRed,
                onTap: () => _confirmReset(context, provider),
              ),

              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Versi 1.0.0',
                  style: TextStyle(color: AppTheme.iosGrey, fontSize: 13),
                ),
              ),
            ],
          );
        },
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
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Belum ada kendaraan',
          style: TextStyle(color: AppTheme.iosGrey),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            leading: Icon(icon, color: textColor ?? AppTheme.iosBlue, size: 22),
            title: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing:
                trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.iosGrey,
                  size: 20,
                ),
          ),
          const Divider(height: 1, indent: 56),
        ],
      ),
    );
  }

  Widget _buildAddVehicleTile(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, indent: 16),
          ListTile(
            onTap: () => _showAddVehicleSheet(context),
            leading: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppTheme.iosBlue,
            ),
            title: const Text(
              'Tambah Kendaraan',
              style: TextStyle(
                color: AppTheme.iosBlue,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppTheme.iosGrey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleSheet(BuildContext context) {
    final nameController = TextEditingController();
    final yearController = TextEditingController();
    final odoController = TextEditingController();
    VehicleType selectedType = VehicleType.mobil;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.iosLightGrey,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: AppTheme.iosBlue),
                    ),
                  ),
                  const Text(
                    'Tambah Kendaraan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          yearController.text.isEmpty ||
                          odoController.text.isEmpty)
                        return;

                      final provider = Provider.of<VehicleProvider>(
                        context,
                        listen: false,
                      );
                      provider.addVehicle(
                        Vehicle(
                          name: nameController.text,
                          type: selectedType,
                          year: int.parse(yearController.text),
                          currentOdometer: double.parse(odoController.text),
                        ),
                      );
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
              const SizedBox(height: 16),
              _buildInputGroup([
                _buildSheetTextField(
                  'Nama Kendaraan',
                  nameController,
                  placeholder: 'Misal: Honda Vario',
                ),
                _buildSheetTextField(
                  'Tahun',
                  yearController,
                  placeholder: '2023',
                  isNumber: true,
                ),
                _buildSheetTextField(
                  'Odometer Saat Ini',
                  odoController,
                  placeholder: '5000',
                  isNumber: true,
                ),
              ]),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'Tipe Kendaraan',
                  style: TextStyle(color: AppTheme.iosGrey, fontSize: 13),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    RadioListTile<VehicleType>(
                      value: VehicleType.motor,
                      groupValue: selectedType,
                      title: const Text('Motor'),
                      activeColor: AppTheme.iosBlue,
                      onChanged: (val) =>
                          setModalState(() => selectedType = val!),
                    ),
                    const Divider(height: 1, indent: 56),
                    RadioListTile<VehicleType>(
                      value: VehicleType.mobil,
                      groupValue: selectedType,
                      title: const Text('Mobil'),
                      activeColor: AppTheme.iosBlue,
                      onChanged: (val) =>
                          setModalState(() => selectedType = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSheetTextField(
    String label,
    TextEditingController controller, {
    String? placeholder,
    bool isNumber = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(label, style: const TextStyle(fontSize: 15)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: isNumber
                      ? TextInputType.number
                      : TextInputType.text,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16),
      ],
    );
  }

  void _showEditUsernameDialog(BuildContext context, VehicleProvider provider) {
    final controller = TextEditingController(text: provider.username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Profil'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.setUsername(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, VehicleProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'Hapus seluruh data kendaraan dan riwayat? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.resetData();
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppTheme.iosRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
