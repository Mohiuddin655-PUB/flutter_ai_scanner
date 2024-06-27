import 'dart:convert';

typedef AiResponseDataBuilder<T extends Object?> = T Function(
  Map<String, dynamic> source,
);

class AiResponse<T extends Object?> {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<Choice<T>>? choices;
  final Usage? usage;
  final String? systemFingerprint;
  final int? statusCode;
  final String? error;

  const AiResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.statusCode,
    this.error,
  });

  factory AiResponse.from(
    Map<String, dynamic>? source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    source ??= {};
    final id = source["id"];
    final object = source["object"];
    final created = source["created"];
    final model = source["model"];
    final choices = source["choices"];
    final usage = source["usage"];
    final systemFingerprint = source["system_fingerprint"];
    return AiResponse<T>(
      id: id is String ? id : null,
      object: object is String ? object : null,
      created: created is int ? created : null,
      model: model is String ? model : null,
      choices: choices is List
          ? choices.whereType<Map<String, dynamic>>().map((e) {
              return Choice<T>.from(e, builder);
            }).toList()
          : null,
      usage: usage is Map<String, dynamic> ? Usage.from(usage) : null,
      systemFingerprint: systemFingerprint is String ? systemFingerprint : null,
      statusCode: 200,
    );
  }

  factory AiResponse.failure(String? error, [int? statusCode]) {
    return AiResponse(
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
      "system_fingerprint": systemFingerprint,
      "choices": choices?.map((e) => e.source),
      "usage": usage?.source,
    };
  }

  @override
  String toString() {
    return "AiResponse(${source.toString().replaceAll("{", "").replaceAll(",}", "").replaceAll("}", "")})";
  }
}

class Choice<T extends Object?> {
  final int? index;
  final Message<T>? message;
  final bool? logprobs;
  final String? finishReason;

  const Choice({
    this.index,
    this.message,
    this.logprobs,
    this.finishReason,
  });

  factory Choice.from(
    Map<String, dynamic>? source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    source ??= {};
    final index = source["index"];
    final message = source["message"];
    final logprobs = source["logprobs"];
    final finishReason = source["finish_reason"];
    return Choice<T>(
      index: index is int ? index : null,
      message: message is Map<String, dynamic>
          ? Message<T>.from(message, builder)
          : null,
      logprobs: logprobs is bool ? logprobs : null,
      finishReason: finishReason is String ? finishReason : null,
    );
  }

  Map<String, dynamic> get source {
    return {
      "index": index,
      "message": message?.source,
      "logprobs": logprobs,
      "finish_reason": finishReason
    };
  }

  @override
  String toString() {
    return "Choice(${source.toString().replaceAll("{", "").replaceAll(",}", "").replaceAll("}", "")})";
  }
}

class Message<T extends Object?> {
  final String? role;
  final String? content;
  final T? data;

  const Message({
    this.role,
    this.content,
    this.data,
  });

  static T? _data<T extends Object?>(
    String? source,
    AiResponseDataBuilder<T>? builder,
  ) {
    T? data;
    if (builder != null && source != null) {
      final raw = _extract(source);
      if (raw is Map<String, dynamic>) {
        data = builder(raw);
      }
    }
    return data;
  }

  static Map<String, dynamic>? _extract(String? source) {
    source ??= "{}";
    int start = source.indexOf('{');
    int end = source.lastIndexOf('}') + 1;
    if (start == -1 || end == 0) return null;
    final raw = source.substring(start, end);
    try {
      final data = json.decode(raw);
      return data;
    } catch (_) {
      return null;
    }
  }

  factory Message.from(
    Map<String, dynamic>? source, [
    AiResponseDataBuilder<T>? builder,
  ]) {
    source ??= {};
    final role = source["role"];
    final content = source["content"];
    print(content.runtimeType);
    return Message<T>(
      role: role is String ? role : null,
      content: content is String ? content : null,
      data: content is String ? _data(content, builder) : null,
    );
  }

  Map<String, dynamic> get source {
    return {
      "role": role,
      "content": content,
    };
  }

  @override
  String toString() {
    return "Message(${source.toString().replaceAll("{", "").replaceAll(",}", "").replaceAll("}", "")})";
  }
}

class Usage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  const Usage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });

  factory Usage.from(Map<String, dynamic>? source) {
    source ??= {};
    final promptTokens = source["prompt_tokens"];
    final completionTokens = source["completion_tokens"];
    final totalTokens = source["total_tokens"];
    return Usage(
      promptTokens: promptTokens is int ? promptTokens : null,
      completionTokens: completionTokens is int ? completionTokens : null,
      totalTokens: totalTokens is int ? totalTokens : null,
    );
  }

  Map<String, dynamic> get source {
    return {
      "prompt_tokens": promptTokens,
      "completion_tokens": completionTokens,
      "total_tokens": totalTokens,
    };
  }

  @override
  String toString() {
    return "Usage(${source.toString().replaceAll("{", "").replaceAll(",}", "").replaceAll("}", "")})";
  }
}
