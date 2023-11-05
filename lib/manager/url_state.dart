part of 'url_manager.dart';

enum Status { init, loading, loaded, error }

class UrlState {
  final List<Either<HordaException, String>?> cachedUrlList;

  final List<bool> isOpenedList;

  final int index;

  final int attempts;

  const UrlState({
    required this.index,
    required this.attempts,
    this.cachedUrlList = const [],
    this.isOpenedList = const [],
  });

  UrlState copyWith({
    List<Either<HordaException, String>?>? cachedUrlList,
    List<bool>? isOpenedList,
    int? index,
    int? attempts,
  }) {
    return UrlState(
      cachedUrlList: cachedUrlList ?? this.cachedUrlList,
      isOpenedList: isOpenedList ?? this.isOpenedList,
      index: index ?? this.index,
      attempts: attempts ?? this.attempts,
    );
  }
}
