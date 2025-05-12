import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/code_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<CodeProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Text('No favorites yet'),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final entry = favorites[index];
              return Dismissible(
                key: Key(entry.timestamp.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  provider.toggleFavorite(entry);
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
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      provider.toggleFavorite(entry);
                    },
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
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
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
