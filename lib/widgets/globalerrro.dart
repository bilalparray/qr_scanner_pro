// ==================== ERROR HANDLING CLASSES ====================

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlobalErrorHandler {
  static void handleFlutterError(FlutterErrorDetails details) {
    dev.log(
      'Flutter Error: ${details.exception}',
      name: 'GlobalErrorHandler',
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  static void handleError(Object error, StackTrace? stackTrace, String source) {
    dev.log(
      'Error from $source: $error',
      name: 'GlobalErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
