import 'package:ble_vitals_scanner/providers/ble_provider.dart';
import 'package:ble_vitals_scanner/providers/theme_provider.dart';
import 'package:ble_vitals_scanner/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows scanner app shell', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final themeProvider = ThemeProvider();
    await themeProvider.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => BleProvider(enableBleClient: false),
          ),
          ChangeNotifierProvider(create: (_) => themeProvider),
        ],
        child: const MaterialApp(
          home: ScanScreen(autoStartScan: false),
        ),
      ),
    );

    expect(find.text('BLE Vitals Scanner'), findsOneWidget);
    expect(find.text('Discovered devices'), findsOneWidget);
  });
}
