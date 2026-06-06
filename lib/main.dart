import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/ble_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const BleVitalsApp(),
    ),
  );
}

class BleVitalsApp extends StatelessWidget {
  const BleVitalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'BLE Vitals Scanner',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const ScanScreen(),
    );
  }
}
