import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/environment/environment.dart';
import 'package:qr_scanner/services/banner_ad.dart';
import 'package:qr_scanner/widgets/drawer.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import 'package:qr_scanner/models/history_model.dart';
import 'package:qr_scanner/providers/history_provider.dart';
import 'package:qr_scanner/models/generate_code.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }

  Widget _buildPreview(HistoryItem item) {
    const size = 200.0;
    if (!item.isGenerated) {
      return Text(item.content);
    }
    switch (item.codeType) {
      case BarcodeCodeType.qrCode:
      case BarcodeCodeType.qrCodeWiFi:
      case BarcodeCodeType.qrCodeVCard:
      case BarcodeCodeType.microQR:
      case BarcodeCodeType.qrCodeSms:
      case BarcodeCodeType.qrCodeEmail:
      case BarcodeCodeType.qrCodePDF:
      case BarcodeCodeType.qrCodeMultiURl:
      case BarcodeCodeType.qrCodeGeo:
      case BarcodeCodeType.qrCodeAPP:
      case BarcodeCodeType.qrCodePhone:
        return SizedBox(
          width: size,
          height: size,
          child: QrImageView(
            data: item.content,
            version: QrVersions.auto,
          ),
        );
      case BarcodeCodeType.code128:
      case BarcodeCodeType.code128A:
      case BarcodeCodeType.code128B:
      case BarcodeCodeType.code128C:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: Code128(),
          ),
        );
      case BarcodeCodeType.code39:
      case BarcodeCodeType.code39Extended:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content.toUpperCase(),
            symbology: Code39(),
          ),
        );
      case BarcodeCodeType.code93:
      case BarcodeCodeType.code93Extended:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: Code93(),
          ),
        );
      case BarcodeCodeType.ean8:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: EAN8(),
          ),
        );
      case BarcodeCodeType.ean13:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: EAN13(),
          ),
        );
      case BarcodeCodeType.upcA:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: UPCA(),
          ),
        );
      case BarcodeCodeType.upcE:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: UPCE(),
          ),
        );
      case BarcodeCodeType.dataMatrix:
        return SizedBox(
          width: size,
          height: size,
          child: SfBarcodeGenerator(
            value: item.content,
            symbology: DataMatrix(),
          ),
        );
      case BarcodeCodeType.codabar:
        return SizedBox(
          width: size,
          height: size / 2,
          child: SfBarcodeGenerator(
            value: item.content.toUpperCase(),
            symbology: Codabar(),
          ),
        );
      default:
        return const Text('Unsupported barcode type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () {
              final provider = context.read<HistoryProvider>();
              if (provider.history.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All History?'),
                    content: const Text(
                        'This will remove all your history records.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearHistory();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          final history = provider.history;
          if (history.isEmpty) {
            return const Center(
                child: Text('No history yet', style: TextStyle(fontSize: 16)));
          }

          // Total items = history length + number of inserted banner ads
          final int bannerCount = history.length ~/ 2;
          final int totalItemCount = history.length + bannerCount;

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: totalItemCount,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              // Calculate the real history index accounting for banners inserted
              final bannersBefore = index ~/ 3;
              final historyIndex = index - bannersBefore;

              final item = history[historyIndex];
              final previewKey = GlobalKey();

              return ListTile(
                leading: Icon(
                    item.isGenerated ? Icons.qr_code : Icons.qr_code_scanner),
                title: Text(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${item.isGenerated ? 'Generated' : 'Scanned'} on ${_formatTimestamp(item.timestamp)}',
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      item.isGenerated ? 'Preview & Actions' : 'Scanned Data',
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                            key: previewKey, child: _buildPreview(item)),
                        const SizedBox(height: 16),
                        SelectableText(
                          item.snippet,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IndependentBannerAdWidget(
                          adUnitId: Environment.bannerAdUnitId,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
