import 'dart:convert';

import 'package:http/http.dart' as http;

import 'delegate.dart';
import 'request.dart';
import 'response.dart';

class GeminiAiDelegate extends AiDelegate {
  const GeminiAiDelegate({
    required super.key,
    super.organization,
  }) : super(provider: "gemini");

  @override
  AiMessage<T> buildMessage<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    final role = source["role"];
    final parts = source["parts"];
    dynamic content = parts is List ? parts.firstOrNull : null;
    if (content is Map) {
      content = content["text"];
    }
    return AiMessage<T>(
      role: role is String ? role : null,
      content: content is String ? content : null,
      data: content is String ? buildData(content, builder) : null,
    );
  }

  @override
  AiSafetyRating buildSafetyRating<T>(Map<String, dynamic> source) {
    final category = source["category"];
    final probability = source["probability"];
    return AiSafetyRating(
      category: category is String ? category : null,
      probability: probability is String ? probability : null,
    );
  }

  @override
  AiChoice<T> buildChoice<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    final index = source["index"];
    final message = source["content"];
    final finishReason = source["finishReason"];
    final safetyRatings = source["safetyRatings"];
    return AiChoice<T>(
      index: index is int ? index : null,
      message: message is Map<String, dynamic>
          ? buildMessage(message, builder)
          : null,
      finishReason: finishReason is String ? finishReason : null,
      safetyRatings: safetyRatings is List
          ? safetyRatings.map((e) {
              return buildSafetyRating(e);
            }).toList()
          : null,
    );
  }

  @override
  AiTokenUsage buildTokenUsages(Map<String, dynamic> source) {
    final promptTokens = source["promptTokenCount"];
    final completionTokens = source["candidatesTokenCount"];
    final totalTokens = source["totalTokenCount"];
    return AiTokenUsage(
      promptTokens: promptTokens is int ? promptTokens : null,
      completionTokens: completionTokens is int ? completionTokens : null,
      totalTokens: totalTokens is int ? totalTokens : null,
    );
  }

  @override
  AiCompletionResponse<T> buildResponse<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    final model = source["modelVersion"];
    final choices = source["candidates"];
    final usage = source["usageMetadata"];
    return AiCompletionResponse<T>(
      model: model is String ? model : null,
      choices: choices is List
          ? choices.whereType<Map<String, dynamic>>().map((e) {
              return buildChoice(e, builder);
            }).toList()
          : null,
      usage: usage is Map<String, dynamic> ? buildTokenUsages(usage) : null,
      statusCode: 200,
    );
  }

  @override
  Future<AiCompletionResponse<T>> completions<T>(
      AiCompletionRequest<T> request) {
    final data = request.data;
    final model = request.model ?? "gemini-pro";
    final prompt = request.prompt;
    final system = request.system ?? '';
    final maxTokens = request.maxTokens;
    final n = request.n;
    final temperature = request.temperature ?? 0.7;
    final isScanMode = data != null && data is String;
    return http
        .post(
          Uri.parse(
              "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent"),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': key,
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  if (isScanMode)
                    {
                      'inlineData': {
                        'mimeType': 'image/jpeg',
                        'data': data,
                      }
                    }
                ]
              }
            ],
            'generationConfig': {
              'temperature': temperature,
              if (maxTokens != null) 'maxOutputTokens': maxTokens,
              if (n != null) 'n': n,
            },
          }),
        )
        .onError((_, __) => http.Response("$_", 500))
        .then((value) {
      if (value.statusCode == 200) {
        final raw = jsonDecode(value.body);
        if (raw is Map<String, dynamic>) {
          return buildResponse(raw);
        }
      }
      return AiCompletionResponse.failure(
        value.reasonPhrase ?? value.body,
        value.statusCode,
      );
    });
  }
}
