// lib/services/qr_parser.dart
import 'package:intl/intl.dart';
import 'package:qr_scanner_pro/models/scan_result.dart';

class QRParser {
  static ScanResultModel parse(String raw) {
    final data = raw.trim();

    if (_isUrl(data)) {
      return ScanResultModel(raw: data, type: ScanDataType.url);
    }
    if (_isVCard(data)) {
      return ScanResultModel(
        raw: data,
        type: ScanDataType.contact,
        parsed: _parseVCard(data),
      );
    }
    if (_isVEvent(data)) {
      return ScanResultModel(
        raw: data,
        type: ScanDataType.calendar,
        parsed: _parseVEvent(data),
      );
    }
    if (_isEmail(data)) {
      return ScanResultModel(
        raw: data,
        type: ScanDataType.email,
        parsed: {'email': data.replaceFirst('mailto:', '')},
      );
    }
    if (_isSms(data)) {
      final parts = data.replaceFirst('SMSTO:', '').split(':');
      return ScanResultModel(
        raw: data,
        type: ScanDataType.sms,
        parsed: {'phone': parts[0], 'message': parts.sublist(1).join(':')},
      );
    }
    if (_isTel(data)) {
      return ScanResultModel(
        raw: data,
        type: ScanDataType.phone,
        parsed: {'phone': data.replaceFirst('tel:', '')},
      );
    }
    if (_isWifi(data)) {
      return ScanResultModel(
        raw: data,
        type: ScanDataType.wifi,
        parsed: _parseWifi(data),
      );
    }

    return ScanResultModel(raw: data, type: ScanDataType.text);
  }

  // --- helpers --------------------------------------------------------------

  static bool _isUrl(String s) =>
      RegExp(r'^(http|https)://', caseSensitive: false).hasMatch(s);

  static bool _isEmail(String s) => s.startsWith('mailto:');

  static bool _isSms(String s) => s.startsWith('SMSTO:');

  static bool _isTel(String s) => s.startsWith('tel:');

  static bool _isVCard(String s) =>
      s.contains('BEGIN:VCARD') && s.contains('END:VCARD');

  static bool _isVEvent(String s) =>
      s.contains('BEGIN:VEVENT') && s.contains('END:VEVENT');

  static bool _isWifi(String s) => s.startsWith('WIFI:');

  static Map<String, dynamic> _parseVCard(String input) {
    final lines = input.split(RegExp(r'\r?\n'));
    final map = <String, String>{};
    for (var line in lines) {
      final idx = line.indexOf(':');
      if (idx == -1) continue;
      final key = line.substring(0, idx).toUpperCase();
      final value = line.substring(idx + 1);
      map[key] = value;
    }
    return {
      'name': map['FN'] ?? '',
      'org': map['ORG'],
      'title': map['TITLE'],
      'tel': map['TEL'],
      'email': map['EMAIL'],
      'address': map['ADR'],
    };
  }

  static Map<String, dynamic> _parseVEvent(String input) {
    final lines = input.split(RegExp(r'\r?\n'));
    final map = <String, String>{};
    for (var line in lines) {
      final idx = line.indexOf(':');
      if (idx == -1) continue;
      final key = line.substring(0, idx).toUpperCase();
      final value = line.substring(idx + 1);
      map[key] = value;
    }

    DateTime? parseDt(String? dt) {
      if (dt == null) return null;
      try {
        return DateFormat("yyyyMMdd'T'HHmmss'Z'").parseUtc(dt);
      } catch (_) {
        return null;
      }
    }

    return {
      'summary': map['SUMMARY'],
      'description': map['DESCRIPTION'],
      'location': map['LOCATION'],
      'start': parseDt(map['DTSTART']),
      'end': parseDt(map['DTEND']),
    };
  }

  static Map<String, dynamic> _parseWifi(String input) {
    final map = <String, String>{};
    for (var part in input.replaceFirst('WIFI:', '').split(';')) {
      if (part.isEmpty) continue;
      final idx = part.indexOf(':');
      if (idx == -1) continue;
      map[part.substring(0, idx)] = part.substring(idx + 1);
    }
    return {
      'ssid': map['S'],
      'type': map['T'],
      'password': map['P'],
    };
  }
}
