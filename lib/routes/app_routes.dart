import 'package:go_router/go_router.dart';
import 'package:qr_scanner_pro/screens/generate_screen.dart';
import 'package:qr_scanner_pro/screens/history.dart';
import 'package:qr_scanner_pro/screens/home_screen.dart';
import 'package:qr_scanner_pro/screens/scan_screen.dart';
import 'package:qr_scanner_pro/screens/settings_screen.dart';

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
      path: '/scan',
      builder: (context, state) {
        final startGallery = state.uri.queryParameters['startGallery'] ==
            'true'; // Use null-safe casting
        return ScanScreen(startGallery: startGallery);
      },
    )
  ],
);
