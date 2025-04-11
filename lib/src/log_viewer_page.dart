import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'flutter_log_viewer.dart';

class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  List<File> allLogFiles = [];
  File? currentFile;
  LogViewerLevel _level = LogViewerLevel.all;
  List<String> logLines = [];
  bool isLoading = false;

  Future<void> _loadLogFile([File? file]) async {
    setState(() {
      isLoading = true;
    });
    String content = '';
    if (file != null && await file.exists()) {
      content = await file.readAsString();
    } else {
      content = await LogService.instance.readLogFile();
    }

    setState(() {
      isLoading = false;
      currentFile = file;
      logLines = content.split('\n');
    });
  }

  @override
  void initState() {
    super.initState();
    _initLogFiles();
  }

  void _initLogFiles() async {
    setState(() {
      isLoading = true;
    });
    final dir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${dir.path}/logs');

    if (!await logDir.exists()) return;

    final files = await logDir.list().where((e) => e is File && e.path.endsWith('.log')).cast<File>().toList();

    files.sort((a, b) => b.path.compareTo(a.path));

    if (files.isEmpty) {
      setState(() {
        allLogFiles = [];
        currentFile = null;
        logLines = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      allLogFiles = files;
      final matched = files.firstWhere(
        (f) => _level == LogViewerLevel.all || f.path.contains(_level.name),
        orElse: () => files.first,
      );
      currentFile = matched;
      _loadLogFile(currentFile);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLines = logLines.where((line) => line.trim().isNotEmpty && _level.match(line)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('日志查看'),
        actions: [
          DropdownButton<LogViewerLevel>(
            value: _level,
            items: LogViewerLevel.values.map((level) {
              return DropdownMenuItem(value: level, child: Text(level.name));
            }).toList(),
            onChanged: (level) {
              if (level != null) {
                setState(() {
                  _level = level;
                });
                _initLogFiles();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                logLines = [];
                currentFile = null;
              });
              LogService.instance.clearLogFile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadLogFile(currentFile),
          ),
        ],
      ),
      body: filteredLines.isEmpty
          ? isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Text('No logs available'),
                )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredLines.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: SelectableText(
                    filteredLines[index],
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
