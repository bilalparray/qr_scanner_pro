// barcode_customization.dart

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BarcodeCustomization extends StatelessWidget {
  final Color foregroundColor;
  final Color backgroundColor;
  final double width;
  final double height;
  final bool showValue;
  final ValueChanged<Color> onForegroundColorChanged;
  final ValueChanged<Color> onBackgroundColorChanged;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<bool> onShowValueChanged;
  final bool isShowValueEnabled;

  const BarcodeCustomization({
    super.key,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.width,
    required this.height,
    required this.showValue,
    required this.onForegroundColorChanged,
    required this.onBackgroundColorChanged,
    required this.onWidthChanged,
    required this.onHeightChanged,
    required this.onShowValueChanged,
    required this.isShowValueEnabled,
  });

  Future<void> _pickColor(BuildContext context, Color current,
      ValueChanged<Color> onChanged) async {
    Color tempColor = current;
    Color? picked = await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: tempColor,
            onColorChanged: (color) => tempColor = color,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(tempColor),
              child: const Text('OK')),
        ],
      ),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.palette_outlined,
                    color: theme.colorScheme.tertiary),
              ),
              const SizedBox(width: 12),
              Text('Customization',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async => await _pickColor(
                        context, foregroundColor, onForegroundColorChanged),
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _colorPickerBox(context, 'Foreground', foregroundColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async => await _pickColor(
                        context, backgroundColor, onBackgroundColorChanged),
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _colorPickerBox(context, 'Background', backgroundColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Size Controls',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.width_normal, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Width: ${width.round()}px'),
                Expanded(
                  child: Slider(
                    value: width,
                    min: 200,
                    max: 400,
                    divisions: 20,
                    onChanged: onWidthChanged,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Icon(Icons.height, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Height: ${height.round()}px'),
                Expanded(
                  child: Slider(
                    value: height,
                    min: 100,
                    max: 250,
                    divisions: 15,
                    onChanged: onHeightChanged,
                  ),
                )
              ],
            ),
            if (isShowValueEnabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.text_fields, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Show Text Value',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Display text below the barcode',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Switch(value: showValue, onChanged: onShowValueChanged),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _colorPickerBox(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  label == 'Foreground' ? Icons.brush : Icons.format_color_fill,
                  size: 20,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.titleSmall),
              const Spacer(),
              Icon(Icons.touch_app, size: 16, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1))
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('Tap to change',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
