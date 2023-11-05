import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:horda_test/screens/home_screen.dart';
import 'core/consts.dart';
import 'core/openai_client.dart';
import 'manager/url_manager.dart';

late final UrlManager _urlManager;
late final UnmodifiableListView<String> _wordPairs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: envPath);
  final OpenaiClient openaiClient = OpenaiClient(Dio(), dotenv.env[openaiKey]!);
  _wordPairs = UnmodifiableListView(generateWordPairs()
      .take(maxAttempts)
      .map((WordPair e) => e.join(" "))
      .toList());
  _urlManager = UrlManager(openaiClient, maxAttempts, _wordPairs.first);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app',
      home: HomeScreen(
        maxAttempts: maxAttempts,
        urlManager: _urlManager,
        wordPairs: _wordPairs,
      ),
    );
  }
}
