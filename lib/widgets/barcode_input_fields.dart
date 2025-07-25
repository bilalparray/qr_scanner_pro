import 'package:flutter/material.dart';
import 'package:qr_scanner/models/generate_code.dart';

class BarcodeInputFields extends StatelessWidget {
  final List<BarcodeInputField> inputFields;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChange;

  const BarcodeInputFields({
    super.key,
    required this.inputFields,
    required this.controllers,
    required this.onChange,
  });

  IconData _iconForField(String key) {
    switch (key) {
      case 'data':
        return Icons.text_fields;
      case 'ssid':
        return Icons.wifi;
      case 'password':
        return Icons.lock;
      case 'security':
        return Icons.security;
      case 'name':
        return Icons.person;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'organization':
        return Icons.business;
      default:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (inputFields.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This barcode type is not yet configured for input fields. Please select another type.',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit_outlined,
                    color: theme.colorScheme.secondary),
              ),
              const SizedBox(width: 12),
              Text('Configure Barcode Data',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 20),
            ...inputFields.map((field) {
              final controller = controllers[field.key];
              if (controller == null) return const SizedBox.shrink();

              if (field.dropdownOptions != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: field.label,
                      hintText: field.hint,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      prefixIcon: Icon(_iconForField(field.key)),
                    ),
                    items: field.dropdownOptions!
                        .map((opt) =>
                            DropdownMenuItem(value: opt, child: Text(opt)))
                        .toList(),
                    value: controller.text.isEmpty ? null : controller.text,
                    onChanged: (val) {
                      controller.text = val ?? '';
                      onChange();
                    },
                    validator: (val) {
                      if (field.isRequired && (val == null || val.isEmpty)) {
                        return '${field.label} is required';
                      }
                      if (field.pattern != null &&
                          val != null &&
                          val.isNotEmpty) {
                        final regex =
                            RegExp(field.pattern!, caseSensitive: false);
                        if (!regex.hasMatch(val)) {
                          return 'Invalid ${field.label} format';
                        }
                      }
                      if (field.maxLength != null &&
                          val != null &&
                          val.length != field.maxLength) {
                        return '${field.label} must be exactly ${field.maxLength} characters';
                      }
                      return null;
                    },
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: field.label,
                      hintText: field.hint,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      prefixIcon: Icon(_iconForField(field.key)),
                      suffixIcon: field.isRequired
                          ? Icon(Icons.star,
                              size: 12, color: Colors.red.shade400)
                          : null,
                    ),
                    keyboardType: field.keyboardType,
                    maxLength: field.maxLength,
                    validator: (val) {
                      if (field.isRequired &&
                          (val == null || val.trim().isEmpty)) {
                        return '${field.label} is required';
                      }
                      if (field.pattern != null &&
                          val != null &&
                          val.isNotEmpty) {
                        final regex =
                            RegExp(field.pattern!, caseSensitive: false);
                        if (!regex.hasMatch(val)) {
                          return 'Invalid ${field.label} format';
                        }
                      }
                      if (field.maxLength != null &&
                          val != null &&
                          val.length != field.maxLength) {
                        return '${field.label} must be exactly ${field.maxLength} characters';
                      }
                      return null;
                    },
                    onChanged: (_) => onChange(),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
