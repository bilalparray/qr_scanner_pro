import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner/providers/history_provider.dart';
import 'package:qr_scanner/screens/home_screen.dart';
import 'package:qr_scanner/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await AdService.instance.preloadAllAds(); // Preload all ads

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HistoryProvider()),
    ],
    child: const MyApp(),
  ));
}

// Define your GoRouter routes
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products/qrscanner',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QR/Barcode Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}
