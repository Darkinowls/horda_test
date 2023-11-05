import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:horda_test/core/openai_client.dart';

import '../core/exceptions.dart';

part 'url_state.dart';

class UrlManager {
  final OpenaiClient _openaiClient;
  late UrlState state;
  final StreamController<UrlState> _streamController =
      StreamController.broadcast();

  /// Emit new state to the stream.
  /// If state is the same, it does nothing
  void _emit(UrlState newState) {
    if (state == newState) {
      return;
    }
    _streamController.add(newState);
    state = newState;
  }

  UrlManager(this._openaiClient, int attempts, String firstPrompt) {
    state = UrlState(
        index: -1,
        attempts: attempts,
        cachedUrlList: List.filled(attempts, null, growable: false),
        statusList: List.filled(attempts, Status.init, growable: false));
    getNextImage(firstPrompt);
  }

  Stream<UrlState> get stream => _streamController.stream.asBroadcastStream();

  void getPrevImage() {
    _emit(state.copyWith(index: state.index - 1));
  }

  /// Get next image url.
  /// If status is init, it generates a new url via OpenAI Client
  Future<void> getNextImage(String prompt) async {
    _emit(state.copyWith(index: state.index + 1));
    final Status status = state.statusList[state.index];

    if (status == Status.init) {
      _setStatusLoading();
      final Either<OpenaiException, String> urlSolved =
          await _openaiClient.generateImageUrl(prompt);
      _setStatusResolved(urlSolved);
    }
  }

  void _setStatusLoading() {
    final List<Status> statusList = [...state.statusList];
    statusList[state.index] = Status.loading;
    _emit(state.copyWith(statusList: statusList, attempts: state.attempts - 1));
  }

  void _setStatusResolved(Either<OpenaiException, String> urlSolved) {
    final List<Either<HordaException, String>?> cachedUrlList = [
      ...state.cachedUrlList
    ];
    cachedUrlList[state.index] = urlSolved;
    final List<Status> statusListAgain = [...state.statusList];
    statusListAgain[state.index] =
        urlSolved.isRight ? Status.loaded : Status.error;
    _emit(state.copyWith(
        cachedUrlList: cachedUrlList, statusList: statusListAgain));
  }
}
