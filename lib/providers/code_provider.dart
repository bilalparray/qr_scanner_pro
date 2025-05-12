import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/code_entry.dart';

class CodeProvider extends ChangeNotifier {
  Box<CodeEntry>? _historyBox;
  Box<CodeEntry>? _favoritesBox;
  List<CodeEntry> _history = [];
  List<CodeEntry> _favorites = [];
  bool _isInitialized = false;

  CodeProvider() {
    _initBoxes();
  }

  bool get isInitialized => _isInitialized;

  Future<void> _initBoxes() async {
    try {
      _historyBox = Hive.box<CodeEntry>('history');
      _favoritesBox = Hive.box<CodeEntry>('favorites');
      _loadData();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing Hive boxes: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  void _loadData() {
    if (_historyBox != null && _favoritesBox != null) {
      _history = _historyBox!.values.toList();
      _favorites = _favoritesBox!.values.toList();
    }
  }

  List<CodeEntry> get history => _history;
  List<CodeEntry> get favorites => _favorites;

  Future<void> addEntry(CodeEntry entry) async {
    if (!_isInitialized || _historyBox == null) return;

    try {
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await _historyBox!.put(key, entry);
      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding entry: $e');
    }
  }

  Future<void> toggleFavorite(CodeEntry entry) async {
    if (!_isInitialized || _favoritesBox == null) return;

    try {
      if (entry.isFavorite) {
        await _favoritesBox!.delete(entry.key);
        entry.isFavorite = false;
      } else {
        final key = DateTime.now().millisecondsSinceEpoch.toString();
        await _favoritesBox!.put(key, entry);
        entry.isFavorite = true;
      }
      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> deleteEntry(CodeEntry entry) async {
    if (!_isInitialized || _historyBox == null || _favoritesBox == null) return;

    try {
      await _historyBox!.delete(entry.key);
      if (entry.isFavorite) {
        await _favoritesBox!.delete(entry.key);
      }
      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting entry: $e');
    }
  }

  Future<void> clearHistory() async {
    if (!_isInitialized || _historyBox == null || _favoritesBox == null) return;

    try {
      await _historyBox!.clear();
      await _favoritesBox!.clear();
      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
