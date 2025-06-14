import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  late Logger _logger;
  static const int _maxLogSizeInBytes = 1 * 1024 * 1024; // 1 MB
  static const String _logFileName = 'app.log';

  LoggerService() {
    _initialize();
  }

  Future<void> _initialize() async {
    final fileOutput = RotatingFileOutput(
      maxLogSize: _maxLogSizeInBytes,
      logFileName: _logFileName,
    );

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: MultiOutput([
        if (kDebugMode) ConsoleOutput(),
        fileOutput,
      ]),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

class RotatingFileOutput extends LogOutput {
  final int maxLogSize;
  final String logFileName;
  File? _logFile;

  RotatingFileOutput({required this.maxLogSize, required this.logFileName});

  @override
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/$logFileName');
    if (await _logFile!.exists() && await _logFile!.length() > maxLogSize) {
      await _rotateLogs(directory.path);
    }
  }

  @override
  void output(OutputEvent event) async {
    _logFile?.writeAsStringSync('${event.lines.join('\n')}\n', mode: FileMode.append);
    if (await _logFile!.length() > maxLogSize) {
      final directory = await getApplicationDocumentsDirectory();
      await _rotateLogs(directory.path);
    }
  }

  Future<void> _rotateLogs(String path) async {
    final oldLog = File('$path/$logFileName');
    final backupLog = File('$path/$logFileName.1');
    if (await backupLog.exists()) {
      await backupLog.delete();
    }
    if (await oldLog.exists()) {
      await oldLog.rename(backupLog.path);
    }
    _logFile = File('$path/$logFileName');
  }
} 