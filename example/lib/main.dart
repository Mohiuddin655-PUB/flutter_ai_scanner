import 'package:flutter/material.dart';

import 'ai_food_scanner/ai_food_page.dart';
import 'ai_food_scanner/ai_food_scanner.dart';

void main() async {
  AiFoodScanner.init(
    key: "OPEN_AI_GPT_KEY",
    organization: "OPEN_AI_GPT_ORGANIZATION",
  );
  runApp(const MyApp());
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
      home: const AiFoodScannerPage(),
    );
  }
}
