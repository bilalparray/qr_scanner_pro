import 'package:flutter/material.dart';
import 'package:qr_scanner_pro/models/generate_code.dart';

class BarcodeTypeSelector extends StatelessWidget {
  final BarcodeCodeType selectedType;
  final ValueChanged<BarcodeCodeType> onTypeChanged;

  const BarcodeTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'Select Barcode Type',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ]),
          const SizedBox(height: 10),
          DropdownButtonFormField<BarcodeCodeType>(
            isExpanded: true,
            value: selectedType,
            decoration: InputDecoration(
              labelText: 'Barcode Type',
              prefixIcon: Icon(selectedType.category.icon),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            items: BarcodeCodeType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: type.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const TextSpan(text: ' • '),
                      TextSpan(
                        text: type.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (BarcodeCodeType? value) {
              if (value == null) return;
              onTypeChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
