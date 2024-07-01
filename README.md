# flutter_ai_scanner

## INIT
```dart
void main() async {
  AiFoodScanner.init(
    key: "OPEN_AI_GPT_KEY",
    organization: "OPEN_AI_GPT_ORGANIZATION",
  );
  // ...
}
```

## DATA MODEL
```dart
class AiFoodData {
  final double? calorie;
  final String? name;

  const AiFoodData({
    this.calorie,
    this.name,
  });

  factory AiFoodData.from(Object? source) {
    final data = source is Map<String, dynamic> ? source : {};
    final calorie = data["calorie"];
    final name = data["name"];
    return AiFoodData(
      calorie: calorie is num ? calorie.toDouble() : null,
      name: name is String ? name : null,
    );
  }

  Map<String, dynamic> get source {
    return {
      "calorie": calorie,
      "name": name,
    };
  }
}

class AiNutritionData {
  final double? calorie;
  final List<AiFoodData>? items;

  const AiNutritionData({
    this.calorie,
    this.items,
  });

  factory AiNutritionData.from(Object? source) {
    final data = source is Map<String, dynamic> ? source : {};
    final calorie = data["calorie"];
    final items = data["items"];
    return AiNutritionData(
      calorie: calorie is num ? calorie.toDouble() : null,
      items: items is List ? items.map((AiFoodData.from)).toList() : null,
    );
  }

  factory AiNutritionData.sample() {
    final items = [
      const AiFoodData(name: "Mango", calorie: 34.0),
      const AiFoodData(name: "Orange", calorie: 21.3)
    ];
    return AiNutritionData(
      calorie: 0.0,
      items: items,
    );
  }

  Map<String, dynamic> get source {
    return {
      "calorie": calorie,
      "items": items?.map((e) => e.source),
    };
  }
}
```

## AI_SCANNER 
```dart
import 'package:flutter_ai_scanner/flutter_ai_scanner.dart';

class AiFoodScanner extends AiScanner {
  const AiFoodScanner({
    required super.key,
    super.organization,
  });

  static AiFoodScanner? _i;

  static AiFoodScanner get i {
    if (_i != null) {
      return _i!;
    } else {
      throw UnimplementedError("AiFoodScanner not initialized yet!");
    }
  }

  static void init({
    required String key,
    String? organization,
  }) {
    _i = AiFoodScanner(
      key: key,
      organization: organization,
    );
  }

  Future<AiResponse<AiNutritionData>> scan(String url) {
    final json = AiNutritionData.sample().source;
    return execute(AiRequest<AiNutritionData>.scan(
      category: "food",
      preconditions: "nutrition information",
      sample: json,
      url: url,
      builder: AiNutritionData.from,
      n: 3,
    ));
  }
}
```

## SCAN IMAGE
```dart
Future<AiResponse<AiNutritionData>> scanData(String imageUrl){
  return AiFoodScanner.i.scan(imageUrl);
}
```