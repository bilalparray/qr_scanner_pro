// lib/models/scan_result_model.dart
enum ScanDataType {
  url,
  contact,
  calendar,
  phone,
  email,
  sms,
  wifi,
  text,
}

class ScanResultModel {
  ScanResultModel({
    required this.raw,
    required this.type,
    this.parsed,
  });

  final String raw;
  final ScanDataType type;
  final Map<String, dynamic>? parsed;
}
