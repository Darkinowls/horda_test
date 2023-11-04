import 'package:dio/dio.dart';

class OpenaiClient {
  final String _token;
  final Dio _dio;

  OpenaiClient(this._dio, this._token) {
    _dio.options.baseUrl = "https://api.openai.com/v1";
    _dio.options.connectTimeout = const Duration(milliseconds: 5000);
    _dio.options.headers = {
      "Authorization": "Bearer $_token",
      "Content-Type": "application/json"
    };
  }

  Future<String> generateImageUrl(String prompt) async {
    final res = await _dio.post("/images/generations",
        data: {"prompt": prompt, "n": 1, "size": "256x256"});

    return res.data["data"][0]["url"];
  }
}
