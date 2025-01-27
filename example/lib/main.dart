import 'package:flutter/material.dart';
import 'package:flutter_ai_scanner/flutter_ai_scanner.dart';

void main() async {
  Ai.delegate = const GptAiDelegate(key: 'YOUR API KEY HERE');
  // Ai.delegate = const GeminiAiDelegate(key: 'YOUR API KEY HERE');
  final response = await Ai.completions(
    AiCompletionRequest(
      prompt: "i ate one piece medium apple and 2 pieces boiled eggs",
      system:
          "Following the json schema and provide me only json. if you not found return null.\nSchema: {SCHEMA}",
      schema: {
        "name": "string",
        "total_calories": "double",
        "total_protein": "double",
        "total_fat": "double",
        "total_carbs": "double",
        "ingredients": [
          {
            "name": "string",
            "calories": "double",
            "proteinInGram": "double",
            "fatInGram": "double",
            "carbsInGram": "double",
            "quantity": "int",
            "size": "string",
          }
        ],
      },
      builder: (value) => AiData.from(value),
    ),
  );
  print(response.choices?.firstOrNull?.message?.data);
  runApp(const MyApp());
}

class AiData {
  final String? name;
  final double? totalCalories;
  final double? totalProtein;
  final double? totalFat;
  final double? totalCarbs;
  final List<AiDataIngredient>? ingredients;

  const AiData({
    this.name,
    this.totalCalories,
    this.totalProtein,
    this.totalFat,
    this.totalCarbs,
    this.ingredients,
  });

  factory AiData.from(Map<String, dynamic> source) {
    return AiData(
      name: source['name'] as String?,
      totalCalories: (source['total_calories'] as num?)?.toDouble(),
      totalProtein: (source['total_protein'] as num?)?.toDouble(),
      totalFat: (source['total_fat'] as num?)?.toDouble(),
      totalCarbs: (source['total_carbs'] as num?)?.toDouble(),
      ingredients: (source['ingredients'] as List<dynamic>?)
          ?.map((e) => AiDataIngredient.from(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> get source {
    return {
      'name': name,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_fat': totalFat,
      'total_carbs': totalCarbs,
      'ingredients': ingredients?.map((e) => e.source).toList(),
    };
  }

  @override
  String toString() => "$AiData($source)";
}

class AiDataIngredient {
  final String? name;
  final double? calories;
  final double? proteinInGram;
  final double? fatInGram;
  final double? carbsInGram;
  final int? quantity;
  final String? size;

  const AiDataIngredient({
    this.name,
    this.calories,
    this.proteinInGram,
    this.fatInGram,
    this.carbsInGram,
    this.quantity,
    this.size,
  });

  factory AiDataIngredient.from(Map<String, dynamic> source) {
    return AiDataIngredient(
      name: source['name'] as String?,
      calories: (source['calories'] as num?)?.toDouble(),
      proteinInGram: (source['proteinInGram'] as num?)?.toDouble(),
      fatInGram: (source['fatInGram'] as num?)?.toDouble(),
      carbsInGram: (source['carbsInGram'] as num?)?.toDouble(),
      quantity: source['quantity'] as int?,
      size: source['size'] as String?,
    );
  }

  Map<String, dynamic> get source {
    return {
      'name': name,
      'calories': calories,
      'proteinInGram': proteinInGram,
      'fatInGram': fatInGram,
      'carbsInGram': carbsInGram,
      'quantity': quantity,
      'size': size,
    };
  }

  @override
  String toString() => "$AiDataIngredient($source)";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Ai Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Container(),
    );
  }
}
