import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:horda_test/screens/home_screen.dart';
import 'core/consts.dart';
import 'core/openai_client.dart';

late final OpenaiClient _openaiClient;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: envPath);
  _openaiClient = OpenaiClient(Dio(), dotenv.env[openaiKey]!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app',
      home: HomeScreen(maxAttempts: maxAttempts, openaiClient: _openaiClient),
    );
  }
}
