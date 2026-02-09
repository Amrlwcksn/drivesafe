import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'dashboard_screen.dart';
import 'maintenance_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MaintenanceScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    // Initialize notifications non-blocking
    NotificationService().init().catchError((e) {
      debugPrint('Notification init failed: $e');
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        // 1. Loading State
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Setup Required State
        if (provider.username.isEmpty) {
          return _buildSetupScreen(context, provider);
        }

        // 3. Main App State
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            indicatorColor: AppTheme.iosBlue.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build),
                label: 'Maintenance',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ).applyGlassBackground(context);
      },
    );
  }

  Widget _buildSetupScreen(BuildContext context, VehicleProvider provider) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 80,
                  color: AppTheme.iosBlue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selamat Datang!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silakan masukkan nama Anda untuk memulai menggunakan Drivesafe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.iosGrey),
                ),
                const SizedBox(height: 32),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Nama Panggilan',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person, color: AppTheme.iosBlue),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_usernameController.text.trim().isNotEmpty) {
                        provider.setUsername(_usernameController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.iosBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: AppTheme.iosBlue.withOpacity(0.4),
                    ),
                    child: const Text(
                      'Mulai Berkendara',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).applyGlassBackground(context);
  }
}

extension GlassScaffold on Scaffold {
  Widget applyGlassBackground(BuildContext context) {
    return Container(
      decoration: AppTheme.getScaffoldDecoration(context),
      child: this,
    );
  }
}
