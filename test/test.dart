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
import 'package:horda_test/consts.dart';
import 'package:horda_test/exceptions.dart';
import 'package:horda_test/openai_client.dart';

const imageUrl =
    "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Qu7e7ExMjie0LsRvV3LHeKzJ/user-xoX76QNVBxpbqT5ZrIY676XA/img-p9DUaFRkULZLxwH6p486ZkH1.png?st=2023-11-03T18%3A37%3A26Z&se=2023-11-03T20%3A37%3A26Z&sp=r&sv=2021-08-06&sr=b&rscd=inline&rsct=image/png&skoid=6aaadede-4fb3-4698-a8f6-684d7786b067&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2023-11-03T19%3A33%3A39Z&ske=2023-11-04T19%3A33%3A39Z&sks=b&skv=2021-08-06&sig=mdoMsu8JAYhvTQ1nT31Gf55dJUd16/opr/h8lXPdhcE%3D";

void main() {
  test("test image url", () async {
    await dotenv.load(fileName: envPath);
    OpenaiClient dioClient = OpenaiClient(Dio(), dotenv.env[openaiKey]!);
    final Either<HordaException, String> url = await dioClient.generateImageUrl("Hello!");
    expect(url.isRight, true);
  });
}
