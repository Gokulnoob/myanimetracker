import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'service_providers.dart';

// Anime List State
class AnimeListState {
  final List<Anime> anime;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const AnimeListState({
    this.anime = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  AnimeListState copyWith({
    List<Anime>? anime,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return AnimeListState(
      anime: anime ?? this.anime,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Anime List Notifier
class AnimeListNotifier extends StateNotifier<AnimeListState> {
  final JikanApiService _apiService;
  final String _listType;

  AnimeListNotifier(this._apiService, this._listType)
      : super(const AnimeListState());

  Future<void> loadAnime({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = const AnimeListState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      ApiResponse<List<Anime>> response;

      switch (_listType) {
        case 'top':
        case 'trending':
          response = await _apiService.getTopAnime(page: state.currentPage);
          break;
        case 'seasonal':
          response =
              await _apiService.getSeasonalAnime(page: state.currentPage);
          break;
        default:
          response = await _apiService.getTopAnime(page: state.currentPage);
      }

      if (response.isSuccess && response.data != null) {
        final newAnime = response.data!;

        // Cache anime locally
        await HiveService.saveAnimeList(newAnime);

        final allAnime = refresh ? newAnime : [...state.anime, ...newAnime];

        state = state.copyWith(
          anime: allAnime,
          isLoading: false,
          hasMore: response.pagination?.hasNextPage ?? false,
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Failed to load anime',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadAnime();
  }

  Future<void> refresh() async {
    await loadAnime(refresh: true);
  }
}

// Top Anime Provider
final topAnimeProvider =
    StateNotifierProvider<AnimeListNotifier, AnimeListState>((ref) {
  final apiService = ref.watch(jikanApiServiceProvider);
  return AnimeListNotifier(apiService, 'top');
});

// Seasonal Anime Provider
final seasonalAnimeProvider =
    StateNotifierProvider<AnimeListNotifier, AnimeListState>((ref) {
  final apiService = ref.watch(jikanApiServiceProvider);
  return AnimeListNotifier(apiService, 'seasonal');
});

// Trending Anime Provider (same as top but can be customized)
final trendingAnimeProvider =
    StateNotifierProvider<AnimeListNotifier, AnimeListState>((ref) {
  final apiService = ref.watch(jikanApiServiceProvider);
  return AnimeListNotifier(apiService, 'trending');
});
