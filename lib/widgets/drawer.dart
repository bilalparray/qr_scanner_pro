import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 32,
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'QR & Barcode App',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Ultimate QR & Barcode Suite',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan QR/Barcode'),
            onTap: () {
              Navigator.pop(context);
              context.go('/scan'); // Use GoRouter's navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Scan from Gallery'),
            onTap: () {
              Navigator.pop(context);
              context.go('/scan?startGallery=true');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box_rounded),
            title: const Text('Generate Barcode'),
            onTap: () {
              Navigator.pop(context);
              context.go('/generate');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Scan & Generation History'),
            onTap: () {
              Navigator.pop(context);
              context.go('/history');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
        ],
      ),
    );
  }
}
