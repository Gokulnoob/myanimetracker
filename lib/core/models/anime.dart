import 'package:hive/hive.dart';

part 'anime.g.dart';

@HiveType(typeId: 0)
class Anime extends HiveObject {
  @HiveField(0)
  final int malId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? titleEnglish;

  @HiveField(3)
  final String? titleJapanese;

  @HiveField(4)
  final String? synopsis;

  @HiveField(5)
  final AnimeImages images;

  @HiveField(6)
  final int? episodes;

  @HiveField(7)
  final String? duration;

  @HiveField(8)
  final String? rating;

  @HiveField(9)
  final double? score;

  @HiveField(10)
  final int? scoredBy;

  @HiveField(11)
  final int? rank;

  @HiveField(12)
  final int? popularity;

  @HiveField(13)
  final List<Genre> genres;

  @HiveField(14)
  final List<Studio> studios;

  @HiveField(15)
  final String? source;

  @HiveField(16)
  final String? status;

  @HiveField(17)
  final String? aired;

  @HiveField(18)
  final String? season;

  @HiveField(19)
  final int? year;

  @HiveField(20)
  final String? type;

  @HiveField(21)
  final DateTime? lastUpdated;

  Anime({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    this.synopsis,
    required this.images,
    this.episodes,
    this.duration,
    this.rating,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    required this.genres,
    required this.studios,
    this.source,
    this.status,
    this.aired,
    this.season,
    this.year,
    this.type,
    this.lastUpdated,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] ?? 0,
      title: json['title'] ?? '',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      synopsis: json['synopsis'],
      images: AnimeImages.fromJson(json['images'] ?? {}),
      episodes: json['episodes'],
      duration: json['duration'],
      rating: json['rating'],
      score: json['score']?.toDouble(),
      scoredBy: json['scored_by'],
      rank: json['rank'],
      popularity: json['popularity'],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => Genre.fromJson(g))
              .toList() ??
          [],
      studios: (json['studios'] as List<dynamic>?)
              ?.map((s) => Studio.fromJson(s))
              .toList() ??
          [],
      source: json['source'],
      status: json['status'],
      aired: json['aired']?['string'],
      season: json['season'],
      year: json['year'],
      type: json['type'],
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'title': title,
      'title_english': titleEnglish,
      'title_japanese': titleJapanese,
      'synopsis': synopsis,
      'images': images.toJson(),
      'episodes': episodes,
      'duration': duration,
      'rating': rating,
      'score': score,
      'scored_by': scoredBy,
      'rank': rank,
      'popularity': popularity,
      'genres': genres.map((g) => g.toJson()).toList(),
      'studios': studios.map((s) => s.toJson()).toList(),
      'source': source,
      'status': status,
      'aired': {'string': aired},
      'season': season,
      'year': year,
      'type': type,
    };
  }

  String get displayTitle => titleEnglish ?? title;

  String get imageUrl => images.jpg.largeImageUrl ?? images.jpg.imageUrl ?? '';

  bool get isAiring => status?.toLowerCase() == 'currently airing';

  String get episodeProgress =>
      episodes != null ? 'Episodes: $episodes' : 'Episodes: Unknown';
}

@HiveType(typeId: 1)
class AnimeImages extends HiveObject {
  @HiveField(0)
  final ImageSet jpg;

  @HiveField(1)
  final ImageSet webp;

  AnimeImages({
    required this.jpg,
    required this.webp,
  });

  factory AnimeImages.fromJson(Map<String, dynamic> json) {
    return AnimeImages(
      jpg: ImageSet.fromJson(json['jpg'] ?? {}),
      webp: ImageSet.fromJson(json['webp'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jpg': jpg.toJson(),
      'webp': webp.toJson(),
    };
  }
}

@HiveType(typeId: 2)
class ImageSet extends HiveObject {
  @HiveField(0)
  final String? imageUrl;

  @HiveField(1)
  final String? smallImageUrl;

  @HiveField(2)
  final String? largeImageUrl;

  ImageSet({
    this.imageUrl,
    this.smallImageUrl,
    this.largeImageUrl,
  });

  factory ImageSet.fromJson(Map<String, dynamic> json) {
    return ImageSet(
      imageUrl: json['image_url'],
      smallImageUrl: json['small_image_url'],
      largeImageUrl: json['large_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'small_image_url': smallImageUrl,
      'large_image_url': largeImageUrl,
    };
  }
}

@HiveType(typeId: 3)
class Genre extends HiveObject {
  @HiveField(0)
  final int malId;

  @HiveField(1)
  final String name;

  Genre({
    required this.malId,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      malId: json['mal_id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'name': name,
    };
  }
}

@HiveType(typeId: 4)
class Studio extends HiveObject {
  @HiveField(0)
  final int malId;

  @HiveField(1)
  final String name;

  Studio({
    required this.malId,
    required this.name,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      malId: json['mal_id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'name': name,
    };
  }
}
