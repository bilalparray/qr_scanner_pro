// history_model.dart
import 'package:qr_scanner/models/generate_code.dart';

class HistoryItem {
  final String content;
  final String snippet;
  final BarcodeCodeType codeType; // new field
  final DateTime timestamp;
  final bool isGenerated;

  HistoryItem({
    required this.content,
    required this.snippet,
    required this.codeType,
    required this.timestamp,
    required this.isGenerated,
  });

  Map<String, dynamic> toMap() => {
        'content': content,
        'snippet': snippet,
        'codeType': codeType.name, // serialize by enum name
        'timestamp': timestamp.toIso8601String(),
        'isGenerated': isGenerated,
      };

  factory HistoryItem.fromMap(Map<String, dynamic> map) => HistoryItem(
        content: map['content'] as String,
        snippet: map['snippet'] as String,
        codeType: BarcodeCodeType.values.firstWhere(
          (e) => e.name == (map['codeType'] as String),
          orElse: () => BarcodeCodeType.qrCode,
        ), // deserialize
        timestamp: DateTime.parse(map['timestamp'] as String),
        isGenerated: map['isGenerated'] as bool,
      );
}
