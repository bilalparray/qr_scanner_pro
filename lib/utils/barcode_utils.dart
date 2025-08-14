import 'package:flutter/material.dart';
import 'package:qr_scanner_pro/models/generate_code.dart';
import 'package:share_plus/share_plus.dart';

class BarcodeUtils {
  static String buildDataString(
    BarcodeCodeType type,
    Map<String, TextEditingController> controllers,
  ) {
    switch (type) {
      // 1) Standard QR & Micro QR just embed arbitrary text/data:
      case BarcodeCodeType.qrCode:
      case BarcodeCodeType.microQR:
        return controllers['data']?.text ?? '';

      // 2) Wi‑Fi credentials
      case BarcodeCodeType.qrCodeWiFi:
        final ssid = controllers['ssid']?.text ?? '';
        final password = controllers['password']?.text ?? '';
        final security = controllers['security']?.text ?? 'WPA';
        return 'WIFI:T:$security;S:$ssid;P:$password;;';

      // 3) SMS
      case BarcodeCodeType.qrCodeSms:
        final phone = controllers['phone']?.text ?? '';
        final message = controllers['message']?.text ?? '';
        return 'SMSTO:$phone:$message';

      // 4) Email (with optional subject/body)
      case BarcodeCodeType.qrCodeEmail:
        final email = controllers['email']?.text ?? '';
        final subject = controllers['subject']?.text ?? '';
        final body = controllers['body']?.text ?? '';
        final params = <String>[];
        if (subject.isNotEmpty) {
          params.add('subject=${Uri.encodeComponent(subject)}');
        }
        if (body.isNotEmpty) params.add('body=${Uri.encodeComponent(body)}');
        final query = params.isNotEmpty ? '?${params.join("&")}' : '';
        return 'mailto:$email$query';

      // 5) PDF link (just a URL to a PDF)
      case BarcodeCodeType.qrCodePDF:
        return controllers['data']?.text ?? '';

      // 6) Multi‑URL (comma or newline separated)
      case BarcodeCodeType.qrCodeMultiURl:
        // e.g. "https://a.com,https://b.com"
        // or split and join with newlines:
        final raw = controllers['data']?.text ?? '';
        // normalize commas → newlines for better scanner support:
        return raw.replaceAll(',', '\n');

      // 7) vCard / contact
      case BarcodeCodeType.qrCodeVCard:
        final name = controllers['name']?.text ?? '';
        final org = controllers['organization']?.text ?? '';
        final phone = controllers['phone']?.text ?? '';
        final email = controllers['email']?.text ?? '';
        return '''
BEGIN:VCARD
VERSION:3.0
FN:$name
ORG:$org
TEL:$phone
EMAIL:$email
END:VCARD
''';

      // 8) Geo: latitude & longitude
      case BarcodeCodeType.qrCodeGeo:
        final lat = controllers['latitude']?.text ?? '';
        final lng = controllers['longitude']?.text ?? '';
        return 'geo:$lat,$lng';

      // 9) App deep‐link or store URL
      case BarcodeCodeType.qrCodeAPP:
        final appLink = controllers['url']?.text ?? '';
        return appLink;

      // 10) Phone call
      case BarcodeCodeType.qrCodePhone:
        final tel = controllers['phone']?.text ?? '';
        return 'TEL:$tel';

      // fallback to raw data textbox
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
