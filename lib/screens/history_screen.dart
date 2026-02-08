import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.iosLightGrey,
        appBar: AppBar(
          title: const Text(
            'Riwayat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
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
                _buildMaintenanceLogs(provider.logs),
                _buildDistanceLogs(provider.distanceLogs),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaintenanceLogs(List<dynamic> logs) {
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
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.iosBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.build,
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
                      DateFormat('dd MMM yyyy').format(log.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Odometer: ${log.odometer.toInt()} KM',
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
        final added = log['addedDistance'] as double;
        final newOdo = log['newOdometer'] as double;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
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
}
