import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/services/services.dart';
import '../../core/utils/overflow_utils.dart';
import '../details/anime_details_screen.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;

class MyListsScreen extends ConsumerStatefulWidget {
  const MyListsScreen({super.key});

  @override
  ConsumerState<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends ConsumerState<MyListsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  ListSortType _sortType = ListSortType.dateAdded;
  bool _sortAscending = false;
  String _searchQuery = '';

  final List<WatchStatus> _tabs = [
    WatchStatus.watching,
    WatchStatus.completed,
    WatchStatus.planToWatch,
    WatchStatus.onHold,
    WatchStatus.dropped,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Tab changed, could trigger refresh if needed
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userListsState = ref.watch(userAnimeListsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and actions
            _buildHeader(),

            // Tab bar
            _buildTabBar(),

            // Search and filter bar
            _buildSearchAndFilters(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((status) {
                  return _buildListContent(status, userListsState);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'My Lists',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final userListsState = ref.watch(userAnimeListsProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: _tabs.map((status) {
          final count = userListsState.getListByStatus(status).length;
          return Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.shortName,
                  style: const TextStyle(fontSize: 14),
                ),
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search your anime...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Sort options
          Row(
            children: [
              Icon(
                Icons.sort,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Sort by:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<ListSortType>(
                  value: _sortType,
                  isDense: true,
                  underline: Container(),
                  items: ListSortType.values.map((sortType) {
                    return DropdownMenuItem(
                      value: sortType,
                      child: Text(sortType.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortType = value;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                tooltip: _sortAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(
      WatchStatus status, UserAnimeListsState userListsState) {
    if (userListsState.isLoading) {
      return const LoadingWidget(
        showShimmer: true,
        message: 'Loading your anime lists...',
      );
    }

    if (userListsState.error != null) {
      return Center(
        child: custom.ErrorWidget(
          message: userListsState.error!,
          onRetry: () {
            ref.read(userAnimeListsProvider.notifier).loadUserLists();
          },
        ),
      );
    }

    List<UserAnimeEntry> entries = userListsState.getListByStatus(status);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      entries = entries.where((entry) {
        // We would need to get the anime data to search by title
        // For now, this is a placeholder
        return true; // TODO: Implement anime title search
      }).toList();
    }

    // Apply sorting
    entries = _sortEntries(entries);

    if (entries.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(userAnimeListsProvider.notifier).loadUserLists();
      },
      child: CustomScrollView(
        slivers: [
          // List stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildListStats(entries, status),
            ),
          ),

          // Anime grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: OverflowUtils.getResponsiveGridCount(
                context,
                itemWidth: 300.0, // Card width for list items
                minCount: 1,
                maxCount: 3,
              ),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildAnimeEntryCard(entry);
              },
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

  Widget _buildListStats(List<UserAnimeEntry> entries, WatchStatus status) {
    final totalEpisodes = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.episodesWatched,
    );

    final avgScore = entries.where((e) => e.personalScore != null).isNotEmpty
        ? entries
                .where((e) => e.personalScore != null)
                .map((e) => e.personalScore!)
                .reduce((a, b) => a + b) /
            entries.where((e) => e.personalScore != null).length
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${status.displayName} Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Anime',
                    entries.length.toString(),
                    Icons.library_books,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Episodes',
                    totalEpisodes.toString(),
                    Icons.play_circle_outline,
                  ),
                ),
                if (avgScore > 0)
                  Expanded(
                    child: _buildStatItem(
                      'Avg Score',
                      avgScore.toStringAsFixed(1),
                      Icons.star_outline,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  Widget _buildAnimeEntryCard(UserAnimeEntry entry) {
    return FutureBuilder<Anime?>(
      future: _getAnimeData(entry.animeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final anime = snapshot.data;
        if (anime == null) {
          return const SizedBox.shrink();
        }

        return _buildDetailedEntryCard(anime, entry);
      },
    );
  }

  Widget _buildDetailedEntryCard(Anime anime, UserAnimeEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            AnimeDetailsScreen.route(anime),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Anime Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: Image.network(
                    anime.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    anime.displayTitle.toSafeText(
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 4),

                    // Status and Type
                    [
                      _buildStatusChip(entry.status),
                      if (anime.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: anime.type!.toSafeText(
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                          ),
                        ),
                    ].toFlexibleRow(spacing: 8.0),

                    const SizedBox(height: 8),

                    // Progress Information
                    if (anime.episodes != null) ...[
                      [
                        const Icon(Icons.play_circle_outline, size: 16),
                        '${entry.episodesWatched}/${anime.episodes} episodes'
                            .toSafeText(
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                        ),
                      ].toFlexibleRow(spacing: 4.0),

                      const SizedBox(height: 4),

                      // Progress Bar
                      LinearProgressIndicator(
                        value: anime.episodes! > 0
                            ? entry.episodesWatched / anime.episodes!
                            : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(entry.status),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Score and Rating
                    [
                      if (entry.personalScore != null) ...[
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        '${entry.personalScore!.toStringAsFixed(1)}/10'
                            .toSafeText(
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                        ),
                      ],
                      if (anime.score != null) ...[
                        const Icon(Icons.public, size: 16, color: Colors.blue),
                        anime.score!.toStringAsFixed(1).toSafeText(
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                            ),
                      ],
                    ].toFlexibleRow(spacing: 4.0),

                    // Transaction Details
                    const SizedBox(height: 8),
                    _buildTransactionDetails(entry),
                  ],
                ),
              ),

              // Actions
              OverflowUtils.constrainedContainer(
                maxWidth: 48, // Fixed width to prevent overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.isFavorite)
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (action) {
                        switch (action) {
                          case 'edit':
                            _showEditDialog(entry, anime);
                            break;
                          case 'quick_status':
                            _showQuickStatusMenu(entry, anime);
                            break;
                          case 'remove':
                            _removeFromList(entry);
                            break;
                          case 'favorite':
                            _toggleFavorite(entry);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'quick_status',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz),
                              SizedBox(width: 8),
                              Text('Change Status'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'favorite',
                          child: [
                            Icon(entry.isFavorite
                                ? Icons.favorite_border
                                : Icons.favorite),
                            (entry.isFavorite
                                    ? 'Remove from Favorites'
                                    : 'Add to Favorites')
                                .toSafeText(maxLines: 1),
                          ].toFlexibleRow(spacing: 8.0),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Remove'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(WatchStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildTransactionDetails(UserAnimeEntry entry) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Information
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Added: ${_formatDate(entry.dateAdded)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ),

          if (entry.dateStarted != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.play_arrow, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Started: ${_formatDate(entry.dateStarted!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
          ],

          if (entry.dateCompleted != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Completed: ${_formatDate(entry.dateCompleted!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
          ],

          // Notes Preview
          if (entry.personalNotes?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.note, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    entry.personalNotes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return Colors.blue;
      case WatchStatus.completed:
        return Colors.green;
      case WatchStatus.planToWatch:
        return Colors.grey;
      case WatchStatus.onHold:
        return Colors.orange;
      case WatchStatus.dropped:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return Icons.play_circle;
      case WatchStatus.completed:
        return Icons.check_circle;
      case WatchStatus.planToWatch:
        return Icons.bookmark;
      case WatchStatus.onHold:
        return Icons.pause_circle;
      case WatchStatus.dropped:
        return Icons.stop_circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).round()} months ago';
    } else {
      return '${(difference.inDays / 365).round()} years ago';
    }
  }

  void _removeFromList(UserAnimeEntry entry) {
    ref.read(userAnimeListsProvider.notifier).removeAnime(entry.animeId);
  }

  void _toggleFavorite(UserAnimeEntry entry) {
    ref.read(userAnimeListsProvider.notifier).toggleFavorite(entry.animeId);
  }

  Widget _buildEmptyState(WatchStatus status) {
    String message;
    String suggestion;
    IconData icon;

    switch (status) {
      case WatchStatus.watching:
        message = 'No anime currently watching';
        suggestion = 'Add some anime you\'re watching to track your progress!';
        icon = Icons.play_circle_outline;
        break;
      case WatchStatus.completed:
        message = 'No completed anime';
        suggestion = 'Mark anime as completed to see them here!';
        icon = Icons.check_circle_outline;
        break;
      case WatchStatus.planToWatch:
        message = 'No planned anime';
        suggestion = 'Add anime you want to watch to your plan to watch list!';
        icon = Icons.bookmark_outline;
        break;
      case WatchStatus.onHold:
        message = 'No anime on hold';
        suggestion = 'Anime you\'ve paused will appear here!';
        icon = Icons.pause_circle_outline;
        break;
      case WatchStatus.dropped:
        message = 'No dropped anime';
        suggestion = 'Anime you\'ve dropped will appear here!';
        icon = Icons.stop_circle_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to search screen
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Anime'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to search screen
        DefaultTabController.of(context).animateTo(1);
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Anime'),
    );
  }

  List<UserAnimeEntry> _sortEntries(List<UserAnimeEntry> entries) {
    final sortedEntries = List<UserAnimeEntry>.from(entries);

    sortedEntries.sort((a, b) {
      int comparison;

      switch (_sortType) {
        case ListSortType.dateAdded:
          comparison = a.dateAdded.compareTo(b.dateAdded);
          break;
        case ListSortType.dateModified:
          comparison = a.lastModified.compareTo(b.lastModified);
          break;
        case ListSortType.score:
          final aScore = a.personalScore ?? 0;
          final bScore = b.personalScore ?? 0;
          comparison = aScore.compareTo(bScore);
          break;
        case ListSortType.progress:
          comparison = a.progressPercentage.compareTo(b.progressPercentage);
          break;
        case ListSortType.title:
          // Would need anime data to sort by title
          comparison = a.animeId.compareTo(b.animeId);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedEntries;
  }

  Future<Anime?> _getAnimeData(int animeId) async {
    // Try to get from local cache first
    final cachedAnime = HiveService.getAnime(animeId);
    if (cachedAnime != null) {
      return cachedAnime;
    }

    // If not cached, you could fetch from API
    // For now, return null
    return null;
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Export Lists'),
              onTap: () {
                Navigator.pop(context);
                _exportLists();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Import Lists'),
              onTap: () {
                Navigator.pop(context);
                _importLists();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync with MAL'),
              onTap: () {
                Navigator.pop(context);
                _syncWithMAL();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear All Lists'),
              onTap: () {
                Navigator.pop(context);
                _showClearConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportLists() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }

  void _importLists() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import functionality coming soon!'),
      ),
    );
  }

  void _syncWithMAL() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('MAL sync functionality coming soon!'),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Lists'),
        content: const Text(
          'Are you sure you want to clear all your anime lists? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllLists();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _clearAllLists() {
    // Implementation would clear all user lists
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All lists cleared'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showQuickStatusMenu(UserAnimeEntry entry, Anime anime) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 40,
                    height: 56,
                    child: Image.network(
                      anime.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      anime.displayTitle.toSafeText(
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                      ),
                      'Current: ${entry.status.displayName}'.toSafeText(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            'Change Status To:'.toSafeText(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            ...WatchStatus.values.where((status) => status != entry.status).map(
                  (status) => ListTile(
                    leading: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                    ),
                    title: status.displayName.toSafeText(maxLines: 1),
                    subtitle: _getStatusDescription(status).toSafeText(
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmQuickStatusChange(entry, anime, status);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _confirmQuickStatusChange(
      UserAnimeEntry entry, Anime anime, WatchStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move "${anime.displayTitle}" to ${newStatus.displayName}?'),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_getStatusIcon(entry.status),
                    size: 16, color: _getStatusColor(entry.status)),
                const SizedBox(width: 4),
                Text(entry.status.displayName),
                const Icon(Icons.arrow_forward, size: 16),
                Icon(_getStatusIcon(newStatus),
                    size: 16, color: _getStatusColor(newStatus)),
                const SizedBox(width: 4),
                Text(newStatus.displayName),
              ],
            ),
            if (newStatus == WatchStatus.completed &&
                anime.episodes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Episodes will be set to ${anime.episodes}/${anime.episodes}',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _quickUpdateStatus(entry, anime, newStatus);
            },
            child: const Text('Move'),
          ),
        ],
      ),
    );
  }

  void _quickUpdateStatus(
      UserAnimeEntry entry, Anime anime, WatchStatus newStatus) {
    final oldStatus = entry.status.displayName;
    final newStatusName = newStatus.displayName;

    // Update the status
    ref.read(userAnimeListsProvider.notifier).updateAnimeStatus(
          entry.animeId,
          newStatus,
        );

    // Auto-complete episodes if status changed to completed
    if (newStatus == WatchStatus.completed && anime.episodes != null) {
      ref.read(userAnimeListsProvider.notifier).updateProgress(
            entry.animeId,
            anime.episodes!,
          );
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Moved "${anime.displayTitle}" from $oldStatus to $newStatusName'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Switch to the tab where the anime was moved
            final targetIndex = _tabs.indexOf(newStatus);
            if (targetIndex != -1) {
              _tabController.animateTo(targetIndex);
            }
          },
        ),
      ),
    );
  }

  String _getStatusDescription(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return 'Currently watching this anime';
      case WatchStatus.completed:
        return 'Finished watching';
      case WatchStatus.planToWatch:
        return 'Want to watch later';
      case WatchStatus.onHold:
        return 'Paused watching';
      case WatchStatus.dropped:
        return 'Stopped watching';
    }
  }

  void _showEditDialog(UserAnimeEntry entry, Anime anime) {
    showDialog(
      context: context,
      builder: (context) => _EditAnimeDialog(
        entry: entry,
        anime: anime,
        onSave: (updatedEntry) {
          // This will automatically move the anime to the correct list
          ref.read(userAnimeListsProvider.notifier).updateAnimeStatus(
                entry.animeId,
                updatedEntry.status,
              );

          // Update other fields if changed
          if (updatedEntry.episodesWatched != entry.episodesWatched) {
            ref.read(userAnimeListsProvider.notifier).updateProgress(
                  entry.animeId,
                  updatedEntry.episodesWatched,
                );
          }

          if (updatedEntry.personalScore != entry.personalScore) {
            ref.read(userAnimeListsProvider.notifier).updateScore(
                  entry.animeId,
                  updatedEntry.personalScore,
                );
          }

          if (updatedEntry.personalNotes != entry.personalNotes) {
            ref.read(userAnimeListsProvider.notifier).updateNotes(
                  entry.animeId,
                  updatedEntry.personalNotes,
                );
          }

          // Show confirmation message with status change info
          final oldStatus = entry.status.displayName;
          final newStatus = updatedEntry.status.displayName;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                oldStatus != newStatus
                    ? 'Anime moved from $oldStatus to $newStatus'
                    : 'Anime updated successfully',
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  // Switch to the tab where the anime was moved
                  final targetIndex = _tabs.indexOf(updatedEntry.status);
                  if (targetIndex != -1) {
                    _tabController.animateTo(targetIndex);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Edit Anime Dialog Widget
class _EditAnimeDialog extends StatefulWidget {
  final UserAnimeEntry entry;
  final Anime anime;
  final Function(UserAnimeEntry) onSave;

  const _EditAnimeDialog({
    required this.entry,
    required this.anime,
    required this.onSave,
  });

  @override
  State<_EditAnimeDialog> createState() => _EditAnimeDialogState();
}

class _EditAnimeDialogState extends State<_EditAnimeDialog> {
  late WatchStatus _selectedStatus;
  late int _episodesWatched;
  late double? _personalScore;
  late String? _personalNotes;
  late TextEditingController _notesController;
  late TextEditingController _episodesController;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.entry.status;
    _episodesWatched = widget.entry.episodesWatched;
    _personalScore = widget.entry.personalScore;
    _personalNotes = widget.entry.personalNotes;
    _notesController = TextEditingController(text: _personalNotes ?? '');
    _episodesController =
        TextEditingController(text: _episodesWatched.toString());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _episodesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit),
          const SizedBox(width: 8),
          Expanded(
            child: widget.anime.displayTitle.toSafeText(
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 2,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Selection
            'Status'.toSafeText(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WatchStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: WatchStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      status.displayName.toSafeText(maxLines: 1),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                    // Auto-complete episodes if status changed to completed
                    if (value == WatchStatus.completed &&
                        widget.anime.episodes != null) {
                      _episodesWatched = widget.anime.episodes!;
                      _episodesController.text = _episodesWatched.toString();
                    }
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Episodes Watched
            if (widget.anime.episodes != null) ...[
              'Episodes Watched'.toSafeText(
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _episodesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Episodes',
                        suffixText: '/ ${widget.anime.episodes}',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        final episodes = int.tryParse(value) ?? 0;
                        setState(() {
                          _episodesWatched =
                              episodes.clamp(0, widget.anime.episodes!);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _episodesWatched = widget.anime.episodes!;
                        _episodesController.text = _episodesWatched.toString();
                        _selectedStatus = WatchStatus.completed;
                      });
                    },
                    icon: const Icon(Icons.done_all),
                    tooltip: 'Mark as completed',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Personal Score
            'Personal Score'.toSafeText(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _personalScore ?? 0.0,
                    min: 0.0,
                    max: 10.0,
                    divisions: 20,
                    label: _personalScore?.toStringAsFixed(1) ?? 'No rating',
                    onChanged: (value) {
                      setState(() {
                        _personalScore = value > 0 ? value : null;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child:
                      (_personalScore?.toStringAsFixed(1) ?? '0.0').toSafeText(
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _personalScore = null;
                });
              },
              child: 'Clear Rating'.toSafeText(maxLines: 1),
            ),

            const SizedBox(height: 16),

            // Personal Notes
            'Personal Notes'.toSafeText(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add your thoughts about this anime...',
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 3,
              onChanged: (value) {
                _personalNotes = value.isNotEmpty ? value : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: 'Cancel'.toSafeText(maxLines: 1),
        ),
        ElevatedButton(
          onPressed: () {
            // Create updated entry
            final updatedEntry = UserAnimeEntry(
              animeId: widget.entry.animeId,
              status: _selectedStatus,
              episodesWatched: _episodesWatched,
              totalEpisodes: widget.entry.totalEpisodes,
              personalScore: _personalScore,
              personalNotes: _personalNotes,
              dateAdded: widget.entry.dateAdded,
              dateStarted: _selectedStatus == WatchStatus.watching &&
                      widget.entry.dateStarted == null
                  ? DateTime.now()
                  : widget.entry.dateStarted,
              dateCompleted: _selectedStatus == WatchStatus.completed
                  ? DateTime.now()
                  : null,
              lastModified: DateTime.now(),
              isFavorite: widget.entry.isFavorite,
            );

            Navigator.of(context).pop();
            widget.onSave(updatedEntry);
          },
          child: 'Save Changes'.toSafeText(maxLines: 1),
        ),
      ],
    );
  }

  IconData _getStatusIcon(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return Icons.play_circle;
      case WatchStatus.completed:
        return Icons.check_circle;
      case WatchStatus.planToWatch:
        return Icons.bookmark;
      case WatchStatus.onHold:
        return Icons.pause_circle;
      case WatchStatus.dropped:
        return Icons.stop_circle;
    }
  }

  Color _getStatusColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return Colors.blue;
      case WatchStatus.completed:
        return Colors.green;
      case WatchStatus.planToWatch:
        return Colors.grey;
      case WatchStatus.onHold:
        return Colors.orange;
      case WatchStatus.dropped:
        return Colors.red;
    }
  }
}

// Enum for list sorting options
enum ListSortType {
  dateAdded,
  dateModified,
  title,
  score,
  progress,
}

extension ListSortTypeExtension on ListSortType {
  String get displayName {
    switch (this) {
      case ListSortType.dateAdded:
        return 'Date Added';
      case ListSortType.dateModified:
        return 'Last Modified';
      case ListSortType.title:
        return 'Title';
      case ListSortType.score:
        return 'Score';
      case ListSortType.progress:
        return 'Progress';
    }
  }
}
