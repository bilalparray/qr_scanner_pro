// ==================== DATA MODELS ====================

import 'package:flutter/material.dart';

enum BarcodeCategory {
  qrCodes('QR Codes', Icons.qr_code_2),
  oneDimensional('1D Linear', Icons.view_stream),
  twoDimensional('2D Matrix', Icons.grid_4x4),
  postal('Postal', Icons.local_post_office),
  specialized('Specialized', Icons.settings);

  const BarcodeCategory(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

enum BarcodeCodeType {
  // QR Codes
  qrCode(
    'QR Code',
    'Standard QR Code',
    BarcodeCategory.qrCodes,
    'https://flutter.dev',
  ),
  qrCodeWiFi(
    'QR WiFi',
    'WiFi credentials QR',
    BarcodeCategory.qrCodes,
    'MyWiFi',
  ),
  qrCodeVCard(
    'QR vCard',
    'Contact information QR',
    BarcodeCategory.qrCodes,
    'John Doe',
  ),
  microQR(
    'Micro QR',
    'Compact QR for small data',
    BarcodeCategory.qrCodes,
    '12345',
  ),

  // 1D Linear Barcodes
  code128(
    'Code 128',
    'High-density linear barcode',
    BarcodeCategory.oneDimensional,
    'Hello World',
  ),
  code128A(
    'Code 128A',
    'Uppercase and control chars',
    BarcodeCategory.oneDimensional,
    'HELLO123',
  ),
  code128B(
    'Code 128B',
    'ASCII character set',
    BarcodeCategory.oneDimensional,
    'Hello123!',
  ),
  code128C(
    'Code 128C',
    'Numeric pairs only',
    BarcodeCategory.oneDimensional,
    '123456',
  ),
  code39(
    'Code 39',
    'Alphanumeric barcode',
    BarcodeCategory.oneDimensional,
    'CODE39',
  ),
  code39Extended(
    'Code 39 Ext',
    'Extended ASCII Code 39',
    BarcodeCategory.oneDimensional,
    'Code39+',
  ),
  code93(
    'Code 93',
    'Compact alphanumeric',
    BarcodeCategory.oneDimensional,
    'CODE93',
  ),
  code93Extended(
    'Code 93 Ext',
    'Extended ASCII Code 93',
    BarcodeCategory.oneDimensional,
    'Code93+',
  ),
  ean8(
    'EAN-8',
    '8-digit product code',
    BarcodeCategory.oneDimensional,
    '12345678',
  ),
  ean13(
    'EAN-13',
    '13-digit product code',
    BarcodeCategory.oneDimensional,
    '1234567890123',
  ),
  upcA(
    'UPC-A',
    '12-digit Universal Product Code',
    BarcodeCategory.oneDimensional,
    '123456789012',
  ),
  upcE('UPC-E', 'Compressed UPC', BarcodeCategory.oneDimensional, '01234567'),
  codabar(
    'Codabar',
    'Self-checking barcode',
    BarcodeCategory.oneDimensional,
    'A123456B',
  ),
  itf(
    'ITF',
    'Interleaved 2 of 5',
    BarcodeCategory.oneDimensional,
    '1234567890',
  ),
  itf14(
    'ITF-14',
    '14-digit shipping code',
    BarcodeCategory.oneDimensional,
    '12345678901234',
  ),

  // 2D Barcodes
  dataMatrix(
    'Data Matrix',
    '2D matrix barcode',
    BarcodeCategory.twoDimensional,
    'Data Matrix Test',
  ),
  pdf417(
    'PDF417',
    'Portable Data File',
    BarcodeCategory.twoDimensional,
    'PDF417 Example',
  ),
  aztec(
    'Aztec Code',
    '2D barcode with bullseye',
    BarcodeCategory.twoDimensional,
    'Aztec Test',
  ),
  maxiCode(
    'MaxiCode',
    'Fixed-size postal barcode',
    BarcodeCategory.twoDimensional,
    '12345',
  ),

  // Postal Barcodes
  postnet('POSTNET', 'US Postal Service', BarcodeCategory.postal, '12345'),
  planet(
    'PLANET',
    'US Postal tracking',
    BarcodeCategory.postal,
    '123456789012',
  ),
  australianPost(
    'AU Post',
    'Australian Post barcode',
    BarcodeCategory.postal,
    '1234567890',
  ),
  royalMail(
    'Royal Mail',
    'UK Royal Mail barcode',
    BarcodeCategory.postal,
    'SN34RD1A',
  ),

  // Specialized
  gs1_128(
    'GS1-128',
    'Supply chain barcode',
    BarcodeCategory.specialized,
    '01123456789012',
  ),
  pharmacode(
    'Pharmacode',
    'Pharmaceutical barcode',
    BarcodeCategory.specialized,
    '12345',
  ),
  pzn('PZN', 'German pharmaceutical', BarcodeCategory.specialized, '1234567');

  const BarcodeCodeType(
    this.displayName,
    this.description,
    this.category,
    this.exampleData,
  );

  final String displayName;
  final String description;
  final BarcodeCategory category;
  final String exampleData;
}

class BarcodeInputField {
  final String key;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? pattern;
  final bool isRequired;
  final List<String>? dropdownOptions;

  const BarcodeInputField({
    required this.key,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.pattern,
    this.isRequired = true,
    this.dropdownOptions,
  });
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  static const ValidationResult valid = ValidationResult(isValid: true);

  static ValidationResult invalid(String message) {
    return ValidationResult(isValid: false, errorMessage: message);
  }
}
