import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../details/anime_details_screen.dart';

enum FullListType {
  trending,
  seasonal,
  topRated,
}

class FullListScreen extends ConsumerStatefulWidget {
  final FullListType listType;
  final String title;

  const FullListScreen({
    super.key,
    required this.listType,
    required this.title,
  });

  static Route<void> route(FullListType listType, String title) {
    return MaterialPageRoute(
      builder: (_) => FullListScreen(
        listType: listType,
        title: title,
      ),
    );
  }

  @override
  ConsumerState<FullListScreen> createState() => _FullListScreenState();
}

class _FullListScreenState extends ConsumerState<FullListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load data for the specific list type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    switch (widget.listType) {
      case FullListType.trending:
        ref.read(trendingAnimeProvider.notifier).loadAnime(refresh: true);
        break;
      case FullListType.seasonal:
        ref.read(seasonalAnimeProvider.notifier).loadAnime(refresh: true);
        break;
      case FullListType.topRated:
        ref.read(topAnimeProvider.notifier).loadAnime(refresh: true);
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    switch (widget.listType) {
      case FullListType.trending:
        ref.read(trendingAnimeProvider.notifier).loadMore();
        break;
      case FullListType.seasonal:
        ref.read(seasonalAnimeProvider.notifier).loadMore();
        break;
      case FullListType.topRated:
        ref.read(topAnimeProvider.notifier).loadMore();
        break;
    }
  }

  StateNotifierProvider<AnimeListNotifier, AnimeListState> _getProvider() {
    switch (widget.listType) {
      case FullListType.trending:
        return trendingAnimeProvider;
      case FullListType.seasonal:
        return seasonalAnimeProvider;
      case FullListType.topRated:
        return topAnimeProvider;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _getProvider();
    final animeState = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(provider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildContent(animeState, provider),
    );
  }

  Widget _buildContent(AnimeListState animeState,
      StateNotifierProvider<AnimeListNotifier, AnimeListState> provider) {
    // Loading state (first load)
    if (animeState.isLoading && animeState.anime.isEmpty) {
      return const LoadingWidget(
        showShimmer: true,
        message: 'Loading anime...',
      );
    }

    // Error state
    if (animeState.error != null && animeState.anime.isEmpty) {
      return custom.ErrorWidget(
        message: animeState.error!,
        onRetry: () => ref.read(provider.notifier).refresh(),
      );
    }

    // No results
    if (animeState.anime.isEmpty && !animeState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Anime Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try refreshing the page',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(provider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Results found
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(provider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${animeState.anime.length} anime found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const Spacer(),
                  if (animeState.hasMore)
                    Text(
                      'Scroll for more',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                ],
              ),
            ),
          ),

          // Results grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: _getCrossAxisCount(context),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: animeState.anime.length,
              itemBuilder: (context, index) {
                final anime = animeState.anime[index];
                return AnimeCard(
                  anime: anime,
                  onTap: () {
                    Navigator.push(
                      context,
                      AnimeDetailsScreen.route(anime),
                    );
                  },
                );
              },
            ),
          ),

          // Loading more indicator
          if (animeState.isLoading && animeState.anime.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // End of list indicator
          if (!animeState.hasMore && animeState.anime.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'You\'ve reached the end!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }
}
