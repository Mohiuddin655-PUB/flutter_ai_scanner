import 'dart:convert';

typedef AiResponseDataBuilder<T extends Object?> = T Function(
  Map<String, dynamic> source,
);

class AiCompletionResponse<T extends Object?> {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<AiChoice<T>>? choices;
  final AiTokenUsage? usage;
  final String? systemFingerprint;
  final String? serviceTier;
  final int? statusCode;
  final String? error;

  const AiCompletionResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.serviceTier,
    this.statusCode,
    this.error,
  });

  factory AiCompletionResponse.failure(String? error, [int? statusCode]) {
    return AiCompletionResponse(
      error: error,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic> get source {
    if (statusCode != 200) {
      return {
        "status_code": statusCode,
        "error": error,
      };
    }
    return {
      "id": id,
      "object": object,
      "created": created,
      "model": model,
      "service_tier": serviceTier,
      "system_fingerprint": systemFingerprint,
      "choices": choices?.map((e) => e.source).toList(),
      "usage": usage?.source,
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode {
    if (statusCode != 200) {
      return statusCode.hashCode ^ error.hashCode;
    }
    return id.hashCode ^
        object.hashCode ^
        created.hashCode ^
        model.hashCode ^
        serviceTier.hashCode ^
        systemFingerprint.hashCode ^
        choices.hashCode ^
        usage.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! AiCompletionResponse<T>) return false;
    if (statusCode != 200) {
      return other.statusCode == statusCode && other.error == error;
    }
    return other.id == id &&
        other.object == object &&
        other.created == created &&
        other.model == model &&
        other.serviceTier == systemFingerprint &&
        other.systemFingerprint == systemFingerprint &&
        other.choices == choices &&
        other.usage == usage;
  }

  @override
  String toString() => "$AiCompletionResponse#$hashCode($json)";
}

class AiSafetyRating {
  final String? category;
  final String? probability;

  const AiSafetyRating({
    this.category,
    this.probability,
  });

  Map<String, dynamic> get source {
    return {
      "category": category,
      "probability": probability,
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode => category.hashCode ^ probability.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiSafetyRating &&
        other.category == category &&
        other.probability == probability;
  }

  @override
  String toString() => "$AiSafetyRating#$hashCode($json)";
}

class AiChoice<T extends Object?> {
  final int? index;
  final AiMessage<T>? message;
  final bool? logprobs;
  final String? finishReason;
  final List<AiSafetyRating>? safetyRatings;

  const AiChoice({
    this.index,
    this.message,
    this.logprobs,
    this.finishReason,
    this.safetyRatings,
  });

  Map<String, dynamic> get source {
    return {
      "index": index,
      "message": message?.source,
      "logprobs": logprobs,
      "finish_reason": finishReason,
      "safety_ratings": safetyRatings?.map((e) => e.source).toList(),
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode =>
      index.hashCode ^
      message.hashCode ^
      logprobs.hashCode ^
      finishReason.hashCode ^
      safetyRatings.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiChoice<T> &&
        other.index == index &&
        other.message == message &&
        other.logprobs == logprobs &&
        other.finishReason == finishReason &&
        other.safetyRatings == safetyRatings;
  }

  @override
  String toString() => "$AiChoice#$hashCode($json)";
}

class AiMessage<T extends Object?> {
  final String? role;
  final String? content;
  final String? refusal;
  final T? data;

  const AiMessage({
    this.role,
    this.content,
    this.refusal,
    this.data,
  });

  Map<String, dynamic> get source {
    return {
      "role": role,
      "content": content,
      "refusal": refusal,
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode => role.hashCode ^ content.hashCode ^ refusal.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiMessage<T> &&
        other.role == role &&
        other.content == content &&
        other.refusal == refusal;
  }

  @override
  String toString() => "$AiMessage#$hashCode($json)";
}

class AiTokenUsage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final AiPromptTokensDetails? promptTokensDetails;
  final AiCompletionTokensDetails? completionTokensDetails;

  const AiTokenUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.completionTokensDetails,
    this.promptTokensDetails,
  });

  Map<String, dynamic> get source {
    return {
      "prompt_tokens": promptTokens,
      "completion_tokens": completionTokens,
      "total_tokens": totalTokens,
      "prompt_tokens_details": promptTokensDetails?.source,
      "completion_tokens_details": completionTokensDetails?.source,
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode =>
      promptTokens.hashCode ^ completionTokens.hashCode ^ totalTokens.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiTokenUsage &&
        other.promptTokens == promptTokens &&
        other.completionTokens == completionTokens &&
        other.totalTokens == totalTokens;
  }

  @override
  String toString() => "$AiTokenUsage#$hashCode($json)";
}

class AiPromptTokensDetails {
  final int? audioTokens;
  final int? cachedTokens;

  const AiPromptTokensDetails({
    this.audioTokens,
    this.cachedTokens,
  });

  Map<String, dynamic> get source {
    return {
      "audio_tokens": audioTokens,
      "cached_tokens": cachedTokens,
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode => audioTokens.hashCode ^ cachedTokens.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiPromptTokensDetails &&
        other.audioTokens == audioTokens &&
        other.cachedTokens == cachedTokens;
  }

  @override
  String toString() => "$AiPromptTokensDetails#$hashCode($json)";
}

class AiCompletionTokensDetails {
  final int? acceptedPredictionTokens;
  final int? audioTokens;
  final int? reasoningTokens;
  final int? rejectedPredictionTokens;

  const AiCompletionTokensDetails({
    this.acceptedPredictionTokens,
    this.audioTokens,
    this.reasoningTokens,
    this.rejectedPredictionTokens,
  });

  Map<String, dynamic> get source {
    return {
      "accepted_prediction_tokens": acceptedPredictionTokens,
      "audio_tokens": audioTokens,
      "reasoning_tokens": reasoningTokens,
      "rejected_prediction_tokens": rejectedPredictionTokens,
    };
  }

  String get json => jsonEncode(source);

  @override
  int get hashCode =>
      acceptedPredictionTokens.hashCode ^
      audioTokens.hashCode ^
      reasoningTokens.hashCode ^
      rejectedPredictionTokens.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiCompletionTokensDetails &&
        other.acceptedPredictionTokens == acceptedPredictionTokens &&
        other.audioTokens == audioTokens &&
        other.reasoningTokens == reasoningTokens &&
        other.rejectedPredictionTokens == rejectedPredictionTokens;
  }

  @override
  String toString() => "$AiCompletionTokensDetails#$hashCode($json)";
}
