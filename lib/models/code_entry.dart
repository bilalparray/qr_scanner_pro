import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'code_entry.g.dart';

@HiveType(typeId: 0)
class CodeEntry extends HiveObject {
  @HiveField(0)
  final String content;

  @HiveField(1)
  final String type; // 'qr' or 'barcode'

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? format; // For barcodes: 'code128', 'ean13', etc.

  @HiveField(4)
  bool isFavorite;

  @HiveField(5)
  final String? title; // Optional title for the entry

  CodeEntry({
    required this.content,
    required this.type,
    required this.timestamp,
    this.format,
    this.isFavorite = false,
    this.title,
  });

  String get formattedDate {
    return DateFormat('MMM d, y HH:mm').format(timestamp);
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
      'format': format,
      'title': title,
    };
  }

  factory CodeEntry.fromJson(Map<String, dynamic> json) {
    return CodeEntry(
      content: json['content'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      format: json['format'],
      isFavorite: json['isFavorite'] ?? false,
      title: json['title'],
    );
  }
}
