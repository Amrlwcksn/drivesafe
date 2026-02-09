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
      surface: const Color(0xFFF9F9FB),
      background: Colors.white,
      onSurface: const Color(0xFF1C1C1E),
      onBackground: const Color(0xFF1C1C1E),
      error: iosRed,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1C1C1E),
      titleTextStyle: TextStyle(
        color: Color(0xFF1C1C1E),
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.95),
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
      background: const Color(0xFF000000),
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1C1C1E).withOpacity(0.8),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: iosBlue,
      unselectedLabelColor: iosGrey,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF000000).withOpacity(0.9),
      indicatorColor: iosBlue.withOpacity(0.15),
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

  // Gradients - Modern "Ice White" and "Deep Space"
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2F2F7), Color(0xFFFFFFFF), Color(0xFFE5E5EA)],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000000), Color(0xFF1C1C1E), Color(0xFF0A0A0B)],
  );

  static BoxDecoration getScaffoldDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: Theme.of(context).brightness == Brightness.dark
          ? darkBackgroundGradient
          : lightBackgroundGradient,
    );
  }
}
