import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import '../providers/code_provider.dart';
import '../models/code_entry.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isFlashOn = false;
  bool _isScanning = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // TODO: Implement image scanning
      // This would require additional image processing libraries
    }
  }

  Future<void> _handleScannedCode(String code, BarcodeFormat format) async {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
    });

    try {
      final entry = CodeEntry(
        content: code,
        type: format == BarcodeFormat.qrCode ? 'qr' : 'barcode',
        timestamp: DateTime.now(),
        format: format.toString(),
      );

      await context.read<CodeProvider>().addEntry(entry);

      if (!mounted) return;

      // Show result dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scan Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${format.toString()}'),
              const SizedBox(height: 8),
              Text('Content: $code'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isScanning = true;
                });
              },
              child: const Text('Scan Again'),
            ),
            if (code.startsWith('http'))
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(code);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: const Text('Open Link'),
              ),
            TextButton(
              onPressed: () {
                FlutterClipboard.copy(code);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing scan: $e')),
        );
        setState(() {
          _isScanning = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Code'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
                _controller.toggleTorch();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _scanFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleScannedCode(barcode.rawValue ?? '', barcode.format);
                break; // Process only the first barcode
              }
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Position the code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
