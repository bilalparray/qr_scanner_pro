import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_scanner/environment/environment.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // You might want to use your own app logo/icon here
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Swap with your logo if available
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 32,
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'QR & Barcode App',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
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
              // GoRouter.of(context).go('/scan');
              context.push('/scan');
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Scan from Gallery'),
            onTap: () {
              Navigator.pop(context); // close drawer
              context.push('/scan?startGallery=true');
            },
          ),

          ListTile(
            leading: const Icon(Icons.add_box_rounded),
            title: const Text('Generate Barcode'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/generate');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Scan & Generation History'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/history');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/settings');
            },
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Remove Ads'),
            onTap: () {
              Navigator.pop(context);
              launchUrl(Uri.parse(Environment.playstoreUrl));
            },
          ),
        ],
      ),
    );
  }
}
