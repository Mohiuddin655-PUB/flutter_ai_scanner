import 'dart:convert';

import 'request.dart';
import 'response.dart';

typedef AiDataSource = Map<String, dynamic>;

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

  AiDataSource extractData(String? source) {
    source ??= "{}";
    int start = source.indexOf('{');
    int end = source.lastIndexOf('}') + 1;
    if (start == -1 || end == 0) return {};
    final raw = source.substring(start, end);
    try {
      final data = jsonDecode(raw);
      return data;
    } catch (_) {
      return {};
    }
  }

  T? buildData<T extends Object?>(
    String? source,
    AiResponseDataBuilder<T>? builder,
  ) {
    T? data;
    if (builder != null && source != null) {
      final raw = extractData(source);
      data = builder(raw);
    }
    return data;
  }

  AiMessage<T> buildMessage<T>(
    AiDataSource source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    return const AiMessage();
  }

  AiSafetyRating buildSafetyRating<T>(AiDataSource source) {
    return const AiSafetyRating();
  }

  AiChoice<T> buildChoice<T>(
    AiDataSource source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    return const AiChoice();
  }

  AiPromptTokensDetails buildPromptTokensDetails(AiDataSource source) {
    return const AiPromptTokensDetails();
  }

  AiCompletionTokensDetails buildCompletionTokensDetails(AiDataSource source) {
    return const AiCompletionTokensDetails();
  }

  AiTokenUsage buildTokenUsages(AiDataSource source) {
    return const AiTokenUsage();
  }

  AiCompletionResponse<T> buildResponse<T>(
    AiDataSource source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    return const AiCompletionResponse();
  }

  Future<AiCompletionResponse<T>> completions<T>(
    AiCompletionRequest<T> request,
  );

  @override
  String toString() => "$AiDelegate#$hashCode($provider)";
}
