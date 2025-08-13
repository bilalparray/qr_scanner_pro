import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scanner/models/scan_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ActionHandler {
  const ActionHandler._();

  static Future<void> copyToClipboard(BuildContext ctx, String data) async {
    final messenger = ScaffoldMessenger.of(ctx);
    await Clipboard.setData(ClipboardData(text: data));
    messenger.showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  static Future<void> share(BuildContext ctx, String data) async {
    final shareParams = ShareParams(text: data);
    await SharePlus.instance.share(shareParams);
  }

  static Future<void> saveToFile(BuildContext ctx, String data) async {
    final messenger = ScaffoldMessenger.of(ctx);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    await file.writeAsString(data);
    messenger.showSnackBar(
      SnackBar(content: Text('Saved: ${file.path}')),
    );
  }

  static Future<void> handleTypeSpecific(
    BuildContext ctx,
    ScanResultModel result,
  ) async {
    switch (result.type) {
      case ScanDataType.url:
        await _openUri(ctx, Uri.parse(result.raw));
        break;
      case ScanDataType.phone:
        await _openUri(ctx, Uri.parse('tel:${result.parsed!['phone']}'));
        break;
      case ScanDataType.email:
        await _openUri(ctx, Uri.parse(result.raw));
        break;
      case ScanDataType.sms:
        final phone = result.parsed!['phone'] as String;
        final msg = Uri.encodeComponent(result.parsed!['message'] as String);
        await _openUri(ctx, Uri.parse('sms:$phone?body=$msg'));
        break;
      case ScanDataType.calendar:
        _snack(ctx, 'Add to calendar via share/import');
        break;
      case ScanDataType.contact:
        saveContactFromVCard(ctx, result.raw);
        _snack(ctx, 'Use vCard file to import contact');
        break;

      case ScanDataType.wifi:
        // Assuming your parsed Wi-Fi info contains SSID and password
        final ssid = result.parsed?['ssid'] ?? '';
        final password = result.parsed?['password'] ?? '';
        final security = result.parsed?['type'] ?? 'WPA'; // or 'WEP', or 'NONE'

        if (ssid.isNotEmpty) {
          // Attempt to connect to the Wi-Fi network
          final bool connected = await WiFiForIoTPlugin.connect(
            ssid,
            password: password,
            security: security.toLowerCase() == 'wep'
                ? NetworkSecurity.WEP
                : security.toLowerCase() == 'none'
                    ? NetworkSecurity.NONE
                    : NetworkSecurity.WPA,
            joinOnce: true,
            withInternet: true,
          );

          if (connected) {
            _snack(ctx, 'Connected to Wi-Fi: $ssid');
          } else {
            _snack(ctx, 'Failed to connect to Wi-Fi: $ssid');
          }
        } else {
          _snack(ctx, 'SSID not found in Wi-Fi credentials');
        }
        break;

      case ScanDataType.text:
        // nothing special
        break;
    }
  }

  // --------------------------------------------------------------------------

  static Future<void> _openUri(BuildContext ctx, Uri uri) async {
    final messenger = ScaffoldMessenger.of(ctx);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Cannot open URI')),
      );
    }
  }

  static void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  static Future<void> saveContactFromVCard(
      BuildContext ctx, String rawVCard) async {
    await FlutterContacts.requestPermission();
    if (!await FlutterContacts.requestPermission()) {
      _snack(ctx, 'Contact permission denied');
      return;
    }

    try {
      String? getValue(String key, String rawVCard) {
        // Matches KEY optionally followed by parameters (;XXX=YYY), then a colon and value
        final pattern = RegExp(
          '^${RegExp.escape(key)}(?:;[^:]+)?:\\s*(.*)\$',
          caseSensitive: false,
          multiLine: true,
        );

        final match = pattern.firstMatch(rawVCard);
        if (match != null && match.groupCount >= 1) {
          return match.group(1)?.trim();
        }
        return null;
      }

      // Extract fields manually (example for FN, TEL, EMAIL)
      final fullName = getValue('FN', rawVCard) ?? '';
      final phone = getValue('TEL', rawVCard) ?? '';
      final email = getValue('EMAIL', rawVCard) ?? '';

      final contact = Contact();

      if (fullName.isNotEmpty) {
        // You can further split the fullName into first/last if you want
        contact.name = Name(first: fullName);
      }

      if (phone.isNotEmpty) {
        contact.phones = [Phone(phone, label: PhoneLabel.mobile)];
      }

      if (email.isNotEmpty) {
        contact.emails = [Email(email)];
      }

      await contact.insert();
      _snack(ctx, 'Contact saved successfully.');
    } catch (e) {
      _snack(ctx, 'Failed to save contact: $e');
    }
  }
}
