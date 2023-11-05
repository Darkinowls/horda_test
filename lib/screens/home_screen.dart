import 'dart:collection';

import 'package:either_dart/either.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

import '../core/exceptions.dart';
import '../repositories/url_repository.dart';
import '../widgets/image_placeholder.dart';

class HomeScreen extends StatefulWidget {
  final int maxAttempts;

  final UrlRepository urlRepository;

  const HomeScreen(
      {super.key, required this.maxAttempts, required this.urlRepository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int attempts;
  int index = 0;
  late final UnmodifiableListView<String> wordPairs;

  @override
  void initState() {
    attempts = widget.maxAttempts;
    wordPairs = UnmodifiableListView(generateWordPairs()
        .map((WordPair e) => e.join(" "))
        .take(widget.maxAttempts)
        .toList(growable: false));
    widget.urlRepository.generateImageUrl(index, wordPairs[index]);
    attempts--;
    super.initState();
  }

  void getPrevImage() {
    index--;
    setState(() {});
  }

  /// If there is no future url, generate it and decrease attempts
  void setNextImage() {
    index++;
    if (attempts != 0 && widget.urlRepository.getFutureUrl(index) == null) {
      widget.urlRepository.generateImageUrl(index, wordPairs[index]);
      attempts--;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 256,
            width: 256,
            padding: const EdgeInsets.all(25),
            color: Colors.grey[300],
            child: widget.urlRepository.hasCachedUrl(index)
                ? ImagePlaceholder(
                    result: widget.urlRepository.requireCachedUrl(index))
                : FutureBuilder(
                    future: widget.urlRepository.getFutureUrl(index),
                    builder: buildFuture,
                  ),
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
      return const Center(child: CircularProgressIndicator());
    }
    final Either<HordaException, String> result = snapshot.data!;
    return ImagePlaceholder(result: result);
  }
}
