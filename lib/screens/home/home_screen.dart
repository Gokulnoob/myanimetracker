import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

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
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Beautiful App Bar with gradient
            _buildSliverAppBar(context, colorScheme),

            // Welcome Card
            _buildWelcomeCard(context, colorScheme),

            // Quick Stats Card
            if (userStats.totalAnime > 0)
              SliverToBoxAdapter(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildStatsCard(context, userStats, colorScheme),
                ),
              ),

            // Continue Watching Section
            _buildContinueWatchingSection(context, colorScheme),

            // Trending Anime Section
            _buildAnimeSection(
              context,
              'Trending Now',
              trendingAnimeProvider,
              Icons.trending_up_rounded,
              FullListType.trending,
              colorScheme.primary,
            ),

            // Seasonal Anime Section
            _buildAnimeSection(
              context,
              'This Season',
              seasonalAnimeProvider,
              Icons.calendar_today_rounded,
              FullListType.seasonal,
              colorScheme.secondary,
            ),

            // Top Rated Section
            _buildAnimeSection(
              context,
              'Top Rated',
              topAnimeProvider,
              Icons.star_rounded,
              FullListType.topRated,
              colorScheme.tertiary,
            ),

            // Bottom padding for navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar.large(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      stretch: true,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'MyAnimeFinder',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.3),
                colorScheme.secondaryContainer.withValues(alpha: 0.3),
                colorScheme.tertiaryContainer.withValues(alpha: 0.2),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                top: 60,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            // Navigate to search screen
            DefaultTabController.of(context).animateTo(1);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context, ColorScheme colorScheme) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 18
            ? 'Good Afternoon'
            : 'Good Evening';

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to discover amazing anime?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      BuildContext context, UserStatistics stats, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: colorScheme.onSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    colorScheme,
                    'Total',
                    stats.totalAnime.toString(),
                    Icons.tv_rounded,
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    colorScheme,
                    'Completed',
                    stats.completed.toString(),
                    Icons.check_circle_rounded,
                    colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    colorScheme,
                    'Watching',
                    stats.watching.toString(),
                    Icons.play_circle_rounded,
                    colorScheme.tertiary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    colorScheme,
                    'Time',
                    stats.timeWatched,
                    Icons.schedule_rounded,
                    colorScheme.outline,
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
    BuildContext context,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection(
      BuildContext context, ColorScheme colorScheme) {
    final watchingList = ref.watch(watchingListProvider);

    if (watchingList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: _buildSectionHeader(
              context,
              'Continue Watching',
              Icons.play_circle_outline_rounded,
              colorScheme.primary,
              null,
            ),
          ),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: watchingList.length,
              itemBuilder: (context, index) {
                final entry = watchingList[index];
                final anime = HiveService.getAnime(entry.animeId);

                if (anime == null) return const SizedBox.shrink();

                return Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimeCard(
                    anime: anime,
                    showProgressBar: true,
                    heroContext: 'continue-watching',
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
    BuildContext context,
    String title,
    StateNotifierProvider<AnimeListNotifier, AnimeListState> provider,
    IconData icon,
    FullListType listType,
    Color accentColor,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final animeState = ref.watch(provider);

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                child: _buildSectionHeader(
                  context,
                  title,
                  icon,
                  accentColor,
                  () {
                    Navigator.push(
                      context,
                      FullListScreen.route(listType, title),
                    );
                  },
                ),
              ),
              if (animeState.isLoading && animeState.anime.isEmpty)
                const SizedBox(
                  height: 320,
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
                  height: 340, // Increased from 320 to prevent overflow
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: animeState.anime.length.clamp(0, 10),
                    itemBuilder: (context, index) {
                      final anime = animeState.anime[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          transitionDuration: const Duration(milliseconds: 500),
                          closedBuilder: (context, openContainer) => AnimeCard(
                            anime: anime,
                            onTap: openContainer,
                            heroContext: listType.name,
                          ),
                          openBuilder: (context, closeContainer) =>
                              AnimeDetailsScreen(anime: anime),
                          closedElevation: 0,
                          openElevation: 0,
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    VoidCallback? onSeeAll,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
        ),
        if (onSeeAll != null)
          FilledButton.tonal(
            onPressed: onSeeAll,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
