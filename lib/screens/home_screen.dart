import 'dart:collection';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import 'package:horda_test/widgets/error_column.dart';

import '../core/exceptions.dart';
import '../manager/url_manager.dart';
import '../widgets/horda_network_image.dart';

class HomeScreen extends StatelessWidget {
  final int maxAttempts;
  final UrlManager urlManager;
  final UnmodifiableListView<String> wordPairs;

  const HomeScreen(
      {super.key,
      required this.maxAttempts,
      required this.urlManager,
      required this.wordPairs});

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
            child: StreamBuilder<Either<HordaException, String>?>(
              initialData:
                  urlManager.state.cachedUrlList[urlManager.state.index],
              stream: urlManager.urlStream,
              builder:
                  (_, AsyncSnapshot<Either<HordaException, String>?> snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final Either<HordaException, String> solved = snapshot.data!;

                return switch (solved) {
                  Left() => ErrorColumn(error: solved.left),
                  Right() => HordaNetworkImage(url: solved.right),
                };
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          StreamBuilder<int>(
              initialData: urlManager.state.index,
              stream: urlManager.indexStream,
              builder: (_, AsyncSnapshot<int> snapshot) {
                return Text(wordPairs[snapshot.data!]);
              }),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<int>(
                  initialData: urlManager.state.index,
                  stream: urlManager.indexStream,
                  builder: (_, AsyncSnapshot<int> snapshot) {
                    final index = snapshot.data!;
                    return ElevatedButton(
                        onPressed: index == 0
                            ? null
                            : urlManager.getPrevImage,
                        child: const Text("Prev"));
                  }),
              const SizedBox(
                width: 25,
              ),
              StreamBuilder<int>(
                  initialData: urlManager.state.index,
                  stream: urlManager.indexStream,
                  builder: (_, AsyncSnapshot<int> snapshot) {
                    final int index = snapshot.data!;
                    return ElevatedButton(
                        onPressed: index == maxAttempts - 1
                            ? null
                            : () => urlManager.getNextImage(wordPairs[index+1]),
                        child: const Text("Next"));
                  }),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          StreamBuilder<int>(
              initialData: urlManager.state.attempts,
              stream: urlManager.attemptsStream,
              builder: (_, AsyncSnapshot<int> snapshot) {
                final int attempts = snapshot.data!;
                return Text("left: $attempts");
              })
        ]),
      ),
    );
  }
}
