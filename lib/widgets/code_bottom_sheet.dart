import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ResultSheet extends StatefulWidget {
  final String result;
  final String type; // 'qr' or 'barcode'
  final String format;

  const ResultSheet({
    super.key,
    required this.result,
    required this.type,
    required this.format,
  });

  @override
  _ResultSheetState createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  bool _copied = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  String get _codeData => widget.result;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _codeData));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _shareImage() async {
    final imageBytes = await _screenshotController.capture();
    if (imageBytes == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = File('${directory.path}/code.png');
    await imagePath.writeAsBytes(imageBytes);

    final result = await Share.shareXFiles([XFile(imagePath.path)],
        text: 'Shared code: $_codeData');

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code shared successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadImage() async {
    final imageBytes = await _screenshotController.capture();
    if (imageBytes == null) return;

    final directory = await getDownloadsDirectory();
    final imagePath = File('${directory?.path}/saved_code.png');
    await imagePath.writeAsBytes(imageBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image saved to Documents'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2)),
          ),
          Text('Generated Code',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]),
            child: Column(
              children: [
                Screenshot(
                    controller: _screenshotController,
                    child: widget.type == 'qr'
                        ? QrImageView(
                            data: _codeData,
                            size: 200,
                            backgroundColor: Colors.white)
                        : BarcodeWidget(
                            data: _codeData,
                            barcode: Barcode.fromType(BarcodeType.values
                                .firstWhere((e) => e.name == widget.format,
                                    orElse: () => BarcodeType.Code128)),
                            width: 200,
                            height: 80,
                            backgroundColor: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: Icon(_copied ? Icons.check : Icons.copy,
                            color: Colors.blue),
                        onPressed: _copyToClipboard),
                    IconButton(
                        icon: const Icon(Icons.share, color: Colors.green),
                        onPressed: _shareImage),
                    IconButton(
                        icon: const Icon(Icons.download, color: Colors.purple),
                        onPressed: _downloadImage),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
