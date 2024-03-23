import 'dart:io';
import 'package:flutter/foundation.dart';

class FileUtils {
  /// Returns List<int> bytes from file
  /// Throws a [FileSystemException] if the operation fails.
  static Future<List<int>?> readBytesFromFile({
    File? file,
    String? filePath,
  }) async {
    if (file == null && filePath == null) return null;
    file ??= File(filePath ?? '');
    if (!await file.exists()) return null;
    List<int> bytes = [];
    bytes = await file.readAsBytes();
    return bytes;
  }

  static Future<void> deleteFilePath(String filePath) async {
    try {
      if (kDebugMode) {
        print('---Deleted file: $filePath');
      }
      await File(filePath).delete();
    } catch (_) {}
  }
}
