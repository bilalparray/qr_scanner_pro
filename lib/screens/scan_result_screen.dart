// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_scanner/models/scan_result.dart';
import '../services/action_handler.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final ScanResultModel result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => ActionHandler.copyToClipboard(context, result.raw),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ActionHandler.share(context, result.raw),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => ActionHandler.saveToFile(context, result.raw),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Open'),
        icon: const Icon(Icons.open_in_new),
        onPressed: () => ActionHandler.handleTypeSpecific(context, result),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (result.type) {
      case ScanDataType.url:
        return SelectableText(result.raw, style: theme.textTheme.bodyLarge);
      case ScanDataType.text:
        return SelectableText(result.raw, style: theme.textTheme.bodyLarge);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parsed Data',
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            ...?result.parsed?.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${e.key}: ${e.value}'),
              ),
            ),
          ],
        );
    }
  }
}
