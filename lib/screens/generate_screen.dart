import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_scanner/widgets/code_bottom_sheet.dart';
import 'dart:io';

import '../providers/code_provider.dart';
import '../models/code_entry.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({Key? key}) : super(key: key);

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _urlController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _encryptionTypeController =
      TextEditingController(text: 'WPA'); // Default value
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _selectedType = 'qr';
  String _selectedFormat = 'code128';
  String _selectedQrType = 'text';
  final Color _backgroundColor = Colors.white;
  File? _logoFile;
  final int _errorCorrectionLevel = QrErrorCorrectLevel.M;
  bool _isGenerating = false;
  String? _generatedData;

  @override
  void dispose() {
    for (final c in [
      _contentController,
      _nameController,
      _phoneController,
      _emailController,
      _subjectController,
      _messageController,
      _urlController,
      _eventNameController,
      _locationController,
      _startDateController,
      _endDateController,
      _descriptionController,
      _ssidController,
      _passwordController,
      _encryptionTypeController,
      _latitudeController,
      _longitudeController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  String _generateQrContent() {
    switch (_selectedQrType) {
      case 'url':
        return _urlController.text;
      case 'contact':
        return '''
BEGIN:VCARD
VERSION:3.0
FN:\${_nameController.text}
TEL:\${_phoneController.text}
EMAIL:\${_emailController.text}
END:VCARD
''';
      case 'email':
        return 'mailto:\${_emailController.text}'
            '?subject=\${Uri.encodeComponent(_subjectController.text)}'
            '&body=\${Uri.encodeComponent(_messageController.text)}';
      case 'sms':
        return 'sms:\${_phoneController.text}'
            '?body=\${Uri.encodeComponent(_messageController.text)}';
      case 'event':
        return '''
BEGIN:VEVENT
SUMMARY:\${_eventNameController.text}
LOCATION:\${_locationController.text}
DTSTART:\${_startDateController.text}
DTEND:\${_endDateController.text}
DESCRIPTION:\${_descriptionController.text}
END:VEVENT
''';
      case 'wifi':
        return 'WIFI:S:\${_ssidController.text};T:\${_encryptionTypeController.text};P:\${_passwordController.text};;';
      case 'geo':
        return 'geo:\${_latitudeController.text},\${_longitudeController.text}';
      default:
        return _contentController.text;
    }
  }

  Barcode _getBarcodeFromFormat(String format) {
    switch (format) {
      case 'code128':
        return Barcode.code128();
      case 'code39':
        return Barcode.code39();
      case 'code93':
        return Barcode.code93();
      case 'codabar':
        return Barcode.codabar();
      case 'dataMatrix':
        return Barcode.dataMatrix();
      case 'ean13':
        return Barcode.ean13();
      case 'ean8':
        return Barcode.ean8();
      case 'itf':
        return Barcode.itf();
      case 'pdf417':
        return Barcode.pdf417();
      case 'qr':
        return Barcode.qrCode();
      case 'upca':
        return Barcode.upcA();
      case 'upce':
        return Barcode.upcE();
      default:
        return Barcode.code128();
    }
  }

  Future<void> _generateCode() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CodeProvider>();
    if (!provider.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, initializing...')),
      );
      return;
    }
    setState(() => _isGenerating = true);

    try {
      final data = _selectedType == 'qr'
          ? _generateQrContent()
          : _contentController.text.trim();

      final entry = CodeEntry(
        content: data,
        type: _selectedType,
        timestamp: DateTime.now(),
        format: _selectedType == 'barcode' ? _selectedFormat : _selectedQrType,
      );
      await provider.addEntry(entry);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully!')),
      );
      // ✅ Show bottom sheet after generation
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        isScrollControlled: true,
        builder: (context) => ResultSheet(
          result: data,
          type: _selectedType,
          format:
              _selectedType == 'barcode' ? _selectedFormat : _selectedQrType,
        ),
      );
      setState(() {
        _generatedData = data;
        for (final c in [
          _contentController,
          _nameController,
          _phoneController,
          _emailController,
          _subjectController,
          _messageController,
          _urlController,
          _eventNameController,
          _locationController,
          _startDateController,
          _endDateController,
          _descriptionController,
        ]) {
          c.clear();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String();
    }
  }

  Widget _buildQrFields() {
    switch (_selectedQrType) {
      case 'url':
        return TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(labelText: 'URL'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Enter a URL' : null,
        );
      case 'contact':
        return Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter name' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null,
            ),
          ],
        );
      case 'email':
        return Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter email' : null,
            ),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        );
      case 'sms':
        return Column(
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter phone' : null,
            ),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        );
      case 'event':
        return Column(
          children: [
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Enter event name' : null,
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(labelText: 'Start Date'),
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Select a start date' : null,
            ),
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(labelText: 'End Date'),
              readOnly: true,
              onTap: () => _selectDate(context, _endDateController),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Select an end date' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        );
      case 'wifi':
        return Column(
          children: [
            TextFormField(
              controller: _ssidController,
              decoration: const InputDecoration(labelText: 'SSID'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter SSID' : null,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter password' : null,
            ),
            DropdownButtonFormField<String>(
              value: _encryptionTypeController.text.isEmpty
                  ? 'WPA'
                  : _encryptionTypeController.text,
              decoration: const InputDecoration(labelText: 'Encryption Type'),
              items: const [
                DropdownMenuItem(value: 'WPA', child: Text('WPA')),
                DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                DropdownMenuItem(value: 'nopass', child: Text('No Password')),
              ],
              onChanged: (v) {
                if (v != null)
                  setState(() => _encryptionTypeController.text = v);
              },
            ),
          ],
        );
      case 'geo':
        return Column(
          children: [
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter latitude' : null,
            ),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              validator: (v) => (v?.isEmpty ?? true) ? 'Enter longitude' : null,
            ),
          ],
        );
      case 'text':
      default:
        return TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(labelText: 'Text'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Enter text' : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CodeProvider>(
      builder: (context, provider, Widget? child) {
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Generate Code')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment<String>(
                            value: 'qr',
                            icon: Icon(Icons.qr_code),
                            label: Text('QR')),
                        ButtonSegment<String>(
                            value: 'barcode',
                            icon: Icon(Icons.qr_code_2),
                            label: Text('Barcode')),
                      ],
                      selected: <String>{_selectedType},
                      onSelectionChanged: (s) =>
                          setState(() => _selectedType = s.first),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedType == 'qr') ...[
                      DropdownButtonFormField<String>(
                        value: _selectedQrType,
                        decoration: const InputDecoration(labelText: 'QR Type'),
                        items: const [
                          DropdownMenuItem(value: 'text', child: Text('Text')),
                          DropdownMenuItem(value: 'url', child: Text('URL')),
                          DropdownMenuItem(
                              value: 'contact', child: Text('Contact')),
                          DropdownMenuItem(
                              value: 'email', child: Text('Email')),
                          DropdownMenuItem(value: 'sms', child: Text('SMS')),
                          DropdownMenuItem(
                              value: 'event', child: Text('Event')),
                          DropdownMenuItem(value: 'wifi', child: Text('WiFi')),
                          DropdownMenuItem(
                              value: 'geo', child: Text('Geolocation')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedQrType = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildQrFields(),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        value: _selectedFormat,
                        decoration:
                            const InputDecoration(labelText: 'Barcode Format'),
                        items: const [
                          DropdownMenuItem(
                              value: 'code128', child: Text('Code 128')),
                          DropdownMenuItem(
                              value: 'code39', child: Text('Code 39')),
                          DropdownMenuItem(
                              value: 'code93', child: Text('Code 93')),
                          DropdownMenuItem(
                              value: 'codabar', child: Text('Codabar')),
                          DropdownMenuItem(
                              value: 'dataMatrix', child: Text('Data Matrix')),
                          DropdownMenuItem(
                              value: 'ean13', child: Text('EAN-13')),
                          DropdownMenuItem(value: 'ean8', child: Text('EAN-8')),
                          DropdownMenuItem(value: 'itf', child: Text('ITF')),
                          DropdownMenuItem(
                              value: 'pdf417', child: Text('PDF417')),
                          DropdownMenuItem(value: 'qr', child: Text('QR Code')),
                          DropdownMenuItem(value: 'upca', child: Text('UPC-A')),
                          DropdownMenuItem(value: 'upce', child: Text('UPC-E')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedFormat = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(labelText: 'Content'),
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Enter content' : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isGenerating ? null : _generateCode,
                      child: _isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Generate'),
                    ),
                    if (_generatedData != null) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: _selectedType == 'qr'
                            ? QrImageView(
                                data: _generatedData!,
                                version: QrVersions.auto,
                                size: 200,
                                backgroundColor: _backgroundColor,
                                errorCorrectionLevel: _errorCorrectionLevel,
                                embeddedImage: _logoFile != null
                                    ? FileImage(_logoFile!)
                                    : null,
                                embeddedImageStyle: const QrEmbeddedImageStyle(
                                    size: Size(40, 40)),
                              )
                            : BarcodeWidget(
                                barcode: _getBarcodeFromFormat(_selectedFormat),
                                data: _generatedData!,
                                width: 200,
                                height: 80,
                                drawText: true,
                              ),
                      ),
                    ],
                  ]),
            ),
          ),
        );
      },
    );
  }
}
