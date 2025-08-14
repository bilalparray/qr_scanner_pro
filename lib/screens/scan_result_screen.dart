import 'package:flutter/material.dart';
import 'package:qr_scanner/environment/environment.dart';
import 'package:qr_scanner/models/scan_result.dart';
import 'package:qr_scanner/services/banner_ad.dart';
import 'package:qr_scanner/widgets/action_button.dart';
import 'package:qr_scanner/widgets/drawer.dart';
import '../services/action_handler.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final ScanResultModel result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Scan Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header card ───────────────────────────────────────────────
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildHeader(theme),
                ),
              ),
              const SizedBox(height: 16),

              // ── Parsed / raw data display ────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: _buildBody(theme),
                ),
              ),
              const SizedBox(height: 16),
              IndependentBannerAdWidget(adUnitId: Environment.bannerAdUnitId),

              // ── Action buttons ───────────────────────────────────────────
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  ActionButton(
                    icon: Icons.open_in_new,
                    label: 'Open',
                    onTap: () =>
                        ActionHandler.handleTypeSpecific(context, result),
                  ),
                  ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () =>
                        ActionHandler.copyToClipboard(context, result.raw),
                  ),
                  ActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () => ActionHandler.share(context, result.raw),
                  ),
                  ActionButton(
                    icon: Icons.download,
                    label: 'Save',
                    onTap: () => ActionHandler.saveToFile(context, result.raw),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── header with badge + type ──────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    final typeLabel = result.type.name.toUpperCase();
    final icon = switch (result.type) {
      ScanDataType.url => Icons.link,
      ScanDataType.contact => Icons.person,
      ScanDataType.calendar => Icons.event,
      ScanDataType.phone => Icons.phone,
      ScanDataType.email => Icons.email,
      ScanDataType.sms => Icons.sms,
      ScanDataType.wifi => Icons.wifi,
      ScanDataType.text => Icons.text_snippet,
    };

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Text(
          typeLabel,
          style: theme.textTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── content section ───────────────────────────────────────────────────────
  Widget _buildBody(ThemeData theme) {
    if (result.type == ScanDataType.text || result.type == ScanDataType.url) {
      return SelectableText(
        result.raw,
        style: theme.textTheme.bodyLarge,
      );
    }

    // for parsed types
    final entries = (result.parsed ?? {}).entries.toList();
    if (entries.isEmpty) {
      return Text(
        'No additional data.',
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.key}: ',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SelectableText(
                      '${e.value}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
