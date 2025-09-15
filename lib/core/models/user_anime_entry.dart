import 'package:hive/hive.dart';

part 'user_anime_entry.g.dart';

@HiveType(typeId: 5)
enum WatchStatus {
  @HiveField(0)
  watching,

  @HiveField(1)
  completed,

  @HiveField(2)
  planToWatch,

  @HiveField(3)
  onHold,

  @HiveField(4)
  dropped,
}

extension WatchStatusExtension on WatchStatus {
  String get displayName {
    switch (this) {
      case WatchStatus.watching:
        return 'Currently Watching';
      case WatchStatus.completed:
        return 'Completed';
      case WatchStatus.planToWatch:
        return 'Plan to Watch';
      case WatchStatus.onHold:
        return 'On Hold';
      case WatchStatus.dropped:
        return 'Dropped';
    }
  }

  String get shortName {
    switch (this) {
      case WatchStatus.watching:
        return 'Watching';
      case WatchStatus.completed:
        return 'Completed';
      case WatchStatus.planToWatch:
        return 'Plan to Watch';
      case WatchStatus.onHold:
        return 'On Hold';
      case WatchStatus.dropped:
        return 'Dropped';
    }
  }
}

@HiveType(typeId: 6)
class UserAnimeEntry extends HiveObject {
  @HiveField(0)
  final int animeId;

  @HiveField(1)
  WatchStatus status;

  @HiveField(2)
  int episodesWatched;

  @HiveField(3)
  double? personalScore;

  @HiveField(4)
  String? personalNotes;

  @HiveField(5)
  final DateTime dateAdded;

  @HiveField(6)
  DateTime? dateCompleted;

  @HiveField(7)
  DateTime? dateStarted;

  @HiveField(8)
  DateTime lastModified;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  int? totalEpisodes;

  UserAnimeEntry({
    required this.animeId,
    required this.status,
    this.episodesWatched = 0,
    this.personalScore,
    this.personalNotes,
    required this.dateAdded,
    this.dateCompleted,
    this.dateStarted,
    required this.lastModified,
    this.isFavorite = false,
    this.totalEpisodes,
  });

  factory UserAnimeEntry.create({
    required int animeId,
    required WatchStatus status,
    int episodesWatched = 0,
    int? totalEpisodes,
  }) {
    final now = DateTime.now();
    return UserAnimeEntry(
      animeId: animeId,
      status: status,
      episodesWatched: episodesWatched,
      dateAdded: now,
      lastModified: now,
      dateStarted: status == WatchStatus.watching ? now : null,
      totalEpisodes: totalEpisodes,
    );
  }

  void updateStatus(WatchStatus newStatus) {
    final now = DateTime.now();
    status = newStatus;
    lastModified = now;

    switch (newStatus) {
      case WatchStatus.watching:
        dateStarted ??= now;
        dateCompleted = null;
        break;
      case WatchStatus.completed:
        dateCompleted = now;
        if (totalEpisodes != null) {
          episodesWatched = totalEpisodes!;
        }
        break;
      case WatchStatus.planToWatch:
        dateStarted = null;
        dateCompleted = null;
        episodesWatched = 0;
        break;
      case WatchStatus.onHold:
      case WatchStatus.dropped:
        dateCompleted = null;
        break;
    }
  }

  void updateProgress(int episodes) {
    episodesWatched = episodes;
    lastModified = DateTime.now();

    // Auto-complete if watched all episodes
    if (totalEpisodes != null && episodes >= totalEpisodes!) {
      updateStatus(WatchStatus.completed);
    }
  }

  void updateScore(double? score) {
    personalScore = score;
    lastModified = DateTime.now();
  }

  void updateNotes(String? notes) {
    personalNotes = notes;
    lastModified = DateTime.now();
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    lastModified = DateTime.now();
  }

  double get progressPercentage {
    if (totalEpisodes == null || totalEpisodes == 0) return 0.0;
    return (episodesWatched / totalEpisodes!).clamp(0.0, 1.0);
  }

  String get progressText {
    if (totalEpisodes == null) {
      return '$episodesWatched episodes';
    }
    return '$episodesWatched / $totalEpisodes episodes';
  }

  bool get isCompleted => status == WatchStatus.completed;
  bool get isWatching => status == WatchStatus.watching;
  bool get isPlanToWatch => status == WatchStatus.planToWatch;

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'status': status.index,
      'episodesWatched': episodesWatched,
      'personalScore': personalScore,
      'personalNotes': personalNotes,
      'dateAdded': dateAdded.toIso8601String(),
      'dateCompleted': dateCompleted?.toIso8601String(),
      'dateStarted': dateStarted?.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'isFavorite': isFavorite,
      'totalEpisodes': totalEpisodes,
    };
  }

  factory UserAnimeEntry.fromJson(Map<String, dynamic> json) {
    return UserAnimeEntry(
      animeId: json['animeId'],
      status: WatchStatus.values[json['status']],
      episodesWatched: json['episodesWatched'] ?? 0,
      personalScore: json['personalScore']?.toDouble(),
      personalNotes: json['personalNotes'],
      dateAdded: DateTime.parse(json['dateAdded']),
      dateCompleted: json['dateCompleted'] != null
          ? DateTime.parse(json['dateCompleted'])
          : null,
      dateStarted: json['dateStarted'] != null
          ? DateTime.parse(json['dateStarted'])
          : null,
      lastModified: DateTime.parse(json['lastModified']),
      isFavorite: json['isFavorite'] ?? false,
      totalEpisodes: json['totalEpisodes'],
    );
  }
}
