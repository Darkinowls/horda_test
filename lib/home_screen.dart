import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:horda_test/openai_client.dart';

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
  late final List<Future<String>?> srcList;
  late final Iterable<String> wordPairs;

  @override
  void initState() {
    attempts = widget.maxAttempts;
    srcList = List.filled(widget.maxAttempts, null, growable: false);
    wordPairs = generateWordPairs()
        .map((WordPair e) => e.join(" "))
        .take(widget.maxAttempts);

    srcList[index] = generateUrl(wordPairs.elementAt(index));
    super.initState();
  }

  void getPrevImage() {
    index--;
    setState(() {});
  }

  Future<String> generateUrl(String prompt) async {
    final Future<String> futureUrl =
        widget.openaiClient.generateImageUrl(prompt);
    attempts--;
    return futureUrl;
  }

  Future<void> setNextImage(String prompt) async {
    index++;
    if (attempts != 0 && srcList[index] == null) {
      final Future<String> futureUrl = generateUrl(prompt);
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
          future: srcList.elementAt(index),
          builder: buildFuture,
        ),
        const SizedBox(
          height: 25,
        ),
        Text(wordPairs.elementAt(index)),
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
                onPressed: index == widget.maxAttempts - 1
                    ? null
                    : () => setNextImage(wordPairs.elementAt(index)),
                child: const Text("Next")),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Text("left: $attempts")
      ]),
    ));
  }

  Widget buildFuture(_, AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return Image.network(
        snapshot.data!,
        errorBuilder: buildErrorImage,
        loadingBuilder: buildLoadingImage,
      );
    }
    if (snapshot.hasError) {
      return _ErrorColumn(error: snapshot.error!);
    }
    return const CircularProgressIndicator();
  }

  Widget buildLoadingImage(_, Widget child, ImageChunkEvent? progress) {
    if (progress == null) return child;
    return CircularProgressIndicator(
      value: progress.expectedTotalBytes != null
          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
          : null,
    );
  }

  Widget buildErrorImage(_, Object error, __) {
    return _ErrorColumn(error: error);
  }
}

class _ErrorColumn extends StatelessWidget {
  final Object error;

  const _ErrorColumn({required this.error});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          const SizedBox(
            height: 25,
          ),
          Text("Error: ${error.toString()}", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
