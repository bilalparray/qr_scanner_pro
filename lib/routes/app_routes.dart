import 'package:go_router/go_router.dart';
import 'package:qr_scanner/screens/generate_screen.dart';
import 'package:qr_scanner/screens/history.dart';
import 'package:qr_scanner/screens/home_screen.dart';
import 'package:qr_scanner/screens/premium_screen.dart';
import 'package:qr_scanner/screens/scan_screen.dart';
import 'package:qr_scanner/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products/qrscanner',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      path: '/generate',
      builder: (context, state) => const BarcodeHomePage(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) {
        final startGallery = state.uri.queryParameters['startGallery'] ==
            'true'; // Use null-safe casting
        return ScanScreen(startGallery: startGallery);
      },
    )
  ],
);
