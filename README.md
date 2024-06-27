# flutter_ai_scanner

## Example

```dart
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
```

## FOOD NUTRITION INFORMATION
```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_scanner/flutter_ai_scanner.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

const _kUrl =
    "https://www.foodiesfeed.com/wp-content/uploads/2023/06/burger-with-melted-cheese.jpg";

class AiFoodScannerPage extends StatefulWidget {
  const AiFoodScannerPage({super.key});

  @override
  State<AiFoodScannerPage> createState() => _AiFoodScannerPageState();
}

class _AiFoodScannerPageState extends State<AiFoodScannerPage> {
  final _pager = PageController();
  final _editor = TextEditingController();
  final _loading = ValueNotifier(false);
  final _file = ValueNotifier(_kUrl);
  AiResponse<AiNutritionData>? data;

  bool isValidPhotoUrl(String url) {
    if (!url.startsWith("https://")) return false;
    if (!(url.contains(".jpg") ||
        url.contains(".jpeg") ||
        url.contains(".png") ||
        url.contains(".webp") ||
        url.contains(".gif"))) {
      return false;
    }
    return true;
  }

  bool _isInitial = true;

  void _changeUrl() {
    final url = _editor.text;
    if (isValidPhotoUrl(url) && (_file.value != url || _isInitial)) {
      if (!_isInitial) _file.value = url;
      _isInitial = false;
      _loading.value = true;
      AiFoodScanner.i.scan(_file.value).then((data) {
        this.data = data;
        _loading.value = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _editor.text = _file.value;
    _editor.addListener(_changeUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) => _changeUrl());
  }

  @override
  void dispose() {
    _editor.removeListener(_changeUrl);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ValueListenableBuilder(
            valueListenable: _file,
            builder: (context, value, child) {
              return Image.network(value, fit: BoxFit.cover);
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
            child: const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black38),
            ),
          ),
          Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: kToolbarHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _file,
                          builder: (context, value, child) {
                            return Image.network(
                              value,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            height: 50,
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _editor,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: "Input the food photo url",
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _loading,
                  builder: (context, value, child) {
                    if (value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    final choices = data?.choices ?? [];
                    return Stack(
                      children: [
                        PageView.builder(
                          controller: _pager,
                          scrollDirection: Axis.horizontal,
                          itemCount: choices.length,
                          itemBuilder: (context, index) {
                            final choice = choices.elementAt(index);
                            final items = choice.message?.data?.items ?? [];
                            return ListView.separated(
                              padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 50,
                                left: 24,
                                right: 24,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items.elementAt(index);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    subtitle: Text(
                                      item.name ?? "",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                    title: Text(
                                      "${item.calorie ?? 0}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8);
                              },
                            );
                          },
                        ),
                        if (choices.length > 1)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: SmoothPageIndicator(
                                count: choices.length,
                                controller: _pager,
                                effect: const WormEffect(
                                  dotColor: Colors.white24,
                                  activeDotColor: Colors.white54,
                                  dotHeight: 8,
                                  dotWidth: 8,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
```