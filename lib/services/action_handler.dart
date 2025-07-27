import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scanner/models/scan_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
        _snack(ctx, 'Use vCard file to import contact');
        break;
      case ScanDataType.wifi:
        _snack(ctx, 'Wi-Fi credentials copied');
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
}
