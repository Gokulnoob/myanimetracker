import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'service_providers.dart';

// Search State
class SearchState {
  final List<Anime> results;
  final bool isLoading;
  final String? error;
  final SearchFilters filters;
  final List<String> searchHistory;
  final bool hasMore;
  final int currentPage;

  SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    SearchFilters? filters,
    this.searchHistory = const [],
    this.hasMore = true,
    this.currentPage = 1,
  }) : filters = filters ?? SearchFilters();

  SearchState copyWith({
    List<Anime>? results,
    bool? isLoading,
    String? error,
    SearchFilters? filters,
    List<String>? searchHistory,
    bool? hasMore,
    int? currentPage,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      searchHistory: searchHistory ?? this.searchHistory,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Search Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final JikanApiService _apiService;

  SearchNotifier(this._apiService) : super(SearchState()) {
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    final history = HiveService.getSearchHistory();
    state = state.copyWith(searchHistory: history);
  }

  Future<void> search({
    String? query,
    SearchFilters? filters,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    final searchFilters = filters ?? state.filters;
    final searchQuery = query ?? searchFilters.query;

    // Update filters with the query if provided
    final updatedFilters = searchQuery != null && searchQuery.isNotEmpty
        ? searchFilters.copyWith(query: searchQuery)
        : searchFilters;

    if (refresh) {
      state = SearchState(
        isLoading: true,
        filters: updatedFilters,
        searchHistory: state.searchHistory,
      );
    } else {
      state =
          state.copyWith(isLoading: true, error: null, filters: updatedFilters);
    }

    try {
      // Add to search history if query is provided
      if (searchQuery?.isNotEmpty == true) {
        await HiveService.addSearchHistory(searchQuery!);
        _loadSearchHistory();
      }

      // Always use API search for complete results
      final response = await _apiService.searchAnime(
        filters: updatedFilters,
        page: refresh ? 1 : state.currentPage,
      );

      if (response.isSuccess && response.data != null) {
        final newResults = response.data!;

        // Cache results locally
        await HiveService.saveAnimeList(newResults);

        final allResults =
            refresh ? newResults : [...state.results, ...newResults];

        state = state.copyWith(
          results: allResults,
          isLoading: false,
          filters: updatedFilters,
          hasMore: response.pagination?.hasNextPage ?? false,
          currentPage: refresh ? 2 : state.currentPage + 1,
        );
      } else {
        // If API search fails, fallback to local search for basic queries
        if (searchQuery?.isNotEmpty == true && searchFilters.query != null) {
          final localResults = HiveService.searchAnimeLocally(searchQuery!);
          if (localResults.isNotEmpty) {
            state = state.copyWith(
              results: localResults,
              isLoading: false,
              hasMore: false,
              currentPage: 1,
              error: 'Showing cached results (limited)',
            );
            return;
          }
        }

        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Search failed',
        );
      }
    } catch (e) {
      // On network error, try local search as fallback
      if (searchQuery?.isNotEmpty == true) {
        final localResults = HiveService.searchAnimeLocally(searchQuery!);
        if (localResults.isNotEmpty) {
          state = state.copyWith(
            results: localResults,
            isLoading: false,
            hasMore: false,
            currentPage: 1,
            error: 'Showing cached results (network error)',
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await search();
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void clearSearch() {
    state = state.copyWith(
      results: [],
      error: null,
      hasMore: true,
      currentPage: 1,
    );
  }

  Future<void> clearSearchHistory() async {
    await HiveService.clearSearchHistory();
    state = state.copyWith(searchHistory: []);
  }

  Future<void> removeFromHistory(String query) async {
    await HiveService.removeSearchHistory(query);
    _loadSearchHistory();
  }
}

// Search Provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final apiService = ref.watch(jikanApiServiceProvider);
  return SearchNotifier(apiService);
});

// Quick search provider for instant local results
final localSearchProvider = Provider.family<List<Anime>, String>((ref, query) {
  if (query.isEmpty) return [];
  return HiveService.searchAnimeLocally(query).take(10).toList();
});
