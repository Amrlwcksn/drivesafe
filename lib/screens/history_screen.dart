import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iosLightGrey,
      appBar: AppBar(title: const Text('Riwayat'), centerTitle: true),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          final logs = provider.logs;

          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat.',
                style: TextStyle(color: AppTheme.iosGrey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.iosBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppTheme.iosBlue,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    DateFormat('dd MMMM yyyy').format(log.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Odometer: ${log.odometer.toInt()} KM',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.iosGrey,
                        ),
                      ),
                      if (log.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          log.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                      if (log.oilBrand != null || log.oilVolume != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${log.oilBrand ?? "-"} | ${log.oilVolume ?? "-"} ML',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.iosOrange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
