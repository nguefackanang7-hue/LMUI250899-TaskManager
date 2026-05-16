import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class AppColors {
  static const Color background = Color(0xFF0F0E17);
  static const Color surface = Color(0xFF1C1B29);
  static const Color surfaceLight = Color(0xFF252436);
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9D6FFF);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFFFFFFFE);
  static const Color textSecondary = Color(0xFFA7A9BE);
  static const Color border = Color(0xFF2E2D3D);
}
