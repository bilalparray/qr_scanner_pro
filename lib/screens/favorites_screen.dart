import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/code_provider.dart';
import '../models/code_entry.dart';

class FavoritesScreen extends StatefulWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Local snapshot of favorites, taken once when the screen opens:
  late List<CodeEntry> _localFavorites;

  @override
  void initState() {
    super.initState();
    // Grab a fresh copy of provider.favorites
    final provider = Provider.of<CodeProvider>(context, listen: false);
    _localFavorites = List<CodeEntry>.from(provider.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _localFavorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: _localFavorites.length,
              itemBuilder: (context, index) {
                final entry = _localFavorites[index];
                return Dismissible(
                  key: Key(entry.key as String),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // 1) Immediately unfavorite in provider
                    Provider.of<CodeProvider>(context, listen: false)
                        .toggleFavorite(entry);
                    // 2) Remove from local list so it disappears
                    setState(() {
                      _localFavorites.removeAt(index);
                    });
                  },
                  child: ListTile(
                    leading: Icon(
                      entry.type == 'qr' ? Icons.qr_code : Icons.qr_code_2,
                      size: 32,
                    ),
                    title: Text(
                      entry.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${entry.type.toUpperCase()} • ${entry.formattedDate}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // 1) Immediately unfavorite in provider (removes clone)
                        Provider.of<CodeProvider>(context, listen: false)
                            .toggleFavorite(entry);
                        // 2) Also remove from local list so tile vanishes
                        setState(() {
                          _localFavorites.removeAt(index);
                        });
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(entry.type.toUpperCase()),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Content: ${entry.content}'),
                              const SizedBox(height: 8),
                              Text('Date: ${entry.formattedDate}'),
                              if (entry.format != null) ...[
                                const SizedBox(height: 8),
                                Text('Format: ${entry.format}'),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
