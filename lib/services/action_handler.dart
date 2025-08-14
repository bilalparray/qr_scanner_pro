import 'dart:io';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Event;
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
        openGmail(result.parsed!['email'] as String);
        break;

      case ScanDataType.sms:
        final phone = result.parsed!['phone'] as String;
        final msg = Uri.encodeComponent(result.parsed!['message'] as String);
        await _openUri(ctx, Uri.parse('sms:$phone?body=$msg'));
        break;
      case ScanDataType.calendar:
        addToCalender(ctx, result);
        break;
      case ScanDataType.contact:
        saveContactFromVCard(ctx, result.raw);
        break;

      case ScanDataType.wifi:
        connectToWifi(ctx, result);
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

  static Future<void> openGmail(String email,
      {String? subject, String? body}) async {
    final androidUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    // Gmail's Android package name
    const gmailPackage = 'com.google.android.gm';

    final launchUri = Uri.parse(
        'intent://${androidUri.toString().replaceFirst('mailto:', '')}#Intent;scheme=mailto;package=$gmailPackage;end');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Gmail app not found, falling back to default mail client');
      await launchUrl(androidUri, mode: LaunchMode.externalApplication);
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

  static Future<void> connectToWifi(ctx, result) async {
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
  }

  static Future<void> addToCalender(BuildContext ctx, dynamic result) async {
    try {
      // Extract event details from result.parsed or raw data
      // Adjust keys according to your parsing logic
      final String title = result.parsed?['summary'] ?? 'Untitled Event';
      final String description = result.parsed?['description'] ?? '';
      final String location = result.parsed?['location'] ?? '';

      // Parse start and end date/time strings into DateTime objects
      // Expecting ISO8601 or similar format in your parsed data
      DateTime? startDate;
      DateTime? endDate;
      if (result.parsed?['dtstart'] != null) {
        startDate = DateTime.tryParse(result.parsed['dtstart']);
      }
      if (result.parsed?['dtend'] != null) {
        endDate = DateTime.tryParse(result.parsed['dtend']);
      }

      // If startDate is null, fallback to now
      startDate ??= DateTime.now();

      // If endDate is null, fallback to 1 hour after startDate
      endDate ??= startDate.add(Duration(hours: 1));

      final event = Event(
        title: title,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        // You can set other parameters like allDay, iosParams, androidParams here if needed
      );

      final success = await Add2Calendar.addEvent2Cal(event);
      if (success) {
        _snack(ctx, 'Event added to calendar');
      } else {
        _snack(ctx, 'Failed to add event to calendar');
      }
    } catch (e) {
      _snack(ctx, 'Failed to add event to calendar: $e');
    }
  }
}
