import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'logger_output.dart';

class LogService {
  static final LogService instance = LogService._();
  LogService._();

  Logger? _logger;
  Directory? _logDir;

  Logger get log => _logger ?? _createDefaultLogger();

  Logger _createDefaultLogger() {
    return Logger(
      level: Level.all,
      output: ConsoleOutput(),
      printer: SimplePrinter(printTime: true),
    );
  }

  Future<Logger> initLogger() async {
    if (_logger != null) return _logger!;

    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        log.i('Android log directory: ${directory?.path}');
      }

      directory ??= await getApplicationDocumentsDirectory();

      final String logDirPath = '${directory.path}/logs';
      final logDir = Directory(logDirPath);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      _logDir = logDir;
      log.i('Log directory: ${logDir.path}');

      final outputs = <LogOutput>[
        LoggerOutput(logDir: logDir),
      ];

      // 仅在 debug 模式下添加控制台输出
      if (kDebugMode) {
        outputs.insert(0, ConsoleOutput());
      }

      _logger = Logger(
        level: Level.all,
        output: MultiOutput(outputs),
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: false,
          printEmojis: false,
          noBoxingByDefault: true,
        ),
      );

      await logDir.create(recursive: true);
      debugPrint('日志系统初始化成功: ${logDir.path}');

      return _logger!;
    } catch (e) {
      debugPrint('初始化日志系统失败: $e');
      _logger = _createDefaultLogger();
      return _logger!;
    }
  }

  Future<String> readLogFile() async {
    try {
      return '日志系统未初始化';
    } catch (e) {
      return '读取日志过程出错: $e';
    }
  }

  Future<List<File>> listAllLogFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${dir.path}/logs');
    if (!(await logDir.exists())) return [];

    final files = await logDir.list().where((e) => e is File && e.path.endsWith('.txt')).cast<File>().toList();

    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  // 清空所有日志文件内容，但保留文件
  Future<void> clearLogFile() async {
    if (_logDir == null) return;

    final files = _logDir!.listSync();
    for (var file in files) {
      if (file is File && file.path.endsWith('.log')) {
        if (await file.exists()) {
          final raf = await file.open(mode: FileMode.write);
          await raf.truncate(0); // 清空文件内容
          await raf.flush(); // 确保写入磁盘
          await raf.close();
        }
      }
    }
  }
}
