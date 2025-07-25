import 'package:share_plus/share_plus.dart';

Future<void> shareContent({
  required String text,
  String? subject,
  List<XFile>? files, // Use XFile from package:cross_file
}) async {
  final params = ShareParams(
    text: text,
    subject: subject,
    files: files,
  );

  await SharePlus.instance.share(params);
}
