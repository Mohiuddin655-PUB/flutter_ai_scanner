import 'dart:convert';

import 'package:flutter_ai_scanner/flutter_ai_scanner.dart';

import 'response.dart';

typedef AiRequestSample = Map<String, dynamic>;

String _kScanPrompt(
  String type,
  String preconditions,
  AiRequestSample sample,
) {
  return "Scan the $type and give me $preconditions. Like $sample without unnecessary content. Give me only full json data.";
}

String _kSuggestPrompt(
  String type,
  String preconditions,
  AiRequestSample sample,
) {
  return "Suggest $type depending on the user's conditions ($preconditions). Like $sample without unnecessary content. Give me only full json data.";
}

class AiRequest<T extends Object?> {
  final String prompt;
  final String? url;
  final String? model;
  final int? maxTokens;
  final int? n;
  final AiResponseDataBuilder<T>? builder;

  const AiRequest({
    required this.prompt,
    this.url,
    this.model,
    this.maxTokens,
    this.n,
    this.builder,
  });

  AiRequest.scan({
    required String this.url,
    required AiRequestSample sample,
    String category = "photo",
    String preconditions = "information",
    this.model,
    this.maxTokens,
    this.n,
    this.builder,
  }) : prompt = _kScanPrompt(category, preconditions, sample);

  AiRequest.suggest({
    required AiRequestSample sample,
    required String category,
    required String preconditions,
    this.url,
    this.model,
    this.maxTokens,
    this.n,
    this.builder,
  }) : prompt = _kSuggestPrompt(category, preconditions, sample);

  Map<String, dynamic> get data {
    final isScanMode = url != null && url!.isNotEmpty;
    return {
      "model": model ?? "gpt-4-turbo",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": prompt,
            },
            if (isScanMode)
              {
                "type": "image_url",
                "image_url": {"url": url},
              }
          ]
        }
      ],
      "n": n,
      "max_tokens": maxTokens,
    };
  }

  String get body => jsonEncode(data);
}

class AiFoodRequest<T extends Object> {}
