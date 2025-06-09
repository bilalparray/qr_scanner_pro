// lib/widgets/barcode_fields_widget.dart
import 'package:flutter/material.dart';

class BarcodeFieldsWidget extends StatelessWidget {
  final String selectedFormat;
  final TextEditingController contentController;
  final void Function(String) onFormatChanged;

  const BarcodeFieldsWidget({
    Key? key,
    required this.selectedFormat,
    required this.contentController,
    required this.onFormatChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: selectedFormat,
          decoration: const InputDecoration(labelText: 'Barcode Format'),
          items: const [
            DropdownMenuItem(value: 'code128', child: Text('Code 128')),
            DropdownMenuItem(value: 'code39', child: Text('Code 39')),
            DropdownMenuItem(value: 'code93', child: Text('Code 93')),
            DropdownMenuItem(value: 'codabar', child: Text('Codabar')),
            DropdownMenuItem(value: 'dataMatrix', child: Text('Data Matrix')),
            DropdownMenuItem(value: 'ean13', child: Text('EAN-13')),
            DropdownMenuItem(value: 'ean8', child: Text('EAN-8')),
            DropdownMenuItem(value: 'itf', child: Text('ITF')),
            DropdownMenuItem(value: 'pdf417', child: Text('PDF417')),
            DropdownMenuItem(value: 'upca', child: Text('UPC-A')),
            DropdownMenuItem(value: 'upce', child: Text('UPC-E')),
          ],
          onChanged: (v) {
            if (v != null) onFormatChanged(v);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: contentController,
          decoration: const InputDecoration(labelText: 'Content'),
          validator: (v) => (v?.isEmpty ?? true) ? 'Enter content' : null,
        ),
      ],
    );
  }
}
