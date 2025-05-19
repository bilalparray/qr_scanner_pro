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
    if (_isFlashOn) {
      setState(() {
        _isFlashOn = false;
      });
      _controller.toggleTorch();
    }
    setState(() {
      _isScanning = true;
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

      _handleScannedCode(rawValue, format, mlkitBarcode);
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

  Future<void> _handleScannedCode(
      String code, BarcodeFormat format, dynamic scannedResult) async {
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
          type: getQrType(scannedResult),
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
                  barcodes.first,
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

  String getQrType(dynamic barcode) {
    final data = barcode.rawValue ?? '';

    // 1) First look at the semantic type:
    switch (barcode.type) {
      case BarcodeType.url:
        return 'URL';
      case BarcodeType.contactInfo:
        return 'Contact';
      case BarcodeType.email:
        return 'Email';
      case BarcodeType.phone:
        return 'Phone';
      case BarcodeType.sms:
        return 'SMS';
      case BarcodeType.wifi:
        return 'WiFi';
      case BarcodeType.geo:
        return 'Location';
      case BarcodeType.calendarEvent:
        return 'Calendar Event';
      case BarcodeType.isbn:
        return 'ISBN';
      case BarcodeType.driverLicense:
        return 'Driver Licence';
      // add other ML Kit `valueType`s if supported...
      default:
        break;
    }

    // 2) Fallback to checking prefixes (your original logic):
    if (data.startsWith('http')) return 'URL';
    if (data.startsWith('mailto:')) return 'Email';
    if (data.startsWith('MATMSG:')) return 'Email';
    if (data.startsWith('SMTP:')) return 'Email';
    if (data.startsWith('BEGIN:VCARD') || data.startsWith('MECARD:')) {
      return 'Contact';
    }
    if (data.startsWith('bitcoin:')) return 'Bitcoin';
    if (data.startsWith('ethereum:')) return 'Ethereum';
    if (data.startsWith('SMSTO:') || data.startsWith('sms:')) return 'SMS';
    if (data.startsWith('WIFI:')) return 'WiFi';
    if (data.startsWith('geo:')) return 'Location';
    if (data.startsWith('tel:')) return 'Phone';
    if (data.startsWith('BEGIN:VEVENT') || data.startsWith('BEGIN:VCALENDAR')) {
      return 'Calendar Event';
    }
    if (data.startsWith('upi:') || // make sure to include the colon
        data.startsWith('upi')) {
      return 'UPI Payment';
    }

    // 3) Finally, fall back to the raw symbology format:
    switch (barcode.type) {
      case "product":
        return 'Product';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.codabar:
        return 'Codabar';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.itf:
        return 'ITF';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.upcE:
        return 'UPC-E';

      default:
        return 'Text';
    }
  }
}
