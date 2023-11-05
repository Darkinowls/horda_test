import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:horda_test/core/openai_client.dart';

import '../core/exceptions.dart';

part 'url_state.dart';

class UrlManager {
  final OpenaiClient _openaiClient;
  late UrlState state;
  final StreamController<int> _indexController = StreamController.broadcast();

  final StreamController<int> _attemptsController =
      StreamController.broadcast();

  final StreamController<Either<HordaException, String>?> _urlController =
      StreamController.broadcast();

  UrlManager(this._openaiClient, int attempts, String firstPrompt) {
    state = UrlState(
        index: 0,
        attempts: attempts,
        cachedUrlList: List.filled(attempts, null, growable: false),
        isOpenedList: List.filled(attempts, false, growable: false));
    _generateImageUrl(0, firstPrompt);
  }

  Stream<int> get indexStream => _indexController.stream.asBroadcastStream();

  Stream<int> get attemptsStream =>
      _attemptsController.stream.asBroadcastStream();

  Stream<Either<HordaException, String>?> get urlStream =>
      _urlController.stream.asBroadcastStream();

  void getPrevImage() {
    final newIndex = state.index - 1;
    _emitIndex(newIndex);
    _emitUrlChange(state.cachedUrlList[newIndex]);
  }

  /// Get next image url.
  /// If it is not opened before, it generates a new url via OpenAI Client
  Future<void> getNextImage(String prompt) async {
    final newIndex = state.index + 1;
    _emitIndex(newIndex);
    _emitUrlChange(state.cachedUrlList[newIndex]);
    final bool isOpened = state.isOpenedList[newIndex];

    if (isOpened == true) {
      return;
    }
    _generateImageUrl(newIndex, prompt);
  }

  /// Generates a new url via OpenAI Client.
  /// It sets the solved value to the list under the index
  _generateImageUrl(int index, String prompt) async {

    _setIsOpened(index);
    final Either<OpenaiException, String> urlSolved =
        await _openaiClient.generateImageUrl(prompt);
    _setSolved(index, urlSolved);
  }

  void _emitIndex(int index) {
    state = state.copyWith(index: index);
    _indexController.add(index);
  }

  void _emitUrlChange(Either<HordaException, String>? url) {
    _urlController.add(url);
  }

  void _emitAttempts(int attempts) {
    state = state.copyWith(attempts: attempts);
    _attemptsController.add(attempts);
  }

  void _setIsOpened(int index) {
    state.isOpenedList[index] = true;
    _emitAttempts(state.attempts - 1);
  }

  void _setSolved(int index, Either<OpenaiException, String> urlSolved) {
    state.cachedUrlList[index] = urlSolved;
    if (state.index == index) {
      _emitUrlChange(urlSolved);
    }
  }
}
