import 'package:content/video_example_complex.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'hero.dart';
import 'video_example.dart';
import 'web_view_example.dart';
import 'package:flutter/services.dart';
import 'pdf_view_example.dart';
import 'youtube_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Content View Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SizedBox heightBox = const SizedBox(height: 50);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: const Text(
                'View Image',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HeroExample(),
                  ),
                );
              },
            ),
            heightBox,
            InkWell(
                child: const Text(
                  'View Video',
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoComplex(),
                    ),
                  );
                }),
            heightBox,
            InkWell(
                child: const Text(
                  'View URL',
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebViewExample(),
                    ),
                  );
                }),
            heightBox,
            InkWell(
                child: const Text(
                  'View PDF',
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PDFexample(),
                    ),
                  );
                }),
            heightBox,
            InkWell(
                child: const Text(
                  'View Youtube Video',
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Youtube(),
                    ),
                  );
                }),
          ],
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
