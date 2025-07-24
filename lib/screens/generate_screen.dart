// ==================== HOME PAGE ====================
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/models/generate_code.dart';
import 'package:qr_scanner/widgets/globalerrro.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

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

  BarcodeCodeType _selectedType = BarcodeCodeType.qrCode;
  Widget? _generatedBarcode;
  bool _isGenerating = false;
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  bool _showValue = true;
  double _barcodeWidth = 300.0;
  double _barcodeHeight = 150.0;

  // COMPLETE configuration for ALL barcode types - FIXED ISSUE #1
  static final Map<BarcodeCodeType, List<BarcodeInputField>> _inputConfigs = {
    // QR Codes
    BarcodeCodeType.qrCode: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'Enter text, URL, or any data',
      ),
    ],
    BarcodeCodeType.qrCodeWiFi: const [
      BarcodeInputField(
        key: 'ssid',
        label: 'WiFi Name (SSID)',
        hint: 'MyWiFiNetwork',
      ),
      BarcodeInputField(
        key: 'password',
        label: 'Password',
        hint: 'WiFi password',
      ),
      BarcodeInputField(
        key: 'security',
        label: 'Security Type',
        hint: 'WPA',
        dropdownOptions: ['WPA', 'WEP', 'nopass'],
      ),
    ],
    BarcodeCodeType.qrCodeVCard: const [
      BarcodeInputField(key: 'name', label: 'Full Name', hint: 'John Doe'),
      BarcodeInputField(
        key: 'phone',
        label: 'Phone',
        hint: '+1234567890',
        keyboardType: TextInputType.phone,
      ),
      BarcodeInputField(
        key: 'email',
        label: 'Email',
        hint: 'john@example.com',
        keyboardType: TextInputType.emailAddress,
      ),
      BarcodeInputField(
        key: 'organization',
        label: 'Organization',
        hint: 'Company Name',
        isRequired: false,
      ),
    ],
    BarcodeCodeType.microQR: const [
      BarcodeInputField(
        key: 'data',
        label: 'Numeric Data',
        hint: '12345 (max 5 digits)',
        keyboardType: TextInputType.number,
        maxLength: 5,
        pattern: r'^\d{1,5}$',
      ),
    ],

    // 1D Linear Barcodes
    BarcodeCodeType.code128: const [
      BarcodeInputField(key: 'data', label: 'Data', hint: 'Any ASCII text'),
    ],
    BarcodeCodeType.code128A: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'UPPERCASE and numbers only',
        pattern: r'^[A-Z0-9\s]*$',
      ),
    ],
    BarcodeCodeType.code128B: const [
      BarcodeInputField(key: 'data', label: 'Data', hint: 'ASCII characters'),
    ],
    BarcodeCodeType.code128C: const [
      BarcodeInputField(
        key: 'data',
        label: 'Numeric Data',
        hint: 'Even number of digits (e.g., 123456)',
        keyboardType: TextInputType.number,
        pattern: r'^\d*$',
      ),
    ],
    BarcodeCodeType.code39: [
      const BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'A-Z, 0-9, and symbols (-.\$/ +%)',
        pattern: r'^[A-Z0-9\-\.\$\/\+\%\s]*$',
      ),
    ],
    BarcodeCodeType.code39Extended: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'Extended ASCII characters',
      ),
    ],
    BarcodeCodeType.code93: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'A-Z, 0-9, and symbols',
        pattern: r'^[A-Z0-9\-\.\$\/\+\%\s]*$',
      ),
    ],
    BarcodeCodeType.code93Extended: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'Extended ASCII characters',
      ),
    ],
    BarcodeCodeType.ean8: const [
      BarcodeInputField(
        key: 'data',
        label: 'EAN-8 Code',
        hint: '8 digits (e.g., 12345678)',
        keyboardType: TextInputType.number,
        maxLength: 8,
        pattern: r'^\d{8}$',
      ),
    ],
    BarcodeCodeType.ean13: const [
      BarcodeInputField(
        key: 'data',
        label: 'EAN-13 Code',
        hint: '13 digits (e.g., 1234567890123)',
        keyboardType: TextInputType.number,
        maxLength: 13,
        pattern: r'^\d{13}$',
      ),
    ],
    BarcodeCodeType.upcA: const [
      BarcodeInputField(
        key: 'data',
        label: 'UPC-A Code',
        hint: '12 digits (e.g., 123456789012)',
        keyboardType: TextInputType.number,
        maxLength: 12,
        pattern: r'^\d{12}$',
      ),
    ],
    BarcodeCodeType.upcE: const [
      BarcodeInputField(
        key: 'data',
        label: 'UPC-E Code',
        hint: '8 digits (e.g., 01234567)',
        keyboardType: TextInputType.number,
        maxLength: 8,
        pattern: r'^\d{8}$',
      ),
    ],
    BarcodeCodeType.codabar: const [
      BarcodeInputField(
        key: 'data',
        label: 'Codabar Data',
        hint: 'Start with A-D, end with A-D (e.g., A123456B)',
        pattern: r'^[A-Da-d][0-9\-\$\:\/\.\+]*[A-Da-d]$',
      ),
    ],
    BarcodeCodeType.itf: const [
      BarcodeInputField(
        key: 'data',
        label: 'ITF Data',
        hint: 'Even number of digits',
        keyboardType: TextInputType.number,
        pattern: r'^(\d{2})+$',
      ),
    ],
    BarcodeCodeType.itf14: const [
      BarcodeInputField(
        key: 'data',
        label: 'ITF-14 Code',
        hint: '14 digits (e.g., 12345678901234)',
        keyboardType: TextInputType.number,
        maxLength: 14,
        pattern: r'^\d{14}$',
      ),
    ],

    // 2D Barcodes
    BarcodeCodeType.dataMatrix: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'Any text or binary data',
      ),
    ],
    BarcodeCodeType.pdf417: const [
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'Large data capacity',
      ),
    ],
    BarcodeCodeType.aztec: const [
      BarcodeInputField(key: 'data', label: 'Data', hint: 'Up to 3750 bytes'),
    ],
    BarcodeCodeType.maxiCode: const [
      BarcodeInputField(
        key: 'primaryMessage',
        label: 'Postal Code',
        hint: '12345',
      ),
      BarcodeInputField(key: 'country', label: 'Country Code', hint: 'US'),
      BarcodeInputField(
        key: 'serviceClass',
        label: 'Service Class',
        hint: '001',
      ),
    ],

    // Postal Barcodes
    BarcodeCodeType.postnet: const [
      BarcodeInputField(
        key: 'zipCode',
        label: 'ZIP Code',
        hint: '5 or 9 digit ZIP (e.g., 12345)',
        keyboardType: TextInputType.number,
        pattern: r'^\d{5}(\d{4})?$',
      ),
    ],
    BarcodeCodeType.planet: const [
      BarcodeInputField(
        key: 'trackingNumber',
        label: 'Tracking Number',
        hint: '12-digit tracking number',
        keyboardType: TextInputType.number,
        maxLength: 12,
        pattern: r'^\d{12}$',
      ),
    ],
    BarcodeCodeType.australianPost: const [
      BarcodeInputField(
        key: 'sortingCode',
        label: 'Sorting Code',
        hint: '8-digit sorting code',
        keyboardType: TextInputType.number,
        maxLength: 8,
        pattern: r'^\d{8}$',
      ),
      BarcodeInputField(
        key: 'customerInfo',
        label: 'Customer Info',
        hint: 'Optional customer information',
        isRequired: false,
      ),
    ],
    BarcodeCodeType.royalMail: const [
      BarcodeInputField(
        key: 'postCode',
        label: 'Post Code',
        hint: 'UK postcode (e.g., SW1A 1AA)',
        pattern: r'^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][A-Z]{2}$',
      ),
    ],

    // Specialized
    BarcodeCodeType.gs1_128: const [
      BarcodeInputField(
        key: 'applicationId',
        label: 'Application ID',
        hint: '01 (for GTIN)',
        pattern: r'^\d{2,4}$',
      ),
      BarcodeInputField(
        key: 'data',
        label: 'Data',
        hint: 'Data corresponding to AI',
      ),
    ],
    BarcodeCodeType.pharmacode: const [
      BarcodeInputField(
        key: 'number',
        label: 'Pharmacode Number',
        hint: '3-131070',
        keyboardType: TextInputType.number,
        pattern:
            r'^([3-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]|1[0-2][0-9][0-9][0-9][0-9]|13[01][0-9][0-9][0-9]|131[0-9][0-9][0-9]|13107[0-9])$',
      ),
    ],
    BarcodeCodeType.pzn: const [
      BarcodeInputField(
        key: 'pznNumber',
        label: 'PZN Number',
        hint: '7-digit pharmaceutical number',
        keyboardType: TextInputType.number,
        maxLength: 7,
        pattern: r'^\d{7}$',
      ),
    ],
  };

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
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    // Clear existing controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    // Initialize controllers for current barcode type
    final fields = _inputConfigs[_selectedType] ?? [];
    for (final field in fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  ValidationResult _validateInput(BarcodeInputField field, String value) {
    if (field.isRequired && value.trim().isEmpty) {
      return ValidationResult.invalid('${field.label} is required');
    }

    if (field.pattern != null && value.isNotEmpty) {
      if (!RegExp(field.pattern!).hasMatch(value.toUpperCase())) {
        return ValidationResult.invalid('Invalid ${field.label} format');
      }
    }

    if (field.maxLength != null && value.length != field.maxLength) {
      return ValidationResult.invalid(
        '${field.label} must be exactly ${field.maxLength} characters',
      );
    }

    return ValidationResult.valid;
  }

  String? Function(String? value) _fieldValidator(BarcodeInputField field) {
    return (String? value) {
      final result = _validateInput(field, value ?? '');
      return result.isValid ? null : result.errorMessage;
    };
  }

  void _onBarcodeTypeChanged(BarcodeCodeType? newType) {
    if (newType == null || newType == _selectedType) return;

    setState(() {
      _selectedType = newType;
      _generatedBarcode = null;
      _initializeControllers();
    });
  }

  String _buildQRData() {
    switch (_selectedType) {
      case BarcodeCodeType.qrCodeWiFi:
        final ssid = _controllers['ssid']?.text ?? '';
        final password = _controllers['password']?.text ?? '';
        final security = _controllers['security']?.text ?? 'WPA';
        return 'WIFI:T:$security;S:$ssid;P:$password;;';

      case BarcodeCodeType.qrCodeVCard:
        final name = _controllers['name']?.text ?? '';
        final phone = _controllers['phone']?.text ?? '';
        final email = _controllers['email']?.text ?? '';
        final org = _controllers['organization']?.text ?? '';
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nORG:$org\nTEL:$phone\nEMAIL:$email\nEND:VCARD';

      case BarcodeCodeType.gs1_128:
        final ai = _controllers['applicationId']?.text ?? '01';
        final data = _controllers['data']?.text ?? '';
        return '($ai)$data';

      case BarcodeCodeType.maxiCode:
        final postal = _controllers['primaryMessage']?.text ?? '';
        final country = _controllers['country']?.text ?? '';
        final service = _controllers['serviceClass']?.text ?? '';
        return '$service,$postal,$country';

      default:
        return _controllers['data']?.text ?? '';
    }
  }

  Future<void> _generateBarcode() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // UI feedback delay

      final widget = _buildBarcodeWidget();
      if (widget != null) {
        setState(() {
          _generatedBarcode = widget;
        });
        _animationController.forward();
      } else {
        if (mounted) {
          GlobalErrorHandler.showErrorSnackBar(
            context,
            'Failed to generate barcode',
          );
        }
      }
    } catch (e, stackTrace) {
      dev.log('Error generating barcode', error: e, stackTrace: stackTrace);
      if (mounted) {
        GlobalErrorHandler.showErrorSnackBar(
          context,
          'Error generating barcode: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget? _buildBarcodeWidget() {
    final data = _buildQRData();
    if (data.isEmpty) return null;

    try {
      switch (_selectedType) {
        case BarcodeCodeType.qrCode:
        case BarcodeCodeType.qrCodeWiFi:
        case BarcodeCodeType.qrCodeVCard:
        case BarcodeCodeType.microQR:
          return QrImageView(
            data: data,
            version: QrVersions.auto,
            size: _barcodeWidth,
            foregroundColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
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
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.code39:
        case BarcodeCodeType.code39Extended:
          return SfBarcodeGenerator(
            value: data.toUpperCase(),
            symbology: Code39(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.code93:
        case BarcodeCodeType.code93Extended:
          return SfBarcodeGenerator(
            value: data,
            symbology: Code93(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.ean8:
          return SfBarcodeGenerator(
            value: data,
            symbology: EAN8(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.ean13:
          return SfBarcodeGenerator(
            value: data,
            symbology: EAN13(),
            showValue: _showValue,
            //  barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.upcA:
          return SfBarcodeGenerator(
            value: data,
            symbology: UPCA(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.upcE:
          return SfBarcodeGenerator(
            value: data,
            symbology: UPCE(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );

        case BarcodeCodeType.dataMatrix:
          return SfBarcodeGenerator(
            value: data,
            symbology: DataMatrix(),
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
          );

        case BarcodeCodeType.pdf417:
          return SfBarcodeGenerator(
            value: data,
            // symbology: PDF417(),
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
            // barHeight: _barcodeHeight,
          );

        default:
          return SfBarcodeGenerator(
            value: data,
            symbology: Code128(),
            showValue: _showValue,
            barColor: _foregroundColor,
            backgroundColor: _backgroundColor,
            // barHeight: _barcodeHeight,
          );
      }
    } catch (e) {
      dev.log('Error creating barcode widget', error: e);
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
    } catch (e) {
      dev.log('Error capturing barcode', error: e);
      return null;
    }
  }

  Future<void> _shareBarcode() async {
    if (_generatedBarcode == null) return;

    try {
      final imageBytes = await _captureBarcode();
      if (imageBytes == null) {
        if (mounted) {
          GlobalErrorHandler.showErrorSnackBar(
            context,
            'Failed to capture barcode image',
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Generated ${_selectedType.displayName}');

      if (mounted) {
        GlobalErrorHandler.showSuccessSnackBar(
          context,
          'Barcode shared successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalErrorHandler.showErrorSnackBar(
          context,
          'Error sharing barcode: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _downloadBarcode() async {
    if (_generatedBarcode == null) return;

    try {
      // if (await Permission.storage.isDenied) {
      //   final status = await Permission.storage.request();
      //   if (!status.isGranted) {
      //     if (mounted) {
      //       GlobalErrorHandler.showErrorSnackBar(
      //         context,
      //         'Storage permission required to save barcode',
      //       );
      //     }
      //     return;
      //   }
      // }

      final imageBytes = await _captureBarcode();
      if (imageBytes == null) {
        if (mounted) {
          GlobalErrorHandler.showErrorSnackBar(
            context,
            'Failed to capture barcode image',
          );
        }
        return;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        // Optionally check if directory exists:
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }
      final fileName =
          'barcode_${_selectedType.name}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory!.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        GlobalErrorHandler.showSuccessSnackBar(
          context,
          'Saved: $fileName',
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalErrorHandler.showErrorSnackBar(
          context,
          'Error saving barcode: $e',
        );
      }
    }
  }

  void _viewBarcodeFullScreen() {
    if (_generatedBarcode == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeViewerPage(
          barcode: _generatedBarcode!,
          title: _selectedType.displayName,
          foregroundColor: _foregroundColor,
          backgroundColor: _backgroundColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputFields = _inputConfigs[_selectedType] ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_selectedType.category.icon),
            const SizedBox(width: 8),
            const Text('Barcode & QR Generator'),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About'),
                  content: const Text(
                    'Professional Barcode & QR Code Generator\n\nSupports 25+ barcode types with dynamic validation and customization.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Barcode Type Selection Card - Enhanced UI
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Select Barcode Type',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<BarcodeCodeType>(
                        isExpanded: true,
                        itemHeight: 80,
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Barcode Type',
                          prefixIcon: Icon(_selectedType.category.icon),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        items: BarcodeCodeType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: type.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' • '),
                                  TextSpan(
                                    text: type.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1, // forces single-line
                              overflow:
                                  TextOverflow.ellipsis, // clips long text
                            ),
                          );
                        }).toList(),
                        onChanged: _onBarcodeTypeChanged,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Example: ${_selectedType.exampleData}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic Input Fields Card - FIXED: Now shows for ALL types
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Configure ${_selectedType.displayName}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (inputFields.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This barcode type is not yet configured for input fields. Please select another type.',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ...inputFields.asMap().entries.map((entry) {
                          final field = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: field.dropdownOptions != null
                                ? DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: field.label,
                                      hintText: field.hint,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      prefixIcon: Icon(
                                        _getFieldIcon(field.key),
                                      ),
                                    ),
                                    items: field.dropdownOptions!.map((option) {
                                      return DropdownMenuItem(
                                        value: option,
                                        child: Text(option),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      _controllers[field.key]?.text =
                                          value ?? '';
                                      setState(() {
                                        _generatedBarcode = null;
                                      });
                                    },
                                    validator: _fieldValidator(field),
                                  )
                                : TextFormField(
                                    controller: _controllers[field.key],
                                    decoration: InputDecoration(
                                      labelText: field.label,
                                      hintText: field.hint,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      prefixIcon: Icon(
                                        _getFieldIcon(field.key),
                                      ),
                                      suffixIcon: field.isRequired
                                          ? Icon(
                                              Icons.star,
                                              size: 12,
                                              color: Colors.red.shade400,
                                            )
                                          : null,
                                    ),
                                    keyboardType: field.keyboardType,
                                    maxLength: field.maxLength,
                                    validator: _fieldValidator(field),
                                    onChanged: (_) {
                                      setState(() {
                                        _generatedBarcode = null;
                                      });
                                    },
                                  ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Customization Card - FIXED: Now clearly clickable
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.palette_outlined,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Customization',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Color Customization - Enhanced with clear clickability
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _showColorPicker(
                                context,
                                _foregroundColor,
                                (color) => setState(
                                  () => _foregroundColor = color,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.brush,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Foreground',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _foregroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to change',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _showColorPicker(
                                context,
                                _backgroundColor,
                                (color) => setState(
                                  () => _backgroundColor = color,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.format_color_fill,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Background',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _backgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to change',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Size Controls
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Size Controls',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.width_normal,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text('Width: ${_barcodeWidth.round()}px'),
                              Expanded(
                                child: Slider(
                                  value: _barcodeWidth,
                                  min: 200,
                                  max: 400,
                                  divisions: 20,
                                  onChanged: (value) {
                                    setState(() {
                                      _barcodeWidth = value;
                                      if (_generatedBarcode != null) {
                                        _generatedBarcode =
                                            _buildBarcodeWidget();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.height,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text('Height: ${_barcodeHeight.round()}px'),
                              Expanded(
                                child: Slider(
                                  value: _barcodeHeight,
                                  min: 100,
                                  max: 250,
                                  divisions: 15,
                                  onChanged: (value) {
                                    setState(() {
                                      _barcodeHeight = value;
                                      if (_generatedBarcode != null) {
                                        _generatedBarcode =
                                            _buildBarcodeWidget();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Show Text Toggle
                      if (_selectedType != BarcodeCodeType.qrCode &&
                          _selectedType != BarcodeCodeType.qrCodeWiFi &&
                          _selectedType != BarcodeCodeType.qrCodeVCard &&
                          _selectedType != BarcodeCodeType.dataMatrix &&
                          _selectedType != BarcodeCodeType.pdf417) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Show Text Value',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Display text below the barcode',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _showValue,
                                onChanged: (value) {
                                  setState(() {
                                    _showValue = value;
                                    if (_generatedBarcode != null) {
                                      _generatedBarcode = _buildBarcodeWidget();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Generate Button - Enhanced with animation
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateBarcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                  ),
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.qr_code_2,
                          size: 28,
                          color: Colors.white,
                        ),
                  label: Text(
                    _isGenerating
                        ? 'Generating...'
                        : 'Generate ${_selectedType.displayName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Generated Barcode Display Card - Enhanced with animation
              if (_generatedBarcode != null) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Generated ${_selectedType.displayName}',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          RepaintBoundary(
                            key: _barcodeKey,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(child: _generatedBarcode!),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildActionButton(
                                icon: Icons.share,
                                label: 'Share',
                                onPressed: _shareBarcode,
                                color: Colors.blue,
                              ),
                              _buildActionButton(
                                icon: Icons.download,
                                label: 'Save',
                                onPressed: _downloadBarcode,
                                color: Colors.green,
                              ),
                              _buildActionButton(
                                icon: Icons.fullscreen,
                                label: 'View',
                                onPressed: _viewBarcodeFullScreen,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Statistics Card - Enhanced
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.analytics_outlined,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Supported Formats',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildStatisticsGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 4,
      ),
    );
  }

  IconData _getFieldIcon(String fieldKey) {
    switch (fieldKey) {
      case 'data':
        return Icons.text_fields;
      case 'ssid':
        return Icons.wifi;
      case 'password':
        return Icons.lock;
      case 'security':
        return Icons.security;
      case 'name':
        return Icons.person;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'organization':
        return Icons.business;
      case 'zipCode':
        return Icons.location_on;
      case 'trackingNumber':
        return Icons.track_changes;
      default:
        return Icons.edit;
    }
  }

  Widget _buildStatisticsGrid() {
    final categories = <BarcodeCategory, int>{};
    for (final type in BarcodeCodeType.values) {
      categories[type.category] = (categories[type.category] ?? 0) + 1;
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                entry.key.icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                '${entry.value}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                entry.key.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onChanged,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Select Color'),
            ],
          ),
          content: SingleChildScrollView(
            child: EnhancedColorPicker(
              pickerColor: currentColor,
              onColorChanged: onChanged,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

// ==================== BARCODE VIEWER PAGE ====================

class BarcodeViewerPage extends StatelessWidget {
  final Widget barcode;
  final String title;
  final Color foregroundColor;
  final Color backgroundColor;

  const BarcodeViewerPage({
    super.key,
    required this.barcode,
    required this.title,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 10.0,
            child: Container(padding: const EdgeInsets.all(20), child: barcode),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        child: const Icon(Icons.close),
      ),
    );
  }
}

// ==================== ENHANCED COLOR PICKER ====================

class EnhancedColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const EnhancedColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  static const List<List<Color>> _colorGroups = [
    // Basic colors
    [Colors.black, Colors.white, Colors.grey, Colors.red, Colors.pink],
    [
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
    ],
    [Colors.cyan, Colors.teal, Colors.green, Colors.lightGreen, Colors.lime],
    [
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current color display
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: pickerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Selected Color',
                style: TextStyle(
                  color: pickerColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Color grid
          ..._colorGroups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: group.map((color) {
                  final isSelected = pickerColor == color;
                  return GestureDetector(
                    onTap: () => onColorChanged(color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade400,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
