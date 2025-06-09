// lib/utils/code_generator.dart
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class CodeGenerator {
  // Generates the QR content based on type and controllers
  static String generateQrContent({
    required String selectedQrType,
    required String text,
    required String name,
    required String phone,
    required String email,
    required String subject,
    required String message,
    required String eventName,
    required String location,
    required String startDate,
    required String endDate,
    required String description,
    required String ssid,
    required String password,
    required String encryptionType,
    required String latitude,
    required String longitude,
  }) {
    switch (selectedQrType) {
      case 'url':
        return text;
      case 'contact':
        return '''
BEGIN:VCARD
VERSION:3.0
FN:\$name
TEL:\$phone
EMAIL:\$email
END:VCARD
''';
      case 'email':
        return 'mailto:\$email?subject=\${Uri.encodeComponent(subject)}&body=\${Uri.encodeComponent(message)}';
      case 'sms':
        return 'sms:\$phone?body=\${Uri.encodeComponent(message)}';
      case 'event':
        return '''
BEGIN:VEVENT
SUMMARY:\$eventName
LOCATION:\$location
DTSTART:\$startDate
DTEND:\$endDate
DESCRIPTION:\$description
END:VEVENT
''';
      case 'wifi':
        return 'WIFI:S:\$ssid;T:\$encryptionType;P:\$password;;';
      case 'geo':
        return 'geo:\$latitude,\$longitude';
      default:
        return text;
    }
  }

  // Returns the Barcode widget based on format
  static Barcode getBarcodeFromFormat(String format) {
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
}
