import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerOutput extends LogOutput {
  final Directory logDir;
  bool _hasLoggedError = false;

  LoggerOutput({
    required this.logDir,
  });

  File _fileForLevel(Level level) {
    final filename = '${level.name.toLowerCase()}.log';
    return File('${logDir.path}/$filename');
  }

  @override
  void output(OutputEvent event) {
    try {
      final levelLabel = '[${event.level.name.toUpperCase()}]';
      final log = '${DateTime.now()} $levelLabel: ${event.lines.join('\n')}\n';
      final file = _fileForLevel(event.level);
      file.writeAsStringSync(log, mode: FileMode.append);
      _hasLoggedError = false;
    } catch (e) {
      if (!_hasLoggedError && kDebugMode) {
        debugPrint('日志写入失败: $e');
      }
      _hasLoggedError = true;
    }
  }
}
