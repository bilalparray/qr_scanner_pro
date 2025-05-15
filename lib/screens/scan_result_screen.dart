import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:intl/intl.dart';

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

  // region [Handlers]
  void _handleContact(BuildContext context) async {
    try {
      final contact = contacts.Contact.fromVCard(content);
      if (!await contacts.FlutterContacts.requestPermission()) {
        _showSnackBar(context, 'Contact permission denied');
        return;
      }
      await contact.insert();
      _showSnackBar(context, 'Contact saved successfully');
    } catch (e) {
      _showSnackBar(context, 'Error saving contact: $e');
    }
  }

  void _handleSms(BuildContext context) {
    final smsPattern = RegExp(r'^SMSTO:(\+?[\d-]+):?(.*)$');
    final match = smsPattern.firstMatch(content);

    if (match != null) {
      final number = match.group(1);
      final message = Uri.encodeComponent(match.group(2) ?? '');

      final uri = Uri.parse('sms:$number?body=$message');

      launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open SMS app: $e')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid SMS format')),
      );
    }
  }

  void _handleWifi(BuildContext context, String content) async {
    final wifiPattern = RegExp(
      r'^WIFI:(?:S:(.*?);)?(?:T:(.*?);)?(?:P:(.*?);)?(?:H:(true|false);)?;?$',
    );

    final match = wifiPattern.firstMatch(content);

    if (match != null) {
      final ssid = match.group(1);
      final type = match.group(2)?.toLowerCase() ?? 'nopass';
      final password = match.group(3);
      final hidden = match.group(4) == 'true';

      if (ssid == null || ssid.isEmpty) {
        _showSnackBar(context, 'SSID is missing in the WiFi QR code');
        return;
      }

      final security = switch (type) {
        'wep' => NetworkSecurity.WEP,
        'wpa' => NetworkSecurity.WPA,
        _ => NetworkSecurity.NONE,
      };

      try {
        final connected = await WiFiForIoTPlugin.connect(
          ssid,
          password: security == NetworkSecurity.NONE ? null : password,
          security: security,
          joinOnce: true,
          withInternet: true,
          isHidden: hidden,
        );

        _showSnackBar(context,
            connected ? 'Connected to $ssid' : 'Failed to connect to $ssid');
      } catch (e) {
        _showSnackBar(context, 'Error connecting to WiFi: $e');
      }
    } else {
      _showSnackBar(context, 'Invalid WiFi QR code format');
    }
  }

  void _handlePhone(BuildContext context) {
    final phonePattern = RegExp(r'^tel:(\+?[0-9]+)$');
    final match = phonePattern.firstMatch(content.trim());
    if (match != null) {
      launchUrl(Uri.parse(content));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number format')),
      );
    }
  }

  void _handleEmail(BuildContext context) {
    try {
      Uri? uri;

      if (content.startsWith('mailto:')) {
        // Standard mailto: link
        uri = Uri.parse(content);
      } else if (content.startsWith('MATMSG:')) {
        // Parse MATMSG format
        final toMatch = RegExp(r'TO:([^;]+);').firstMatch(content);
        final subMatch = RegExp(r'SUB:([^;]*);').firstMatch(content);
        final bodyMatch = RegExp(r'BODY:([^;]*);').firstMatch(content);

        final to = toMatch?.group(1)?.trim() ?? '';
        final subject = Uri.encodeComponent(subMatch?.group(1)?.trim() ?? '');
        final body = Uri.encodeComponent(bodyMatch?.group(1)?.trim() ?? '');

        uri = Uri.parse('mailto:$to?subject=$subject&body=$body');
      } else if (content.startsWith('SMTP:')) {
        // Optional: SMTP:user@example.com:Subject:Body
        final parts = content.split(':');
        if (parts.length >= 4) {
          final to = parts[1];
          final subject = Uri.encodeComponent(parts[2]);
          final body = Uri.encodeComponent(parts[3]);
          uri = Uri.parse('mailto:$to?subject=$subject&body=$body');
        }
      }

      if (uri != null) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'Unsupported email format');
      }
    } catch (e) {
      _showSnackBar(context, 'Failed to open email app: $e');
    }
  }

  void _handleCalendar(BuildContext context) async {
    try {
      final eventPattern = RegExp(
        r'BEGIN:VEVENT'
        r'(.*?)'
        r'END:VEVENT',
        caseSensitive: false,
        dotAll: true,
      );

      final match = eventPattern.firstMatch(content);
      if (match != null) {
        final eventContent = match.group(1)!;

        final Map<String, String> eventData = {
          for (final line in eventContent.split('\n'))
            if (line.contains(':'))
              line.split(':')[0].trim().toUpperCase(): line.split(':')[1].trim()
        };

        final start =
            DateFormat("yyyyMMdd'T'HHmmss").parse(eventData['DTSTART']!);
        final end = DateFormat("yyyyMMdd'T'HHmmss").parse(eventData['DTEND']!);

        launchUrl(Uri.parse('https://www.google.com/calendar/render?'
            'action=TEMPLATE'
            '&text=${Uri.encodeComponent(eventData['SUMMARY']!)}'
            '&dates=${DateFormat('yyyyMMdd').format(start)}/'
            '${DateFormat('yyyyMMdd').format(end)}'
            '&details=${Uri.encodeComponent(eventData['DESCRIPTION']!)}'
            '&location=${Uri.encodeComponent(eventData['LOCATION']!)}'));
      }
    } catch (e) {
      _showSnackBar(context, 'Error parsing calendar event: $e');
    }
  }

  void _handleLocation(BuildContext context) {
    final geoPattern = RegExp(r'^geo:(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = geoPattern.firstMatch(content);
    if (match != null) {
      final lat = match.group(1);
      final lng = match.group(2);
      launchUrl(Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng'));
    }
  }

  void _handleMeCard(BuildContext context) async {
    try {
      final meCardPattern = RegExp(r'MECARD:(.*?);');
      final data = meCardPattern.allMatches(content).fold(<String, String>{},
          (map, match) {
        final parts = match.group(1)!.split(':');
        if (parts.length == 2) {
          map[parts[0]] = parts[1];
        }
        return map;
      });

      final contact = contacts.Contact()
        ..name.first = data['N'] ?? ''
        ..phones = [contacts.Phone(data['TEL'] ?? '')]
        ..emails = [contacts.Email(data['EMAIL'] ?? '')]
        ..notes = [contacts.Note(data['NOTE'] ?? '')];

      if (!await contacts.FlutterContacts.requestPermission()) {
        _showSnackBar(context, 'Contact permission denied');
        return;
      }
      await contact.insert();
      _showSnackBar(context, 'MeCard contact saved');
    } catch (e) {
      _showSnackBar(context, 'Error saving MeCard: $e');
    }
  }

  void _handleCrypto(BuildContext context) {
    final cryptoPattern = RegExp(r'^(bitcoin|ethereum):.+');
    if (cryptoPattern.hasMatch(content)) {
      Clipboard.setData(ClipboardData(text: content));
      _showSnackBar(context, 'Crypto address copied');
    }
  }
  // endregion

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = Uri.tryParse(content)?.hasAbsolutePath ?? false;
    final isContact = content.startsWith('BEGIN:VCARD');
    final isWifi = content.startsWith('WIFI:');
    final isSms = content.startsWith('SMSTO:');
    final isPhone = content.startsWith('tel:');
    final isEmail = content.startsWith('mailto:') ||
        content.startsWith('MATMSG:') ||
        content.startsWith('SMTP:');

    final isCalendar = content.contains('BEGIN:VEVENT');
    final isLocation = content.startsWith('geo:');
    final isMeCard = content.startsWith('MECARD:');
    final isCrypto = RegExp(r'^(bitcoin|ethereum):').hasMatch(content);

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
            _buildInfoRow('Timestamp',
                DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp)),
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
            _buildActionButtons(
              context,
              isUrl,
              isContact,
              isWifi,
              isSms,
              isPhone,
              isEmail,
              isCalendar,
              isLocation,
              isMeCard,
              isCrypto,
            ),
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

  Widget _buildActionButtons(
    BuildContext context,
    bool isUrl,
    bool isContact,
    bool isWifi,
    bool isSms,
    bool isPhone,
    bool isEmail,
    bool isCalendar,
    bool isLocation,
    bool isMeCard,
    bool isCrypto,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (isUrl)
          _buildActionButton(
              icon: Icons.open_in_browser,
              label: 'Open URL',
              onPressed: () => launchUrl(Uri.parse(content))),
        if (isContact)
          _buildActionButton(
              icon: Icons.contact_page,
              label: 'Save Contact',
              onPressed: () => _handleContact(context)),
        if (isWifi)
          _buildActionButton(
              icon: Icons.wifi,
              label: 'Connect WiFi',
              onPressed: () => _handleWifi(context, content)),
        if (isSms)
          _buildActionButton(
              icon: Icons.message,
              label: 'Send SMS',
              onPressed: () => _handleSms(context)),
        if (isPhone)
          _buildActionButton(
              icon: Icons.phone,
              label: 'Call',
              onPressed: () => _handlePhone(context)),
        if (isEmail)
          _buildActionButton(
              icon: Icons.email,
              label: 'Send Email',
              onPressed: () => _handleEmail(context)),
        if (isCalendar)
          _buildActionButton(
              icon: Icons.calendar_today,
              label: 'Add to Calendar',
              onPressed: () => _handleCalendar(context)),
        if (isLocation)
          _buildActionButton(
              icon: Icons.map,
              label: 'Open Map',
              onPressed: () => _handleLocation(context)),
        if (isMeCard)
          _buildActionButton(
              icon: Icons.contact_phone,
              label: 'Save MeCard',
              onPressed: () => _handleMeCard(context)),
        if (isCrypto)
          _buildActionButton(
              icon: Icons.currency_bitcoin,
              label: 'Copy Address',
              onPressed: () => _handleCrypto(context)),
        _buildActionButton(
          icon: Icons.copy,
          label: 'Copy',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: content));
            _showSnackBar(context, 'Copied to clipboard');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
