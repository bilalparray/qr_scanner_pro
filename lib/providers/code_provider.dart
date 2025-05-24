import 'package:flutter/foundation.dart';
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
  List<CodeEntry> get history => _history;
  List<CodeEntry> get favorites => _favorites;

  Future<void> _initBoxes() async {
    try {
      // These boxes must have been opened in main():
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
    if (_historyBox == null || _favoritesBox == null) return;
    _history = _historyBox!.values.toList();
    _favorites = _favoritesBox!.values.toList();
  }

  /// Add a new entry to history (isFavorite = false by default).
  Future<void> addEntry(CodeEntry entry) async {
    if (!_isInitialized || _historyBox == null) return;

    try {
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await _historyBox!.put(key, entry);
      // Now entry.key == key:
      entry.isFavorite = false;
      await entry.save(); // Persist isFavorite = false into history box

      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding entry: $e');
    }
  }

  /// Toggle “favorite” by cloning/removing from the favoritesBox.
  Future<void> toggleFavorite(CodeEntry entry) async {
    if (!_isInitialized || _historyBox == null || _favoritesBox == null) return;

    try {
      if (entry.isFavorite) {
        // Was already a favorite → find its clone in favoritesBox by matching timestamp & content:
        MapEntry<dynamic, CodeEntry>? toDelete;
        for (var kv in _favoritesBox!.toMap().entries) {
          final CodeEntry ce = kv.value;
          if (ce.timestamp == entry.timestamp && ce.content == entry.content) {
            toDelete = kv;
            break;
          }
        }
        if (toDelete != null) {
          await _favoritesBox!.delete(toDelete.key);
        }

        // Flip original’s flag, save back into history
        entry.isFavorite = false;
        await entry.save();
      } else {
        // Was not a favorite → clone this entry into favoritesBox:
        final clone = CodeEntry(
          content: entry.content,
          type: entry.type,
          timestamp: entry.timestamp,
          format: entry.format,
          isFavorite: true,
          title: entry.title,
        );
        final favKey = DateTime.now().millisecondsSinceEpoch.toString();
        await _favoritesBox!.put(favKey, clone);

        // Flip original’s flag, save back into history
        entry.isFavorite = true;
        await entry.save();
      }

      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  /// Delete a history entry (and its clone in favoritesBox if it was favorited).
  Future<void> deleteEntry(CodeEntry entry) async {
    if (!_isInitialized || _historyBox == null || _favoritesBox == null) return;

    try {
      final histKey = entry.key as String;
      await _historyBox!.delete(histKey);

      if (entry.isFavorite) {
        // Find and delete its clone in favoritesBox as well
        MapEntry<dynamic, CodeEntry>? toDelete;
        for (var kv in _favoritesBox!.toMap().entries) {
          final CodeEntry ce = kv.value;
          if (ce.timestamp == entry.timestamp && ce.content == entry.content) {
            toDelete = kv;
            break;
          }
        }
        if (toDelete != null) {
          await _favoritesBox!.delete(toDelete.key);
        }
      }

      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting entry: $e');
    }
  }

  /// Clear only history. Favorites remain intact.
  Future<void> clearHistory() async {
    if (!_isInitialized || _historyBox == null) return;

    try {
      await _historyBox!.clear();
      _loadData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
