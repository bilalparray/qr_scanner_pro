import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner_pro/environment/environment.dart';
import 'package:qr_scanner_pro/models/generate_code.dart';
import 'package:qr_scanner_pro/providers/history_provider.dart';
import 'package:qr_scanner_pro/screens/settings_screen.dart';
import 'package:qr_scanner_pro/utils/barcode_utils.dart';
import 'package:qr_scanner_pro/widgets/barcode_customisation.dart';
import 'package:qr_scanner_pro/widgets/barcode_input_fields.dart';
import 'package:qr_scanner_pro/widgets/barcode_viewer.dart';
import 'package:qr_scanner_pro/widgets/code_type_selector.dart';
import 'package:qr_scanner_pro/widgets/download.dart';
import 'package:qr_scanner_pro/widgets/drawer.dart';
import 'package:qr_scanner_pro/widgets/global_error.dart';

import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class BarcodeHomePage extends StatefulWidget {
  const BarcodeHomePage({super.key});

  @override
  State<BarcodeHomePage> createState() => _BarcodeHomePageState();
}

class _BarcodeHomePageState extends State<BarcodeHomePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _barcodeKey = GlobalKey();
  final Map<String, TextEditingController> _controllers = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ⚠ Add ScrollController
  final ScrollController _scrollController = ScrollController();

  // ⚠ Preview section key
  final GlobalKey _previewSectionKey = GlobalKey();

  BarcodeCodeType _selectedType = BarcodeCodeType.qrCode;
  Widget? _generatedBarcode;
  bool _isGenerating = false;

  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  bool _showValue = true;
  double _barcodeWidth = 300.0;
  double _barcodeHeight = 150.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeControllers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose(); // Dispose ScrollController
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    final fields = BarcodeInputField.configForType(_selectedType);
    for (final field in fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  String _buildDataString() =>
      BarcodeUtils.buildDataString(_selectedType, _controllers);

  Future<void> _generateBarcode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isGenerating = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300)); // UI feedback
      final widget = _buildBarcodeWidget();
      if (widget != null) {
        setState(() {
          _generatedBarcode = widget;
        });
        _animationController.forward(from: 0);

        // ⚠ Scroll to preview after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = _previewSectionKey.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            // Fallback: scroll to bottom
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      } else {
        if (mounted) {
          GlobalErrorHandler.showErrorSnackBar(
              context, 'Failed to generate barcode');
        }
      }
    } catch (e) {
      if (mounted) {
        GlobalErrorHandler.showErrorSnackBar(
            context, 'Error generating barcode: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Widget? _buildBarcodeWidget() {
    final data = _buildDataString();
    if (data.isEmpty) return null;
    const snippet = "";

    Provider.of<HistoryProvider>(context, listen: false).addToHistory(
      data,
      snippet: snippet,
      isGenerated: true,
      codeType: _selectedType,
    );
    try {
      switch (_selectedType) {
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
          return QrImageView(
            data: data,
            version: QrVersions.auto,
            size: _barcodeWidth,
            backgroundColor: _backgroundColor,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: _foregroundColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: _foregroundColor,
            ),
          );

        case BarcodeCodeType.code128:
        case BarcodeCodeType.code128A:
        case BarcodeCodeType.code128B:
        case BarcodeCodeType.code128C:
          return SfBarcodeGenerator(
            value: data,
            symbology: Code128(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.code39:
        case BarcodeCodeType.code39Extended:
          return SfBarcodeGenerator(
            value: data.toUpperCase(),
            symbology: Code39(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.code93:
        case BarcodeCodeType.code93Extended:
          return SfBarcodeGenerator(
            value: data,
            symbology: Code93(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.ean8:
          return SfBarcodeGenerator(
            value: data,
            symbology: EAN8(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.ean13:
          return SfBarcodeGenerator(
            value: data,
            symbology: EAN13(),
            showValue: _showValue,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.upcA:
          return SfBarcodeGenerator(
            value: data,
            symbology: UPCA(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.upcE:
          return SfBarcodeGenerator(
            value: data,
            symbology: UPCE(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.dataMatrix:
          return SfBarcodeGenerator(
            value: data,
            symbology: DataMatrix(),
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.codabar:
          return SfBarcodeGenerator(
            value: data.toUpperCase(),
            symbology: Codabar(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        default:
          return SfBarcodeGenerator(
            value: data,
            symbology: Code128(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );
      }
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _captureBarcode() async {
    try {
      final boundary = _barcodeKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareBarcode() async {
    if (_generatedBarcode == null) return;

    final imageBytes = await _captureBarcode();
    if (imageBytes == null) {
      if (!mounted) return;

      GlobalErrorHandler.showErrorSnackBar(
          context, 'Failed to capture barcode image');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    await shareContent(
      text:
          'Generated Barcode ${_selectedType.displayName}\n\nDownload our App at ${Environment.playstoreUrl}',
      files: [XFile(file.path)],
    );
    if (!mounted) return;
    GlobalErrorHandler.showSuccessSnackBar(
        context, 'Barcode shared successfully!');
  }

  Future<void> _downloadBarcode() async {
    if (_generatedBarcode == null) return;

    final Uint8List? imageBytes = await _captureBarcode();
    if (imageBytes == null) return;

    final fileName = 'barcode_${DateTime.now().millisecondsSinceEpoch}.png';
    await downloadFileToDownloads(context,
        fileName: fileName, bytes: imageBytes);
  }

  void _viewBarcodeFullScreen() {
    if (_generatedBarcode == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodePreviewFullScreenPage(
          barcodeWidget: _generatedBarcode!,
          title: _selectedType.displayName,
          foregroundColor: _foregroundColor,
          backgroundColor: _backgroundColor,
        ),
      ),
    );
  }

  void _onBarcodeTypeChanged(BarcodeCodeType? newType) {
    if (newType == null || newType == _selectedType) return;
    setState(() {
      _selectedType = newType;
      _generatedBarcode = null;
      _initializeControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputFields = BarcodeInputField.configForType(_selectedType);
    return PopScope(
      canPop: false,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text('Generate ${_selectedType.displayName}'),
          actions: [
            IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsPage())))
          ],
        ),
        body: SafeArea(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: ListView(
              controller: _scrollController, // attach the scroll controller
              padding: const EdgeInsets.all(5),
              children: [
                BarcodeTypeSelector(
                  selectedType: _selectedType,
                  onTypeChanged: _onBarcodeTypeChanged,
                ),
                BarcodeInputFields(
                  inputFields: inputFields,
                  controllers: _controllers,
                  onChange: () => setState(() => _generatedBarcode = null),
                ),
                BarcodeCustomization(
                  foregroundColor: _foregroundColor,
                  backgroundColor: _backgroundColor,
                  width: _barcodeWidth,
                  height: _barcodeHeight,
                  showValue: _showValue,
                  onForegroundColorChanged: (color) {
                    setState(() {
                      _foregroundColor = color;
                      if (_generatedBarcode != null) {
                        _generatedBarcode = _buildBarcodeWidget();
                      }
                    });
                  },
                  onBackgroundColorChanged: (color) {
                    setState(() {
                      _backgroundColor = color;
                      if (_generatedBarcode != null) {
                        _generatedBarcode = _buildBarcodeWidget();
                      }
                    });
                  },
                  onWidthChanged: (width) {
                    setState(() {
                      _barcodeWidth = width;
                      if (_generatedBarcode != null) {
                        _generatedBarcode = _buildBarcodeWidget();
                      }
                    });
                  },
                  onHeightChanged: (height) {
                    setState(() {
                      _barcodeHeight = height;
                      if (_generatedBarcode != null) {
                        _generatedBarcode = _buildBarcodeWidget();
                      }
                    });
                  },
                  onShowValueChanged: (show) {
                    setState(() {
                      _showValue = show;
                      if (_generatedBarcode != null) {
                        _generatedBarcode = _buildBarcodeWidget();
                      }
                    });
                  },
                  isShowValueEnabled:
                      !_selectedType.isQR && !_selectedType.is2D,
                ),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateBarcode,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.qr_code_2,
                          size: 28, color: Colors.white),
                  label: Text(
                    _isGenerating
                        ? 'Generating...'
                        : 'Generate ${_selectedType.displayName}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const SizedBox(height: 32),
                if (_generatedBarcode != null)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: KeyedSubtree(
                      key: _previewSectionKey,
                      child: BarcodePreview(
                        barcodeKey: _barcodeKey,
                        backgroundColor: _backgroundColor,
                        onShare: _shareBarcode,
                        onSave: _downloadBarcode,
                        onViewFullScreen: _viewBarcodeFullScreen,
                        child: _generatedBarcode!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
