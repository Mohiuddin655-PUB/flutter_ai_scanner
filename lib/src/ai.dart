import 'dart:convert';

import 'package:http/http.dart' as http;

import 'request.dart';
import 'response.dart';

class AiScanner {
  final String key;
  final String? organization;

  const AiScanner({
    required this.key,
    this.organization,
  });

  static AiScanner? _i;

  static AiScanner get i {
    if (_i != null) {
      return _i!;
    } else {
      throw UnimplementedError("Ai not initialized yet!");
    }
  }

  static void init({
    required String key,
    String? organization,
  }) {
    _i = AiScanner(key: key, organization: organization);
  }

  Future<AiResponse<T>> execute<T>(AiRequest<T> request) {
    return http
        .post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $key",
          },
          body: request.body,
        )
        .onError((_, __) => http.Response("$_", 500))
        .then((value) {
      if (value.statusCode == 200) {
        final raw = jsonDecode(value.body);
        if (raw is Map<String, dynamic>) {
          return AiResponse.from(raw, request.builder);
        }
      }
      return AiResponse.failure(
        value.reasonPhrase ?? value.body,
        value.statusCode,
      );
    });
  }
}
