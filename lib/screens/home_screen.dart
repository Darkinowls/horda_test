import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:horda_test/widgets/error_column.dart';

import '../manager/url_manager.dart';
import '../widgets/image_placeholder.dart';

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
            child: StreamBuilder(
              initialData: urlManager.state,
              stream: urlManager.stream,
              builder: (_, AsyncSnapshot<UrlState> snapshot) {
                final UrlState urlState = snapshot.data!;
                final int index = urlState.index;
                final Status status = urlState.statusList[index];

                return switch (status) {
                  Status.init ||
                  Status.loading =>
                    const Center(child: CircularProgressIndicator()),
                  Status.loaded =>
                    ImagePlaceholder(result: urlState.cachedUrlList[index]!),
                  Status.error =>
                    ErrorColumn(error: urlState.cachedUrlList[index]!),
                };
              },
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          StreamBuilder(
              initialData: urlManager.state,
              stream: urlManager.stream,
              builder: (_, AsyncSnapshot<UrlState> snapshot) {
                return Text(wordPairs[snapshot.data!.index]);
              }),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                  initialData: urlManager.state,
                  stream: urlManager.stream,
                  builder: (_, AsyncSnapshot<UrlState> snapshot) {
                    return ElevatedButton(
                        onPressed: snapshot.data!.index == 0
                            ? null
                            : urlManager.getPrevImage,
                        child: const Text("Prev"));
                  }),
              const SizedBox(
                width: 25,
              ),
              StreamBuilder(
                  initialData: urlManager.state,
                  stream: urlManager.stream,
                  builder: (_, AsyncSnapshot<UrlState> snapshot) {
                    final index = snapshot.data!.index;
                    return ElevatedButton(
                        onPressed: index == maxAttempts - 1
                            ? null
                            : () => urlManager.getNextImage(wordPairs[index]),
                        child: const Text("Next"));
                  }),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          StreamBuilder(
              initialData: urlManager.state,
              stream: urlManager.stream,
              builder: (_, AsyncSnapshot<UrlState> snapshot) {
                return Text("left: ${snapshot.data!.attempts}");
              })
        ]),
      ),
    );
  }
}
