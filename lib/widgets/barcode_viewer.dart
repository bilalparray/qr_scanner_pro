import 'package:flutter/material.dart';
import 'package:qr_scanner/environment/environment.dart';
import 'package:qr_scanner/services/banner_ad.dart';

class BarcodePreview extends StatelessWidget {
  final GlobalKey barcodeKey;
  final Widget child;
  final Color backgroundColor;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onViewFullScreen;

  const BarcodePreview({
    required this.barcodeKey,
    required this.child,
    required this.backgroundColor,
    required this.onShare,
    required this.onSave,
    required this.onViewFullScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.check_circle, color: Colors.green.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Generated Barcode',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IndependentBannerAdWidget(adUnitId: Environment.bannerAdUnitId),
          RepaintBoundary(
            key: barcodeKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Center(child: child),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildActionButton(Icons.share, 'Share', Colors.blue, onShare),
              _buildActionButton(Icons.download, 'Save', Colors.green, onSave),
              _buildActionButton(
                  Icons.fullscreen, 'View', Colors.purple, onViewFullScreen),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 4,
      ),
    );
  }
}

class BarcodePreviewFullScreenPage extends StatelessWidget {
  final Widget barcodeWidget;
  final String title;
  final Color foregroundColor;
  final Color backgroundColor;

  const BarcodePreviewFullScreenPage({
    required this.barcodeWidget,
    required this.title,
    required this.foregroundColor,
    required this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IndependentBannerAdWidget(adUnitId: Environment.bannerAdUnitId),
            Container(
              color: backgroundColor,
              padding: const EdgeInsets.all(16),
              child: barcodeWidget,
            ),
            IndependentBannerAdWidget(adUnitId: Environment.bannerAdUnitId),
          ],
        ),
      ),
    );
  }
}
