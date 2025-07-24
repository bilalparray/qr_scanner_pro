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

  microQR(
    'Micro QR',
    'Compact QR for small data',
    BarcodeCategory.qrCodes,
    '12345',
  ),
  // Additional QR types

  // SMS QR code (phone number and optionally message)
  qrCodeSms(
    'QR SMS',
    'SMS message QR',
    BarcodeCategory.qrCodes,
    'SMSTO:+1234567890:Hello from QR!',
  ),

  // Email QR code (email with subject and body)
  qrCodeEmail(
    'QR Email',
    'Email QR',
    BarcodeCategory.qrCodes,
    'mailto:example@example.com?subject=Hello&body=This%20is%20a%20test',
  ),

  // PDF QR code (assuming link to PDF)
  qrCodePDF(
    'QR PDF',
    'PDF document link QR',
    BarcodeCategory.qrCodes,
    'https://www.example.com/myfile.pdf',
  ),

  // Multi-URL QR code (custom format or concatenated URLs - optional)
  qrCodeMultiURl(
    'QR Multi-URL',
    'Multiple URLs in one QR (comma-separated or custom)',
    BarcodeCategory.qrCodes,
    'https://example1.com,https://example2.com',
  ),

  // Contact QR code (like vCard but you might want a different detail)
  qrCodeVCard(
    'QR Contact',
    'Contact info QR',
    BarcodeCategory.qrCodes,
    '''
BEGIN:VCARD
VERSION:3.0
N:Doe;Jane;;;
FN:Jane Doe
ORG:Company;
TEL;TYPE=WORK,VOICE:+1234567890
EMAIL:jane.doe@example.com
END:VCARD
''',
  ),

  // Geolocation QR code (latitude and longitude)
  qrCodeGeo(
    'QR Geo',
    'Geolocation QR',
    BarcodeCategory.qrCodes,
    'geo:37.7749,-122.4194',
  ),

  // App QR code (e.g., link to app store or deep link)
  qrCodeAPP(
    'QR App',
    'App download or deep link QR',
    BarcodeCategory.qrCodes,
    'https://play.google.com/store/apps/details?id=com.example.app',
  ),

  // Phone QR code (Call phone number)
  qrCodePhone(
    'QR Phone',
    'Phone call QR',
    BarcodeCategory.qrCodes,
    'TEL:+1234567890',
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
