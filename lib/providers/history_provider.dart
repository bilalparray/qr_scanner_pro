// history_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:qr_scanner_pro/models/generate_code.dart';
import 'package:qr_scanner_pro/models/history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryProvider with ChangeNotifier {
  static const _prefsKey = 'barcode_history';
  final List<HistoryItem> _history = [];
  List<HistoryItem> get history => List.unmodifiable(_history);

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      _history
        ..clear()
        ..addAll(
            decoded.map((m) => HistoryItem.fromMap(m as Map<String, dynamic>)));
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_history.map((h) => h.toMap()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  void addToHistory(
    String content, {
    required String snippet,
    required BarcodeCodeType codeType, // new param
    required bool isGenerated,
  }) {
    _history.insert(
      0,
      HistoryItem(
        content: content,
        snippet: snippet,
        codeType: codeType,
        timestamp: DateTime.now(),
        isGenerated: isGenerated,
      ),
    );
    notifyListeners();
    _saveHistory();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
    _saveHistory();
  }
}
