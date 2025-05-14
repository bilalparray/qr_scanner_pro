import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ScanResultScreen extends StatelessWidget {
  final String content;
  final String format;
  final DateTime timestamp;

  const ScanResultScreen({
    super.key,
    required this.content,
    required this.format,
    required this.timestamp,
  });

  void _handleContact(BuildContext context) async {
    try {
      final contact = Contact.fromVCard(content);
      if (!await FlutterContacts.requestPermission()) {
        _showSnackBar(context, 'Contact permission denied');
        return;
      }
      await contact.insert();
      _showSnackBar(context, 'Contact saved successfully');
    } catch (e) {
      _showSnackBar(context, 'Error saving contact: $e');
    }
  }

  void _handleWifi(BuildContext context) {
    final wifiPattern = RegExp(r'WIFI:S:(.+?);T:(.+?);P:(.+?);;');
    final match = wifiPattern.firstMatch(content);
    if (match != null) {
      final ssid = match.group(1);
      final security = match.group(2);
      final password = match.group(3);

      WiFiForIoTPlugin.connect(
        ssid!,
        password: password,
        security: _parseSecurity(security!),
      ).then((success) {
        _showSnackBar(
            context, success ? 'Connected to $ssid' : 'Connection failed');
      });
    }
  }

  NetworkSecurity _parseSecurity(String security) {
    switch (security) {
      case 'WPA':
        return NetworkSecurity.WPA;
      case 'WEP':
        return NetworkSecurity.WEP;
      default:
        return NetworkSecurity.WPA;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = Uri.tryParse(content)?.hasAbsolutePath ?? false;
    final isContact = content.startsWith('BEGIN:VCARD');
    final isWifi = content.startsWith('WIFI:');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(content),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Scan Type', format),
            _buildInfoRow('Timestamp', timestamp.toString()),
            const SizedBox(height: 20),
            const Text(
              'Content:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildActionButtons(isUrl, isContact, isWifi),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isUrl, bool isContact, bool isWifi) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (isUrl)
          ElevatedButton.icon(
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open URL'),
            onPressed: () => launchUrl(Uri.parse(content)),
          ),
        if (isContact)
          ElevatedButton(
            onPressed: () => _handleContact,
            child: const Text('Save Contact'),
          ),
        if (isWifi)
          ElevatedButton(
            onPressed: () => _handleWifi,
            child: const Text('Connect to WiFi'),
          ),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: content));
            // _showSnackBar(context, 'Copied to clipboard'); // Added context
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.history),
          label: const Text('Add to History'),
          onPressed: () {
            // _showSnackBar(context, 'Added to history'); // Added context
          },
        ),
      ],
    );
  }
}
