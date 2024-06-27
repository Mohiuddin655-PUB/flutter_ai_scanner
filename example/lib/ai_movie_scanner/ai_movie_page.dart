import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_scanner/flutter_ai_scanner.dart';
import 'package:flutter_andomie/core.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'ai_movie_scanner.dart';

const _kUrl = "https://i.ytimg.com/vi/y1fZg0hhBX8/maxresdefault.jpg";

class AiMovieScannerPage extends StatefulWidget {
  const AiMovieScannerPage({super.key});

  @override
  State<AiMovieScannerPage> createState() => _AiMovieScannerPageState();
}

class _AiMovieScannerPageState extends State<AiMovieScannerPage> {
  final _pager = PageController();
  final _editor = TextEditingController();
  final _loading = ValueNotifier(false);
  final _file = ValueNotifier(_kUrl);
  AiResponse<AiMoviesData>? data;

  bool isValidPhotoUrl(String url) {
    if (!url.isValidWebUrl) return false;
    return true;
  }

  bool _isInitial = true;

  void _changeUrl() {
    final url = _editor.text;
    if (isValidPhotoUrl(url) && (_file.value != url || _isInitial)) {
      if (!_isInitial) _file.value = url;
      _isInitial = false;
      _loading.value = true;
      AiMovieScanner.i.scan(_file.value).then((data) {
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
          ValueListenableBuilder(
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
                      final items = choice.message?.data?.movies ?? [];
                      return ListView.separated(
                        padding: const EdgeInsets.only(
                          top: kToolbarHeight,
                          bottom: 50,
                          left: 24,
                          right: 24,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items.elementAtOrNull(index);
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "${item?.name}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(
                                        item?.releaseDate ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isValidPhotoUrl(item?.thumbnail ?? ""))
                                  Image.network(
                                    item!.thumbnail!,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    item?.description ?? "",
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
