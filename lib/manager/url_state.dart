part of 'url_manager.dart';

enum Status { init, loading, loaded, error }

class UrlState {
  final List<Either<HordaException, String>?> cachedUrlList;

  final List<Status> statusList;

  final int index;

  final int attempts;

  const UrlState({
    required this.index,
    required this.attempts,
    this.cachedUrlList = const [],
    this.statusList = const [],
  });

  UrlState copyWith({
    List<Either<HordaException, String>?>? cachedUrlList,
    List<Status>? statusList,
    int? index,
    int? attempts,
  }) {
    return UrlState(
      cachedUrlList: cachedUrlList ?? this.cachedUrlList,
      statusList: statusList ?? this.statusList,
      index: index ?? this.index,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlState &&
          runtimeType == other.runtimeType &&
          cachedUrlList == other.cachedUrlList &&
          statusList == other.statusList &&
          index == other.index &&
          attempts == other.attempts;

  @override
  int get hashCode =>
      cachedUrlList.hashCode ^
      statusList.hashCode ^
      index.hashCode ^
      attempts.hashCode;
}
