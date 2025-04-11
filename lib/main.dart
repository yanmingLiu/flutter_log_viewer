import 'package:flutter/material.dart';
import 'package:flutter_log_viewer/flutter_log_viewer.dart';
import 'package:logger/logger.dart';

late Logger log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log = await LogService.instance.initLogger();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Log Viewer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Log Viewer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: <Widget>[
            // add log.d button
            ElevatedButton(
              onPressed: () {
                log.d('This is a debug message');
              },
              child: const Text('Log Debug'),
            ),
            // add log.i button
            ElevatedButton(
              onPressed: () {
                log.i('This is an info message');
              },
              child: const Text('Log Info'),
            ),
            // add log.w button
            ElevatedButton(
              onPressed: () {
                log.w('This is a warning message');
              },
              child: const Text('Log Warning'),
            ),
            // add log.e button
            ElevatedButton(
              onPressed: () {
                log.e('This is an error message');
              },
              child: const Text('Log Error'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogViewerPage()),
          );
        },
        tooltip: 'Jump to Log Viewer',
        child: const Icon(Icons.reviews),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
