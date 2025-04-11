enum LogViewerLevel { all, debug, info, warn, error }

extension LogViewerLevelExt on LogViewerLevel {
  bool match(String line) {
    switch (this) {
      case LogViewerLevel.debug:
        return line.contains('[DEBUG]');
      case LogViewerLevel.info:
        return line.contains('[INFO]');
      case LogViewerLevel.warn:
        return line.contains('[WARNING]');
      case LogViewerLevel.error:
        return line.contains('[ERROR]');
      case LogViewerLevel.all:
        return true;
    }
  }

  String get name {
    switch (this) {
      case LogViewerLevel.debug:
        return 'debug';
      case LogViewerLevel.info:
        return 'info';
      case LogViewerLevel.warn:
        return 'warn';
      case LogViewerLevel.error:
        return 'error';
      case LogViewerLevel.all:
        return 'all';
    }
  }
}
