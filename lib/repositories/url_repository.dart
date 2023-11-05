import 'package:either_dart/either.dart';
import 'package:horda_test/core/exceptions.dart';
import 'package:horda_test/core/openai_client.dart';

class UrlRepository {
  final OpenaiClient _openaiClient;

  late final List<Either<HordaException, String>?> _cachedUrlList;
  late final List<Future<Either<HordaException, String>>?> _futureUrlList;

  UrlRepository(this._openaiClient, int urlNumber) {
    _cachedUrlList = List.filled(urlNumber, null, growable: false);
    _futureUrlList = List.filled(urlNumber, null, growable: false);
  }

  Future<Either<HordaException, String>>? getFutureUrl(int index) {
    return _futureUrlList[index];
  }

  /// Generate url and save it to future and cache(after some time) lists
  void generateImageUrl(int index, String prompt) {
    final Future<Either<HordaException, String>> futureUrl =
        _openaiClient.generateImageUrl(prompt);
    _futureUrlList[index] = futureUrl;
    futureUrl.then((Either<HordaException, String> url) {
      _cachedUrlList[index] = url;
    });
  }

  bool hasCachedUrl(int index) {
    return _cachedUrlList[index] != null;
  }

  Either<HordaException, String> requireCachedUrl(int index) {
    try {
      return Right(_cachedUrlList[index]!.right);
    } catch (e) {
      return Left(UrlRepoException("No cached url"));
    }
  }
}
