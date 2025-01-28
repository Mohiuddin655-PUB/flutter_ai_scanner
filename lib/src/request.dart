import 'dart:convert';

import 'response.dart';

class AiCompletionRequest<T extends Object?> {
  final String? tag;
  final String prompt;
  final String? _system;
  final dynamic data;
  final String? model;
  final int? maxTokens;
  final int? temperature;
  final int? n;
  final Map<String, dynamic>? schema;
  final AiResponseDataBuilder<T>? builder;

  String? get system {
    if (schema != null && schema!.isNotEmpty) {
      if (_system == null || !_system.contains("{SCHEMA}")) {
        return "Following the json schema and provide me only json. if you not found return null.\nSchema: ${jsonEncode(schema)}";
      }
      return _system.replaceAll("{SCHEMA}", jsonEncode(schema));
    }
    return null;
  }

  const AiCompletionRequest({
    this.tag,
    required this.prompt,
    this.data,
    this.schema,
    this.model,
    this.maxTokens,
    this.n,
    this.temperature,
    this.builder,
    String? system,
  }) : _system = system;

  @override
  int get hashCode =>
      tag.hashCode ^
      prompt.hashCode ^
      _system.hashCode ^
      schema.hashCode ^
      data.hashCode ^
      model.hashCode ^
      maxTokens.hashCode ^
      n.hashCode ^
      temperature.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiCompletionRequest<T> &&
        other.tag == tag &&
        other.prompt == prompt &&
        other._system == _system &&
        other.schema == schema &&
        other.data == data &&
        other.model == model &&
        other.maxTokens == maxTokens &&
        other.n == n &&
        other.temperature == temperature;
  }

  @override
  String toString() {
    return "$AiCompletionRequest<$T>#$hashCode(tag: $tag, prompt: $prompt, system: $_system, format: $schema, data: $data, model: $model, maxTokens: $maxTokens, n: $n, temperature: $temperature)";
  }
}
