// lib/screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/models/scan_result.dart';
import 'package:qr_scanner/screens/scan_result_screen.dart';
import '../services/qr_parser.dart';
import '../widgets/scan_overlay.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final MobileScannerController _ctrl = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  bool _isBusy = false;
  bool _analyzingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ctrl.start();
    } else if (state == AppLifecycleState.paused) {
      _ctrl.stop();
    }
  }

  // ── live camera detection ─────────────────────────────────────────────────

  void _onDetect(BarcodeCapture cap) async {
    if (_isBusy || cap.barcodes.isEmpty) return;
    setState(() => _isBusy = true);

    final raw = cap.barcodes.first.rawValue ?? '';
    final parsed = QRParser.parse(raw);
    await _openResult(parsed);

    setState(() => _isBusy = false);
  }

  // ── gallery import ────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    if (_analyzingImage) return;
    setState(() => _analyzingImage = true);

    try {
      final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      if (file == null) {
        setState(() => _analyzingImage = false);
        return;
      }

      _showLoadingDialog();
      final capture = await _ctrl.analyzeImage(file.path);
      if (!mounted) return;
      Navigator.of(context).pop(); // close loading

      if (capture != null && capture.barcodes.isNotEmpty) {
        final raw = capture.barcodes.first.rawValue ?? '';
        await _openResult(QRParser.parse(raw));
      } else {
        _showErrorDialog('No QR code found in that image.');
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _showErrorDialog('Image analysis failed: $e');
    } finally {
      setState(() => _analyzingImage = false);
    }
  }

  // ── ui helpers ────────────────────────────────────────────────────────────

  Future<void> _openResult(ScanResultModel r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: r)),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing image…'),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Pick from Gallery',
            onPressed: _analyzingImage ? null : _pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),
          const ScanOverlay(),
          if (_isBusy)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // ── bottom controls ───────────────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // flash
                _CircleButton(
                  onPressed: _ctrl.toggleTorch,
                  child: ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _ctrl,
                    builder: (_, state, __) => Icon(
                      switch (state.torchState) {
                        TorchState.on => Icons.flash_on,
                        TorchState.auto => Icons.flash_auto,
                        _ => Icons.flash_off,
                      },
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                // gallery
                _CircleButton(
                  onPressed: _analyzingImage ? null : _pickFromGallery,
                  child: _analyzingImage
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.photo_library,
                          color: Colors.white, size: 32),
                ),
                // camera switch
                _CircleButton(
                  onPressed: _ctrl.switchCamera,
                  child: ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _ctrl,
                    builder: (_, state, __) => Icon(
                      state.cameraDirection == CameraFacing.front
                          ? Icons.camera_front
                          : Icons.camera_rear,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(onPressed: onPressed, icon: child),
    );
  }
}
