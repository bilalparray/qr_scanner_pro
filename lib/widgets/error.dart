import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  final bool isDevelopment;

  const CustomErrorWidget({
    super.key,
    required this.details,
    required this.isDevelopment,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: isDevelopment ? Colors.red.shade50 : Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDevelopment
                        ? Colors.red.shade100
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDevelopment ? Colors.red : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isDevelopment ? 'Development Error' : 'Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDevelopment
                        ? Colors.red.shade700
                        : Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (isDevelopment) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      details.exception.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'We apologize for the inconvenience. Please restart the app.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
