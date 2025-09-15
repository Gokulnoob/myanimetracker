import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';

// User Statistics
class UserStatistics {
  final int totalAnime;
  final int completed;
  final int watching;
  final int planToWatch;
  final int onHold;
  final int dropped;
  final int totalEpisodes;
  final double averageScore;
  final int favorites;
  final Map<String, int> genreStats;
  final Map<int, int> yearStats;

  UserStatistics({
    required this.totalAnime,
    required this.completed,
    required this.watching,
    required this.planToWatch,
    required this.onHold,
    required this.dropped,
    required this.totalEpisodes,
    required this.averageScore,
    required this.favorites,
    required this.genreStats,
    required this.yearStats,
  });

  double get completionRate {
    if (totalAnime == 0) return 0.0;
    return (completed / totalAnime) * 100;
  }

  String get timeWatched {
    // Assuming average 24 minutes per episode
    final totalMinutes = totalEpisodes * 24;
    final hours = totalMinutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) {
      return '${days}d ${hours % 24}h';
    } else if (hours > 0) {
      return '${hours}h ${totalMinutes % 60}m';
    } else {
      return '${totalMinutes}m';
    }
  }

  List<MapEntry<String, int>> get topGenres {
    final entries = genreStats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  List<MapEntry<int, int>> get topYears {
    final entries = yearStats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }
}

// Profile State
class ProfileState {
  final UserStatistics statistics;
  final bool isLoading;
  final String? error;

  ProfileState({
    required this.statistics,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserStatistics? statistics,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(statistics: _emptyStatistics())) {
    loadStatistics();
  }

  static UserStatistics _emptyStatistics() {
    return UserStatistics(
      totalAnime: 0,
      completed: 0,
      watching: 0,
      planToWatch: 0,
      onHold: 0,
      dropped: 0,
      totalEpisodes: 0,
      averageScore: 0.0,
      favorites: 0,
      genreStats: {},
      yearStats: {},
    );
  }

  void loadStatistics() {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final basicStats = HiveService.getUserStatistics();
      final genreStats = _calculateGenreStatistics();
      final yearStats = _calculateYearStatistics();

      final statistics = UserStatistics(
        totalAnime: basicStats['totalAnime'] ?? 0,
        completed: basicStats['completed'] ?? 0,
        watching: basicStats['watching'] ?? 0,
        planToWatch: basicStats['planToWatch'] ?? 0,
        onHold: basicStats['onHold'] ?? 0,
        dropped: basicStats['dropped'] ?? 0,
        totalEpisodes: basicStats['totalEpisodes'] ?? 0,
        averageScore: basicStats['averageScore'] ?? 0.0,
        favorites: basicStats['favorites'] ?? 0,
        genreStats: genreStats,
        yearStats: yearStats,
      );

      state = state.copyWith(statistics: statistics, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load statistics: $e',
      );
    }
  }

  Map<String, int> _calculateGenreStatistics() {
    final genreCount = <String, int>{};
    final userEntries = HiveService.getAllUserAnimeEntries();

    for (final entry in userEntries) {
      final anime = HiveService.getAnime(entry.animeId);
      if (anime != null) {
        for (final genre in anime.genres) {
          genreCount[genre.name] = (genreCount[genre.name] ?? 0) + 1;
        }
      }
    }

    return genreCount;
  }

  Map<int, int> _calculateYearStatistics() {
    final yearCount = <int, int>{};
    final userEntries = HiveService.getAllUserAnimeEntries();

    for (final entry in userEntries) {
      final anime = HiveService.getAnime(entry.animeId);
      if (anime != null && anime.year != null) {
        yearCount[anime.year!] = (yearCount[anime.year!] ?? 0) + 1;
      }
    }

    return yearCount;
  }

  Future<Map<String, dynamic>> exportUserData() async {
    try {
      return await HiveService.exportUserData();
    } catch (e) {
      state = state.copyWith(error: 'Failed to export data: $e');
      rethrow;
    }
  }

  Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await HiveService.importUserData(data);
      loadStatistics(); // Refresh statistics after import
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to import data: $e',
      );
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await HiveService.userAnimeBox.clear();
      await HiveService.clearSearchHistory();
      await HiveService.animeBox.clear();
      loadStatistics(); // Refresh statistics after clearing
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear data: $e',
      );
      rethrow;
    }
  }
}

// Settings State
class AppSettings {
  final bool isDarkMode;
  final bool showSpoilers;
  final bool autoBackup;
  final int cacheLimit;
  final bool offlineMode;

  AppSettings({
    this.isDarkMode = false,
    this.showSpoilers = false,
    this.autoBackup = true,
    this.cacheLimit = 1000,
    this.offlineMode = false,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? showSpoilers,
    bool? autoBackup,
    int? cacheLimit,
    bool? offlineMode,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showSpoilers: showSpoilers ?? this.showSpoilers,
      autoBackup: autoBackup ?? this.autoBackup,
      cacheLimit: cacheLimit ?? this.cacheLimit,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }
}

// Settings Notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    loadSettings();
  }

  void loadSettings() {
    final settings = AppSettings(
      isDarkMode:
          HiveService.getSetting('isDarkMode', defaultValue: false) ?? false,
      showSpoilers:
          HiveService.getSetting('showSpoilers', defaultValue: false) ?? false,
      autoBackup:
          HiveService.getSetting('autoBackup', defaultValue: true) ?? true,
      cacheLimit:
          HiveService.getSetting('cacheLimit', defaultValue: 1000) ?? 1000,
      offlineMode:
          HiveService.getSetting('offlineMode', defaultValue: false) ?? false,
    );

    state = settings;
  }

  Future<void> updateDarkMode(bool isDarkMode) async {
    await HiveService.saveSetting('isDarkMode', isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  Future<void> updateShowSpoilers(bool showSpoilers) async {
    await HiveService.saveSetting('showSpoilers', showSpoilers);
    state = state.copyWith(showSpoilers: showSpoilers);
  }

  Future<void> updateAutoBackup(bool autoBackup) async {
    await HiveService.saveSetting('autoBackup', autoBackup);
    state = state.copyWith(autoBackup: autoBackup);
  }

  Future<void> updateCacheLimit(int cacheLimit) async {
    await HiveService.saveSetting('cacheLimit', cacheLimit);
    state = state.copyWith(cacheLimit: cacheLimit);
  }

  Future<void> updateOfflineMode(bool offlineMode) async {
    await HiveService.saveSetting('offlineMode', offlineMode);
    state = state.copyWith(offlineMode: offlineMode);
  }
}

// Providers
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

// Convenience providers
final userStatisticsProvider = Provider<UserStatistics>((ref) {
  return ref.watch(profileProvider).statistics;
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isDarkMode;
});
