import 'dart:convert';

import 'package:http/http.dart' as http;

import 'delegate.dart';
import 'request.dart';
import 'response.dart';

class GptAiDelegate extends AiDelegate {
  const GptAiDelegate({
    required super.key,
    super.organization,
  }) : super(provider: "gpt");

  @override
  AiMessage<T> buildMessage<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    final role = source["role"];
    final content = source["content"];
    final refusal = source["refusal"];
    final data = content is String ? buildData(content, builder) : null;
    return AiMessage<T>(
      role: role is String ? role : null,
      content: content is String ? content : null,
      refusal: refusal is String ? refusal : null,
      data: data,
    );
  }

  @override
  AiChoice<T> buildChoice<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    final index = source["index"];
    final message = source["message"];
    final logprobs = source["logprobs"];
    final finishReason = source["finish_reason"];
    return AiChoice<T>(
      index: index is int ? index : null,
      message: message is Map<String, dynamic>
          ? buildMessage(message, builder)
          : null,
      logprobs: logprobs is bool ? logprobs : null,
      finishReason: finishReason is String ? finishReason : null,
    );
  }

  @override
  AiPromptTokensDetails? buildPromptTokensDetails(Map<String, dynamic> source) {
    final audioTokens = source["audio_tokens"];
    final cachedTokens = source["cached_tokens"];
    return AiPromptTokensDetails(
      audioTokens: audioTokens is int ? audioTokens : null,
      cachedTokens: cachedTokens is int ? cachedTokens : null,
    );
  }

  @override
  AiCompletionTokensDetails? buildCompletionTokensDetails(
    Map<String, dynamic> source,
  ) {
    final acceptedPredictionTokens = source["accepted_prediction_tokens"];
    final audioTokens = source["audio_tokens"];
    final reasoningTokens = source["reasoning_tokens"];
    final rejectedPredictionTokens = source["rejected_prediction_tokens"];
    return AiCompletionTokensDetails(
      acceptedPredictionTokens:
          acceptedPredictionTokens is int ? acceptedPredictionTokens : null,
      audioTokens: audioTokens is int ? audioTokens : null,
      reasoningTokens: reasoningTokens is int ? reasoningTokens : null,
      rejectedPredictionTokens:
          rejectedPredictionTokens is int ? rejectedPredictionTokens : null,
    );
  }

  @override
  AiTokenUsage buildTokenUsages(Map<String, dynamic> source) {
    final promptTokens = source["prompt_tokens"];
    final completionTokens = source["completion_tokens"];
    final totalTokens = source["total_tokens"];
    final promptTokensDetails = source["prompt_tokens_details"];
    final completionTokensDetails = source["completion_tokens_details"];
    return AiTokenUsage(
      promptTokens: promptTokens is int ? promptTokens : null,
      completionTokens: completionTokens is int ? completionTokens : null,
      totalTokens: totalTokens is int ? totalTokens : null,
      promptTokensDetails: promptTokensDetails is Map<String, dynamic>
          ? buildPromptTokensDetails(promptTokensDetails)
          : null,
      completionTokensDetails: completionTokensDetails is Map<String, dynamic>
          ? buildCompletionTokensDetails(completionTokensDetails)
          : null,
    );
  }

  @override
  AiCompletionResponse<T> buildResponse<T>(
    Map<String, dynamic> source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    final id = source["id"];
    final object = source["object"];
    final created = source["created"];
    final model = source["model"];
    final choices = source["choices"];
    final usage = source["usage"];
    final systemFingerprint = source["system_fingerprint"];
    final serviceTier = source["service_tier"];
    return AiCompletionResponse<T>(
      id: id is String ? id : null,
      object: object is String ? object : null,
      created: created is int ? created : null,
      model: model is String ? model : null,
      choices: choices is List
          ? choices.whereType<Map<String, dynamic>>().map((e) {
              return buildChoice(e, builder);
            }).toList()
          : null,
      usage: usage is Map<String, dynamic> ? buildTokenUsages(usage) : null,
      serviceTier: serviceTier is String ? serviceTier : null,
      systemFingerprint: systemFingerprint is String ? systemFingerprint : null,
      statusCode: 200,
    );
  }

  @override
  Future<AiCompletionResponse<T>> completions<T>(
    AiCompletionRequest<T> request,
  ) {
    final data = request.data;
    final model = request.model ?? 'gpt-4';
    final prompt = request.prompt;
    final system = request.system ?? '';
    final maxTokens = request.maxTokens ?? 0;
    final n = request.n ?? 0;
    final temperature = request.temperature ?? 0.7;
    final urlBased = data is String && data.isNotEmpty;

    return http
        .post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $key",
          },
          body: jsonEncode({
            "model": model,
            "messages": [
              if (system.isNotEmpty)
                {
                  "role": "system",
                  "content": system,
                },
              {
                "role": "user",
                "content": !urlBased
                    ? prompt
                    : [
                        {
                          "type": "text",
                          "text": prompt,
                        },
                        {
                          "type": "image_url",
                          "image_url": {"url": data},
                        }
                      ]
              }
            ],
            "temperature": temperature,
            if (maxTokens > 0) "max_tokens": maxTokens,
            if (n > 0) "n": n,
          }),
        )
        .onError((error, __) => http.Response("$error", 500))
        .then((value) {
      if (value.statusCode == 200) {
        final raw = jsonDecode(value.body);
        if (raw is Map<String, dynamic>) {
          return buildResponse(raw, request.builder);
        }
      }
      return AiCompletionResponse.failure(
        value.reasonPhrase ?? value.body,
        value.statusCode,
      );
    });
  }
}
