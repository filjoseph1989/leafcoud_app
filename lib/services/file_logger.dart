import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileLogger {
  static Future<void> log(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/leafcloud_logs.txt');
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '$timestamp: $message\n';

      // Still print to console for immediate feedback
      debugPrint('Log file: ${file.path}');
      debugPrint(logEntry.trim());

      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }
}