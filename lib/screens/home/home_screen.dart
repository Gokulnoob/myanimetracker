import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/services/services.dart';
import '../../widgets/widgets.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../details/anime_details_screen.dart';
import '../search/full_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(topAnimeProvider.notifier).loadAnime(refresh: true);
      ref.read(seasonalAnimeProvider.notifier).loadAnime(refresh: true);
      ref.read(trendingAnimeProvider.notifier).loadAnime(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userStats = ref.watch(userStatisticsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(topAnimeProvider.notifier).refresh(),
            ref.read(seasonalAnimeProvider.notifier).refresh(),
            ref.read(trendingAnimeProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'MyAnimeFinder',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // Navigate to search screen
                    DefaultTabController.of(context).animateTo(1);
                  },
                ),
              ],
            ),

            // Quick Stats Card
            if (userStats.totalAnime > 0)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: _buildStatsCard(context, userStats),
                ),
              ),

            // Continue Watching Section
            _buildContinueWatchingSection(),

            // Trending Anime Section
            _buildAnimeSection(
              'Trending Now',
              trendingAnimeProvider,
              Icons.trending_up,
              FullListType.trending,
            ),

            // Seasonal Anime Section
            _buildAnimeSection(
              'This Season',
              seasonalAnimeProvider,
              Icons.calendar_today,
              FullListType.seasonal,
            ),

            // Top Rated Section
            _buildAnimeSection(
              'Top Rated',
              topAnimeProvider,
              Icons.star,
              FullListType.topRated,
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, UserStatistics stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Anime',
                    stats.totalAnime.toString(),
                    Icons.tv,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed',
                    stats.completed.toString(),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Watching',
                    stats.watching.toString(),
                    Icons.play_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Time Spent',
                    stats.timeWatched,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    final watchingList = ref.watch(watchingListProvider);

    if (watchingList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continue Watching',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: watchingList.length,
              itemBuilder: (context, index) {
                final entry = watchingList[index];
                final anime = HiveService.getAnime(entry.animeId);

                if (anime == null) return const SizedBox.shrink();

                return Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimeCard(
                    anime: anime,
                    showProgressBar: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        AnimeDetailsScreen.route(anime),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeSection(
    String title,
    StateNotifierProvider<AnimeListNotifier, AnimeListState> provider,
    IconData icon,
    FullListType listType,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final animeState = ref.watch(provider);

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FullListScreen.route(listType, title),
                        );
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              if (animeState.isLoading && animeState.anime.isEmpty)
                const SizedBox(
                  height: 280,
                  child: LoadingWidget(showShimmer: true),
                )
              else if (animeState.error != null && animeState.anime.isEmpty)
                SizedBox(
                  height: 200,
                  child: custom.ErrorWidget(
                    message: animeState.error!,
                    onRetry: () => ref.read(provider.notifier).refresh(),
                  ),
                )
              else
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: animeState.anime.length.clamp(0, 10),
                    itemBuilder: (context, index) {
                      final anime = animeState.anime[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimeCard(
                          anime: anime,
                          onTap: () {
                            Navigator.push(
                              context,
                              AnimeDetailsScreen.route(anime),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
