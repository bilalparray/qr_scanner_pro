import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner/screens/home_screen.dart';

import 'models/code_entry.dart';
import 'providers/code_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CodeEntryAdapter());

  // 2) Open both boxes before running the app
  await Hive.openBox<CodeEntry>('history');
  await Hive.openBox<CodeEntry>('favorites');

  runApp(
    ChangeNotifierProvider(
      create: (_) => CodeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR/Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Instead of directly calling HomeScreen(), wrap it in a Consumer
      // that waits for CodeProvider.isInitialized to become true.
      home: const _InitializationWrapper(),
    );
  }
}

/// Shows a loading indicator until CodeProvider.isInitialized is true,
/// then replaces itself with HomeScreen.
class _InitializationWrapper extends StatelessWidget {
  const _InitializationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeProvider>(
      builder: (ctx, codeProv, child) {
        if (!codeProv.isInitialized) {
          // Hive boxes are still initializing inside CodeProvider
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Once initialization is done, show the real HomeScreen
        return const HomeScreen();
      },
    );
  }
}
