import 'dart:collection';

import 'package:either_dart/either.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:horda_test/openai_client.dart';

import 'exceptions.dart';

class HomeScreen extends StatefulWidget {
  final int maxAttempts;
  final OpenaiClient openaiClient;

  const HomeScreen(
      {super.key, required this.maxAttempts, required this.openaiClient});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int attempts;
  int index = 0;
  late final List<Future<Either<HordaException, String>>?> srcList;
  late final UnmodifiableListView<String> wordPairs;

  @override
  void initState() {
    attempts = widget.maxAttempts;
    srcList = List.filled(widget.maxAttempts, null, growable: false);
    wordPairs = UnmodifiableListView(generateWordPairs()
        .map((WordPair e) => e.join(" "))
        .take(widget.maxAttempts)
        .toList(growable: false));

    srcList[index] = generateUrl(wordPairs[index]);
    super.initState();
  }

  void getPrevImage() {
    index--;
    setState(() {});
  }

  Future<Either<HordaException, String>> generateUrl(String prompt) {
    final Future<Either<HordaException, String>> futureUrl =
        widget.openaiClient.generateImageUrl(prompt);
    attempts--;
    return futureUrl;
  }

  void setNextImage() {
    index++;
    if (attempts != 0 && srcList[index] == null) {
      final String prompt = wordPairs[index];
      final Future<Either<HordaException, String>> futureUrl =
          generateUrl(prompt);
      srcList[index] = futureUrl;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FutureBuilder(
            future: srcList[index],
            builder: buildFuture,
          ),
          const SizedBox(
            height: 50,
          ),
          Text(wordPairs[index]),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: index == 0 ? null : getPrevImage,
                  child: const Text("Prev")),
              const SizedBox(
                width: 25,
              ),
              ElevatedButton(
                  onPressed:
                      index == widget.maxAttempts - 1 ? null : setNextImage,
                  child: const Text("Next")),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Text("left: $attempts")
        ]),
      ),
    );
  }

  Widget buildFuture(
      _, AsyncSnapshot<Either<HordaException, String>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const CircularProgressIndicator();
    }
    final Either<HordaException, String> result = snapshot.data!;
    return switch (result) {
      Left() => _ErrorColumn(error: result.value),
      Right() => Image.network(
          result.value,
          loadingBuilder: buildLoadingImage,
          errorBuilder: (_, __, ___) =>
              const _ErrorColumn(error: "Failed to load image"),
        )
    };
  }

  Widget buildLoadingImage(_, Widget child, ImageChunkEvent? progress) {
    if (progress == null) return child;
    return CircularProgressIndicator(
      value: progress.expectedTotalBytes != null
          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
          : null,
    );
  }
}

class _ErrorColumn extends StatelessWidget {
  final Object error;

  const _ErrorColumn({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          const SizedBox(
            height: 25,
          ),
          Text(error.toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
