import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import 'exceptions.dart';

class OpenaiClient {
  final String _token;
  final Dio _dio;

  OpenaiClient(this._dio, this._token) {
    _dio.options.baseUrl = "https://api.openai.com/v1";
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      "Authorization": "Bearer $_token",
      "Content-Type": "application/json"
    };
  }

  Future<Either<OpenaiException, String>> generateImageUrl(
      String prompt) async {
    try {
      final Response res = await _dio.post("/images/generations",
          data: {"prompt": prompt, "n": 1, "size": "256x256"});
      return Right(res.data["data"][0]["url"]);
    } on DioException catch (_) {
      return Left(OpenaiException("Time is out"));
    }
  }
}


