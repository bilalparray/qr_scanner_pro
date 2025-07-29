import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/utils/barcode_utils.dart';
import 'package:qr_scanner/widgets/download.dart';
import 'package:qr_scanner/widgets/global_error.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'package:qr_scanner/models/history_model.dart';
import 'package:qr_scanner/providers/history_provider.dart';
import 'package:qr_scanner/models/generate_code.dart';

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

  Future<Uint8List?> _capturePreview(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Generation History'),
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
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = history[index];
              final previewKey = GlobalKey();
              return ListTile(
                leading: Icon(
                    item.isGenerated ? Icons.qr_code : Icons.qr_code_scanner),
                title: Text(item.content,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    '${item.isGenerated ? 'Generated' : 'Scanned'} on ${_formatTimestamp(item.timestamp)}'),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(item.isGenerated
                        ? 'Preview & Actions'
                        : 'Scanned Data'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                            key: previewKey, child: _buildPreview(item)),
                        const SizedBox(height: 16),
                        SelectableText(item.snippet,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12)),
                      ],
                    ),
                    actions: [
                      TextButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        onPressed: () async {
                          final Uint8List? bytes =
                              await _capturePreview(previewKey);
                          if (bytes != null) {
                            await downloadFileToDownloads(context,
                                fileName:
                                    'history_${item.timestamp.millisecondsSinceEpoch}.png',
                                bytes: bytes);
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () async {
                          final bytes = await _capturePreview(previewKey);
                          if (bytes != null) {
                            final temp = await getTemporaryDirectory();
                            final file = File(
                                '${temp.path}/history_${item.timestamp.millisecondsSinceEpoch}.png');
                            await file.writeAsBytes(bytes);

                            shareContent(
                                text: item.content, files: [XFile(file.path)]);
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.content));
                          if (context.mounted) {
                            GlobalErrorHandler.showSuccessSnackBar(
                                context, 'Copied to clipboard');
                          }
                        },
                      ),
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.of(context).pop(),
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
