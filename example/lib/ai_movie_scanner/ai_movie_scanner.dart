import 'package:flutter_ai_scanner/flutter_ai_scanner.dart';

class AiMovieData {
  final String? name;
  final String? description;
  final String? releaseDate;
  final String? thumbnail;
  final String? trailer;
  final int? durationInSeconds;

  const AiMovieData({
    this.name,
    this.description,
    this.releaseDate,
    this.thumbnail,
    this.trailer,
    this.durationInSeconds,
  });

  factory AiMovieData.from(Object? source) {
    final data = source is Map<String, dynamic> ? source : {};
    final name = data["name"];
    final description = data["description"];
    final releaseDate = data["release_date"];
    final thumbnail = data["thumbnail"];
    final trailer = data["trailer"];
    final durationInSeconds = data["duration_in_seconds"];
    return AiMovieData(
      name: name is String ? name : null,
      description: description is String ? description : null,
      releaseDate: releaseDate is String ? releaseDate : null,
      thumbnail: thumbnail is String ? thumbnail : null,
      trailer: trailer is String ? trailer : null,
      durationInSeconds: durationInSeconds is int ? durationInSeconds : null,
    );
  }

  factory AiMovieData.sample() {
    return const AiMovieData(
        name: "KGF 2",
        description: "The most popular movie in india",
        releaseDate: "Dec 23, 2021",
        durationInSeconds: 209,
        thumbnail: "movie thumbnail url, pick from google",
        trailer: "movie trailer url, pick from youtube");
  }

  Map<String, dynamic> get source {
    return {
      "name": name,
      "description": description,
      "release_date": releaseDate,
      "thumbnail": thumbnail,
      "trailer": trailer,
      "duration_in_seconds": durationInSeconds,
    };
  }
}

class AiMoviesData {
  final List<AiMovieData>? movies;

  const AiMoviesData({
    this.movies,
  });

  factory AiMoviesData.from(Object? source) {
    final data = source is Map<String, dynamic> ? source : {};
    final items = data["movies"];
    return AiMoviesData(
      movies: items is List ? items.map((AiMovieData.from)).toList() : null,
    );
  }

  factory AiMoviesData.sample() {
    final items = [AiMovieData.sample()];
    return AiMoviesData(
      movies: items,
    );
  }

  Map<String, dynamic> get source {
    return {
      "movies": movies?.map((e) => e.source),
    };
  }
}

class AiMovieScanner extends AiScanner {
  const AiMovieScanner({
    required super.key,
    super.organization,
  });

  static AiMovieScanner? _i;

  static AiMovieScanner get i {
    if (_i != null) {
      return _i!;
    } else {
      throw UnimplementedError("AiMovieScanner not initialized yet!");
    }
  }

  static void init({
    required String key,
    String? organization,
  }) {
    _i = AiMovieScanner(
      key: key,
      organization: organization,
    );
  }

  Future<AiResponse<AiMoviesData>> scan(String url) {
    final json = AiMoviesData.sample().source;
    return execute(AiRequest<AiMoviesData>.suggest(
      sample: json,
      category: "3 horror movies",
      preconditions: "IMDb: 8-10, etc",
      builder: AiMoviesData.from,
      n: 3,
    ));
  }
}
