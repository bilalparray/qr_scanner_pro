import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import '../providers/code_provider.dart';
import '../models/code_entry.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  late final mlkit.BarcodeScanner _mlKitScanner;
  bool _isFlashOn = false;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _mlKitScanner = mlkit.BarcodeScanner();
  }

  @override
  void dispose() {
    _mlKitScanner.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanFromGallery() async {
    setState(() {
      _isScanning = true;
      _isFlashOn = false;
      _controller.toggleTorch();
    });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final inputImage = mlkit.InputImage.fromFilePath(pickedFile.path);
      final mlkitBarcodes = await _mlKitScanner.processImage(inputImage);

      if (mlkitBarcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No barcode found in image')),
          );
        }
        return;
      }

      final mlkitBarcode = mlkitBarcodes.first;
      final rawValue = mlkitBarcode.rawValue ?? '';
      final format = _convertMlKitFormat(mlkitBarcode.format);

      _handleScannedCode(rawValue, format);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = true);
    }
  }

  BarcodeFormat _convertMlKitFormat(mlkit.BarcodeFormat format) {
    switch (format) {
      case mlkit.BarcodeFormat.qrCode:
        return BarcodeFormat.qrCode;
      case mlkit.BarcodeFormat.aztec:
        return BarcodeFormat.aztec;
      case mlkit.BarcodeFormat.code39:
        return BarcodeFormat.code39;
      case mlkit.BarcodeFormat.code93:
        return BarcodeFormat.code93;
      case mlkit.BarcodeFormat.code128:
        return BarcodeFormat.code128;
      case mlkit.BarcodeFormat.dataMatrix:
        return BarcodeFormat.dataMatrix;
      case mlkit.BarcodeFormat.ean13:
        return BarcodeFormat.ean13;
      case mlkit.BarcodeFormat.ean8:
        return BarcodeFormat.ean8;
      case mlkit.BarcodeFormat.itf:
        return BarcodeFormat.itf;
      case mlkit.BarcodeFormat.pdf417:
        return BarcodeFormat.pdf417;
      case mlkit.BarcodeFormat.upca:
        return BarcodeFormat.upcA;
      case mlkit.BarcodeFormat.upce:
        return BarcodeFormat.upcE;
      default:
        return BarcodeFormat.unknown;
    }
  }

  Future<void> _handleScannedCode(String code, BarcodeFormat format) async {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
      if (_isFlashOn) {
        _isFlashOn = false;
        _controller.toggleTorch();
      }
    });

    final entry = CodeEntry(
      content: code,
      type: format.toString().split('.').last,
      timestamp: DateTime.now(),
      format: format.toString(),
    );

    await context.read<CodeProvider>().addEntry(entry);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          content: code,
          format: format.toString().split('.').last,
          timestamp: DateTime.now(),
        ),
      ),
    ).then((_) => setState(() => _isScanning = true));
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
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _handleScannedCode(
                  barcodes.first.rawValue ?? '',
                  barcodes.first.format,
                );
              }
            },
          ),
          _buildScanOverlay(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 250,
              color: const Color.fromARGB(137, 120, 119, 119),
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Align code within frame to scan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
