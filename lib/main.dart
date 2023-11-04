import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:horda_test/home_screen.dart';
import 'package:horda_test/openai_client.dart';

import 'consts.dart';

late final OpenaiClient dioClient;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: envPath);
  dioClient = OpenaiClient(Dio(), dotenv.env[openaiKey]!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app',
      home: HomeScreen(),
    );
  }
}
