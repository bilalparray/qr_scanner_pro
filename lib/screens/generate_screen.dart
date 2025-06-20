// lib/screens/generate_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_scanner/screens/code_generator.dart';
import 'package:qr_scanner/widgets/barcode_fields.dart';
import 'package:qr_scanner/widgets/qr_fields.dart';

import '../providers/code_provider.dart';
import '../models/code_entry.dart';
import 'package:qr_scanner/widgets/code_bottom_sheet.dart';

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
  final _encryptionTypeController = TextEditingController(text: 'WPA');
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
          ? CodeGenerator.generateQrContent(
              selectedQrType: _selectedQrType,
              text: _contentController.text.trim(),
              name: _nameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              subject: _subjectController.text,
              message: _messageController.text,
              eventName: _eventNameController.text,
              location: _locationController.text,
              startDate: _startDateController.text,
              endDate: _endDateController.text,
              description: _descriptionController.text,
              ssid: _ssidController.text,
              password: _passwordController.text,
              encryptionType: _encryptionTypeController.text,
              latitude: _latitudeController.text,
              longitude: _longitudeController.text,
            )
          : _contentController.text.trim();

      final entry = CodeEntry(
        content: data,
        type: _selectedType,
        timestamp: DateTime.now(),
        format: _selectedType == 'barcode' ? _selectedFormat : _selectedQrType,
      );
      await provider.addEntry(entry);

      if (!mounted) return;

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
                      QrFieldsWidget(
                        selectedQrType: _selectedQrType,
                        contentController: _contentController,
                        nameController: _nameController,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        subjectController: _subjectController,
                        messageController: _messageController,
                        urlController: _urlController,
                        eventNameController: _eventNameController,
                        locationController: _locationController,
                        startDateController: _startDateController,
                        endDateController: _endDateController,
                        descriptionController: _descriptionController,
                        ssidController: _ssidController,
                        passwordController: _passwordController,
                        encryptionTypeController: _encryptionTypeController,
                        latitudeController: _latitudeController,
                        longitudeController: _longitudeController,
                        selectDate: _selectDate,
                      ),
                    ] else ...[
                      BarcodeFieldsWidget(
                        selectedFormat: _selectedFormat,
                        contentController: _contentController,
                        onFormatChanged: (v) =>
                            setState(() => _selectedFormat = v),
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
                                barcode: CodeGenerator.getBarcodeFromFormat(
                                    _selectedFormat),
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
