import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_scanner_pro/widgets/global_error.dart';

Future<void> downloadFileToDownloads(
  BuildContext context, {
  required String fileName,
  required Uint8List bytes,
}) async {
  try {
    final safeName = fileName.split(Platform.pathSeparator).last;

    // if (Platform.isAndroid) {
    //   if (await Permission.storage.isDenied ||
    //       await Permission.manageExternalStorage.isDenied) {
    //     final statuses = await [
    //       Permission.storage,
    //       Permission.manageExternalStorage,
    //     ].request();

    //     if (statuses[Permission.storage] != PermissionStatus.granted &&
    //         statuses[Permission.manageExternalStorage] !=
    //             PermissionStatus.granted) {
    //       throw Exception("Storage permission denied");
    //     }
    //   }
    // }

    // 3️⃣ Determine the target directory.
    late final Directory downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory("/storage/emulated/0/Download");
    } else if (Platform.isIOS) {
      downloadsDir = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError(
          "Unsupported platform: ${Platform.operatingSystem}");
    }

    // 4️⃣ Ensure it exists.
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // 5️⃣ Write the file.
    final filePath = "${downloadsDir.path}/$safeName";
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    GlobalErrorHandler.showSuccessSnackBar(
      context,
      "Saved: $filePath",
    );
  } catch (e) {
    // 7️⃣ Log and show error.
    GlobalErrorHandler.showErrorSnackBar(
      context,
      "Error saving file: ${e.toString()}",
    );
  }
}
