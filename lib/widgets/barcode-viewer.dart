import 'package:flutter/material.dart';

class BarcodeViewerPage extends StatelessWidget {
  final Widget barcode;
  final String title;
  final Color foregroundColor;
  final Color backgroundColor;

  const BarcodeViewerPage({
    super.key,
    required this.barcode,
    required this.title,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 10.0,
            child: Container(padding: const EdgeInsets.all(20), child: barcode),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        child: const Icon(Icons.close),
      ),
    );
  }
}
