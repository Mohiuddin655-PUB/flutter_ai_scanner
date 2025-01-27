import 'dart:convert';

import 'request.dart';
import 'response.dart';

abstract class AiDelegate {
  /// API NAME
  final String provider;

  /// API KEY
  final String key;

  /// API ORGANIZATION
  final String? organization;

  const AiDelegate({
    required this.provider,

    /// API KEY
    required this.key,

    /// API ORGANIZATION
    this.organization,
  });

  Map<String, dynamic>? extractData(String? source) {
    source ??= "{}";
    int start = source.indexOf('{');
    int end = source.lastIndexOf('}') + 1;
    if (start == -1 || end == 0) return null;
    final raw = source.substring(start, end);
    try {
      final data = jsonDecode(raw);
      return data;
    } catch (_) {
      return null;
    }
  }

  T? buildData<T extends Object?>(
    String? source,
    AiResponseDataBuilder<T>? builder,
  ) {
    T? data;
    if (builder != null && source != null) {
      final raw = extractData(source);
      if (raw is Map<String, dynamic>) {
        data = builder(raw);
      }
    }
    return data;
  }

  AiMessage<T> buildMessage<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]);

  AiSafetyRating? buildSafetyRating<T>(Map<String, dynamic> source) {
    return null;
  }

  AiChoice<T> buildChoice<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]);

  AiPromptTokensDetails? buildPromptTokensDetails(Map<String, dynamic> source) {
    return null;
  }

  AiCompletionTokensDetails? buildCompletionTokensDetails(
    Map<String, dynamic> source,
  ) {
    return null;
  }

  AiTokenUsage buildTokenUsages(Map<String, dynamic> source);

  AiCompletionResponse<T> buildResponse<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]);

  Future<AiCompletionResponse<T>> completions<T>(
    AiCompletionRequest<T> request,
  );

  @override
  String toString() => "$AiDelegate#$hashCode($provider)";
}
