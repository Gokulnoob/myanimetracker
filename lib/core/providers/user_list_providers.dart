import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

// User Anime Lists State
class UserAnimeListsState {
  final Map<WatchStatus, List<UserAnimeEntry>> lists;
  final bool isLoading;
  final String? error;

  UserAnimeListsState({
    this.lists = const {},
    this.isLoading = false,
    this.error,
  });

  UserAnimeListsState copyWith({
    Map<WatchStatus, List<UserAnimeEntry>>? lists,
    bool? isLoading,
    String? error,
  }) {
    return UserAnimeListsState(
      lists: lists ?? this.lists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<UserAnimeEntry> getListByStatus(WatchStatus status) {
    return lists[status] ?? [];
  }

  int get totalAnime => lists.values.fold(0, (sum, list) => sum + list.length);
}

// User Anime Lists Notifier
class UserAnimeListsNotifier extends StateNotifier<UserAnimeListsState> {
  UserAnimeListsNotifier() : super(UserAnimeListsState()) {
    loadUserLists();
  }

  void loadUserLists() {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Map<WatchStatus, List<UserAnimeEntry>> lists = {};

      for (final status in WatchStatus.values) {
        lists[status] = HiveService.getUserAnimeByStatus(status);
      }

      state = state.copyWith(lists: lists, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user lists: $e',
      );
    }
  }

  Future<void> addAnimeToList(int animeId, WatchStatus status,
      {int? totalEpisodes}) async {
    try {
      final entry = UserAnimeEntry.create(
        animeId: animeId,
        status: status,
        totalEpisodes: totalEpisodes,
      );

      await HiveService.saveUserAnimeEntry(entry);
      loadUserLists(); // Refresh the lists
    } catch (e) {
      state = state.copyWith(error: 'Failed to add anime to list: $e');
    }
  }

  Future<void> updateAnimeStatus(int animeId, WatchStatus newStatus) async {
    try {
      final entry = HiveService.getUserAnimeEntry(animeId);
      if (entry != null) {
        entry.updateStatus(newStatus);
        await HiveService.saveUserAnimeEntry(entry);
        loadUserLists(); // Refresh the lists
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update anime status: $e');
    }
  }

  Future<void> updateProgress(int animeId, int episodesWatched) async {
    try {
      final entry = HiveService.getUserAnimeEntry(animeId);
      if (entry != null) {
        entry.updateProgress(episodesWatched);
        await HiveService.saveUserAnimeEntry(entry);
        loadUserLists(); // Refresh the lists
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update progress: $e');
    }
  }

  Future<void> updateScore(int animeId, double? score) async {
    try {
      final entry = HiveService.getUserAnimeEntry(animeId);
      if (entry != null) {
        entry.updateScore(score);
        await HiveService.saveUserAnimeEntry(entry);
        loadUserLists(); // Refresh the lists
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update score: $e');
    }
  }

  Future<void> updateNotes(int animeId, String? notes) async {
    try {
      final entry = HiveService.getUserAnimeEntry(animeId);
      if (entry != null) {
        entry.updateNotes(notes);
        await HiveService.saveUserAnimeEntry(entry);
        loadUserLists(); // Refresh the lists
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update notes: $e');
    }
  }

  Future<void> toggleFavorite(int animeId) async {
    try {
      final entry = HiveService.getUserAnimeEntry(animeId);
      if (entry != null) {
        entry.toggleFavorite();
        await HiveService.saveUserAnimeEntry(entry);
        loadUserLists(); // Refresh the lists
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle favorite: $e');
    }
  }

  Future<void> removeAnime(int animeId) async {
    try {
      await HiveService.removeUserAnimeEntry(animeId);
      loadUserLists(); // Refresh the lists
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove anime: $e');
    }
  }

  List<UserAnimeEntry> getFavorites() {
    return HiveService.getFavoriteAnime();
  }
}

// User Anime Lists Provider
final userAnimeListsProvider =
    StateNotifierProvider<UserAnimeListsNotifier, UserAnimeListsState>((ref) {
  return UserAnimeListsNotifier();
});

// Individual list providers for convenience
final watchingListProvider = Provider<List<UserAnimeEntry>>((ref) {
  final state = ref.watch(userAnimeListsProvider);
  return state.getListByStatus(WatchStatus.watching);
});

final completedListProvider = Provider<List<UserAnimeEntry>>((ref) {
  final state = ref.watch(userAnimeListsProvider);
  return state.getListByStatus(WatchStatus.completed);
});

final planToWatchListProvider = Provider<List<UserAnimeEntry>>((ref) {
  final state = ref.watch(userAnimeListsProvider);
  return state.getListByStatus(WatchStatus.planToWatch);
});

final onHoldListProvider = Provider<List<UserAnimeEntry>>((ref) {
  final state = ref.watch(userAnimeListsProvider);
  return state.getListByStatus(WatchStatus.onHold);
});

final droppedListProvider = Provider<List<UserAnimeEntry>>((ref) {
  final state = ref.watch(userAnimeListsProvider);
  return state.getListByStatus(WatchStatus.dropped);
});

final favoritesListProvider = Provider<List<UserAnimeEntry>>((ref) {
  final notifier = ref.watch(userAnimeListsProvider.notifier);
  return notifier.getFavorites();
});

// Check if anime is in user's list
final animeInListProvider =
    Provider.family<UserAnimeEntry?, int>((ref, animeId) {
  return HiveService.getUserAnimeEntry(animeId);
});
