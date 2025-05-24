import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/code_provider.dart';
import '../widgets/code_bottom_sheet.dart'; // Your custom bottom sheet widget

class HistoryScreen extends StatelessWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear History'),
                  content:
                      const Text('Are you sure you want to clear all history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CodeProvider>().clearHistory();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CodeProvider>(
        builder: (ctx, provider, child) {
          final history = provider.history;

          if (history.isEmpty) {
            return const Center(
              child: Text('No history yet'),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (ctx2, index) {
              final entry = history[index];
              return Dismissible(
                key: ValueKey(entry.key),
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
                  provider.deleteEntry(entry);
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
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: entry.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      provider.toggleFavorite(entry);
                    },
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: ctx2,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      isScrollControlled: true,
                      builder: (_) => ResultSheet(
                        result: entry.content,
                        type: entry.type,
                        format: entry.format ?? '',
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
