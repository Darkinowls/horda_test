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
    final UrlState newState = state.copyWith(index: state.index + 1);
    _emit(newState);
    final Status status = newState.statusList[newState.index];

    if (status == Status.init) {
      _setStatusLoading(newState);
      final Either<OpenaiException, String> urlSolved =
          await _openaiClient.generateImageUrl(prompt);
      _setStatusResolved(newState, urlSolved);
    }
  }

  void _setStatusLoading(UrlState newState) {
    final List<Status> statusList = [...newState.statusList];
    statusList[newState.index] = Status.loading;
    _emit(newState.copyWith(
        statusList: statusList, attempts: newState.attempts - 1));
  }

  void _setStatusResolved(
      UrlState newState, Either<OpenaiException, String> urlSolved) {
    final List<Either<HordaException, String>?> cachedUrlList = [
      ...newState.cachedUrlList
    ];
    cachedUrlList[newState.index] = urlSolved;
    final List<Status> statusListAgain = [...newState.statusList];
    statusListAgain[newState.index] =
        urlSolved.isRight ? Status.loaded : Status.error;
    _emit(newState.copyWith(
        cachedUrlList: cachedUrlList, statusList: statusListAgain));
  }
}
