import 'package:flutter/material.dart';
import '../providers/vehicle_provider.dart';

class AppTheme {
  // iOS System Colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGrey = Color(0xFF8E8E93);
  static const Color iosLightGrey = Color(0xFFF2F2F7);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosRed = Color(0xFFFF3B30);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: iosBlue,
      primary: iosBlue,
      secondary: iosBlue,
      surface: Colors.white,
      background: iosLightGrey,
      error: iosRed,
    ),
    scaffoldBackgroundColor: iosLightGrey,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 1,
      backgroundColor: Colors.white,
      indicatorColor: iosBlue.withOpacity(0.1),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: iosBlue,
      unselectedLabelColor: iosGrey,
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: iosBlue,
      brightness: Brightness.dark,
      primary: iosBlue,
      secondary: iosBlue,
      surface: const Color(0xFF1C1C1E),
      background: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1C1C1E),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1C1C1E),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: iosBlue,
      unselectedLabelColor: iosGrey,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 1,
      backgroundColor: Colors.black,
      indicatorColor: iosBlue.withOpacity(0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  static Color getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.aman:
        return iosGreen;
      case MaintenanceStatus.mendekati:
        return iosOrange;
      case MaintenanceStatus.wajibGanti:
        return iosRed;
    }
  }
}
