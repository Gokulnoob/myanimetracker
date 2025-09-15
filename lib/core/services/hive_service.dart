import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class HiveService {
  static const String _animeBoxName = 'anime_box';
  static const String _userAnimeBoxName = 'user_anime_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _searchHistoryBoxName = 'search_history_box';

  static late Box<Anime> _animeBox;
  static late Box<UserAnimeEntry> _userAnimeBox;
  static late Box<dynamic> _settingsBox;
  static late Box<String> _searchHistoryBox;

  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnimeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AnimeImagesAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ImageSetAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(GenreAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(StudioAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(WatchStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(UserAnimeEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(AnimeTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(AnimeStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(SortByAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(SortOrderAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(SearchFiltersAdapter());
    }

    // Open boxes
    _animeBox = await Hive.openBox<Anime>(_animeBoxName);
    _userAnimeBox = await Hive.openBox<UserAnimeEntry>(_userAnimeBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _searchHistoryBox = await Hive.openBox<String>(_searchHistoryBoxName);
  }

  // Anime operations
  static Box<Anime> get animeBox => _animeBox;

  static Future<void> saveAnime(Anime anime) async {
    await _animeBox.put(anime.malId, anime);
  }

  static Future<void> saveAnimeList(List<Anime> animeList) async {
    final Map<int, Anime> animeMap = {
      for (Anime anime in animeList) anime.malId: anime
    };
    await _animeBox.putAll(animeMap);
  }

  static Anime? getAnime(int malId) {
    return _animeBox.get(malId);
  }

  static List<Anime> getAllAnime() {
    return _animeBox.values.toList();
  }

  static List<Anime> searchAnimeLocally(String query) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _animeBox.values.where((anime) {
      return anime.title.toLowerCase().contains(lowercaseQuery) ||
          anime.titleEnglish?.toLowerCase().contains(lowercaseQuery) == true ||
          anime.titleJapanese?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }

  static Future<void> clearAnimeCache() async {
    await _animeBox.clear();
  }

  // User anime list operations
  static Box<UserAnimeEntry> get userAnimeBox => _userAnimeBox;

  static Future<void> saveUserAnimeEntry(UserAnimeEntry entry) async {
    await _userAnimeBox.put(entry.animeId, entry);
  }

  static UserAnimeEntry? getUserAnimeEntry(int animeId) {
    return _userAnimeBox.get(animeId);
  }

  static Future<void> removeUserAnimeEntry(int animeId) async {
    await _userAnimeBox.delete(animeId);
  }

  static List<UserAnimeEntry> getAllUserAnimeEntries() {
    return _userAnimeBox.values.toList();
  }

  static List<UserAnimeEntry> getUserAnimeByStatus(WatchStatus status) {
    return _userAnimeBox.values
        .where((entry) => entry.status == status)
        .toList();
  }

  static List<UserAnimeEntry> getFavoriteAnime() {
    return _userAnimeBox.values.where((entry) => entry.isFavorite).toList();
  }

  // Settings operations
  static Box<dynamic> get settingsBox => _settingsBox;

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> removeSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Search history operations
  static Box<String> get searchHistoryBox => _searchHistoryBox;

  static Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    // Remove if already exists to avoid duplicates
    await removeSearchHistory(query);

    // Add to the beginning
    await _searchHistoryBox.add(query);

    // Keep only last 20 searches
    if (_searchHistoryBox.length > 20) {
      await _searchHistoryBox.deleteAt(0);
    }
  }

  static Future<void> removeSearchHistory(String query) async {
    final keys = _searchHistoryBox.keys
        .where((key) => _searchHistoryBox.get(key) == query)
        .toList();

    for (final key in keys) {
      await _searchHistoryBox.delete(key);
    }
  }

  static List<String> getSearchHistory() {
    return _searchHistoryBox.values.toList().reversed.toList();
  }

  static Future<void> clearSearchHistory() async {
    await _searchHistoryBox.clear();
  }

  // Statistics methods
  static Map<String, dynamic> getUserStatistics() {
    final entries = getAllUserAnimeEntries();

    final completed = entries.where((e) => e.isCompleted).length;
    final watching = entries.where((e) => e.isWatching).length;
    final planToWatch = entries.where((e) => e.isPlanToWatch).length;
    final onHold = entries.where((e) => e.status == WatchStatus.onHold).length;
    final dropped =
        entries.where((e) => e.status == WatchStatus.dropped).length;

    final totalEpisodes = entries
        .where((e) => e.isCompleted)
        .fold<int>(0, (sum, e) => sum + (e.totalEpisodes ?? 0));

    final averageScore = entries
            .where((e) => e.personalScore != null)
            .fold<double>(0, (sum, e) => sum + e.personalScore!) /
        entries.where((e) => e.personalScore != null).length;

    return {
      'totalAnime': entries.length,
      'completed': completed,
      'watching': watching,
      'planToWatch': planToWatch,
      'onHold': onHold,
      'dropped': dropped,
      'totalEpisodes': totalEpisodes,
      'averageScore': averageScore.isNaN ? 0.0 : averageScore,
      'favorites': entries.where((e) => e.isFavorite).length,
    };
  }

  // Cleanup
  static Future<void> dispose() async {
    await _animeBox.close();
    await _userAnimeBox.close();
    await _settingsBox.close();
    await _searchHistoryBox.close();
  }

  // Backup and restore (optional)
  static Future<Map<String, dynamic>> exportUserData() async {
    return {
      'userAnimeEntries': _userAnimeBox.values.map((e) => e.toJson()).toList(),
      'settings': Map<String, dynamic>.from(_settingsBox.toMap()),
      'searchHistory': _searchHistoryBox.values.toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  static Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      // Import user anime entries
      if (data['userAnimeEntries'] != null) {
        await _userAnimeBox.clear();
        final entries = (data['userAnimeEntries'] as List)
            .map((json) => UserAnimeEntry.fromJson(json))
            .toList();

        for (final entry in entries) {
          await saveUserAnimeEntry(entry);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        await _settingsBox.clear();
        await _settingsBox.putAll(Map<String, dynamic>.from(data['settings']));
      }

      // Import search history
      if (data['searchHistory'] != null) {
        await _searchHistoryBox.clear();
        for (final query in data['searchHistory'] as List<String>) {
          await _searchHistoryBox.add(query);
        }
      }
    } catch (e) {
      throw Exception('Failed to import user data: $e');
    }
  }
}
