import 'package:flutter/material.dart';
import 'package:qr_scanner/models/generate_code.dart';
import 'package:share_plus/share_plus.dart';

class BarcodeUtils {
  static String buildDataString(
      BarcodeCodeType type, Map<String, TextEditingController> controllers) {
    switch (type) {
      case BarcodeCodeType.qrCodeWiFi:
        final ssid = controllers['ssid']?.text ?? '';
        final password = controllers['password']?.text ?? '';
        final security = controllers['security']?.text ?? 'WPA';
        return 'WIFI:T:$security;S:$ssid;P:$password;;';

      case BarcodeCodeType.qrCodeVCard:
        final name = controllers['name']?.text ?? '';
        final phone = controllers['phone']?.text ?? '';
        final email = controllers['email']?.text ?? '';
        final org = controllers['organization']?.text ?? '';
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nORG:$org\nTEL:$phone\nEMAIL:$email\nEND:VCARD';

      default:
        return controllers['data']?.text ?? '';
    }
  }
}

Future<void> shareContent({
  required String text,
  List<XFile>? files,
}) async {
  final params = ShareParams(text: text, files: files);
  await SharePlus.instance.share(params);
}
