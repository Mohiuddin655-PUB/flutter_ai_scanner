import 'package:flutter/material.dart';

import 'ai_food_scanner/ai_food_scanner.dart';
import 'ai_movie_scanner/ai_movie_page.dart';
import 'ai_movie_scanner/ai_movie_scanner.dart';

void main() async {
  AiFoodScanner.init(
    key: "sk-proj-F2qpRAsTD3bx7y0oPSymT3BlbkFJ1aJZjPKBtrV112qxO0N7",
    organization: "org-LyamYliNXiW6NAF6Y9wSfGkl",
  );
  AiMovieScanner.init(
    key: "sk-proj-F2qpRAsTD3bx7y0oPSymT3BlbkFJ1aJZjPKBtrV112qxO0N7",
    organization: "org-LyamYliNXiW6NAF6Y9wSfGkl",
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
      home: const AiMovieScannerPage(),
    );
  }
}
