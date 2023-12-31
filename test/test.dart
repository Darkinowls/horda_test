// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horda_test/core/consts.dart';
import 'package:horda_test/core/exceptions.dart';
import 'package:horda_test/core/openai_client.dart';
import 'package:horda_test/repositories/url_repository.dart';

void main() {
  test("test image url", () async {
    await dotenv.load(fileName: envPath);
    OpenaiClient dioClient = OpenaiClient(Dio(), dotenv.env[openaiKey]!);
    final Either<HordaException, String> url =
        await dioClient.generateImageUrl("Hello!");
    expect(url.isRight, true);
  });

  test("test url repo", () async {
    await dotenv.load(fileName: envPath);
    OpenaiClient dioClient = OpenaiClient(Dio(), dotenv.env[openaiKey]!);
    final UrlRepository urlRepository = UrlRepository(dioClient, maxAttempts);
    urlRepository.generateImageUrl(0, "Hello!");
    await Future.delayed(const Duration(seconds: 10));
    final Either<HordaException, String> url = urlRepository.requireCachedUrl(0);
    expect(url.isRight, true);
    print(url.right);
  });
}
