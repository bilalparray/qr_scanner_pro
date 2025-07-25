import 'package:flutter/material.dart';

class EnhancedColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const EnhancedColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  static const List<List<Color>> _colorGroups = [
    // Basic colors
    [Colors.black, Colors.white, Colors.grey, Colors.red, Colors.pink],
    [
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
    ],
    [Colors.cyan, Colors.teal, Colors.green, Colors.lightGreen, Colors.lime],
    [
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current color display
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: pickerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Selected Color',
                style: TextStyle(
                  color: pickerColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Color grid
          ..._colorGroups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: group.map((color) {
                  final isSelected = pickerColor == color;
                  return GestureDetector(
                    onTap: () => onColorChanged(color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade400,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
