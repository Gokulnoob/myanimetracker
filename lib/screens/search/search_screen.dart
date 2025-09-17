import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/utils/overflow_utils.dart';
import '../../widgets/widgets.dart';
import '../details/anime_details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Pre-populate search controller with current query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentQuery = ref.read(searchProvider).filters.query;
      if (currentQuery != null && currentQuery.isNotEmpty) {
        _searchController.text = currentQuery;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Dismiss keyboard when scrolling
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }

    // Load more content when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final searchState = ref.watch(searchProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent automatic resize
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(), // Prevent overscroll glow
          ),
          // Performance optimizations
          cacheExtent: 2000,
          slivers: [
            // Search Header - Always visible at top
            SliverToBoxAdapter(
              child: _buildSearchHeader(searchState),
            ),

            // Main Content Area
            _buildMainContent(searchState, keyboardHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(SearchState searchState, double keyboardHeight) {
    // No search performed yet - show empty state
    if (searchState.results.isEmpty &&
        !searchState.isLoading &&
        searchState.error == null &&
        (searchState.filters.query?.isEmpty ?? true) &&
        !searchState.filters.hasActiveFilters) {
      return _buildEmptyState(keyboardHeight);
    }

    // Loading state (first search)
    if (searchState.isLoading && searchState.results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 32,
            bottom: keyboardHeight + 32,
          ),
          child: const Center(
            child: LoadingWidget(
              showShimmer: true,
              message: 'Searching anime...',
            ),
          ),
        ),
      );
    }

    // Error state
    if (searchState.error != null && searchState.results.isEmpty) {
      return _buildErrorState(searchState.error!, keyboardHeight);
    }

    // No results found
    if (searchState.results.isEmpty && !searchState.isLoading) {
      return _buildNoResultsState(keyboardHeight);
    }

    // Results found - show grid
    return _buildResultsGrid(searchState, keyboardHeight);
  }

  Widget _buildSearchHeader(SearchState searchState) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Bar with title and clear filters
          Row(
            children: [
              Expanded(
                child: Text(
                  'Search Anime',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (searchState.filters.hasActiveFilters) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list_off,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.unfocus();
                    ref.read(searchProvider.notifier).updateFilters(
                          SearchFilters.empty(),
                        );
                    ref.read(searchProvider.notifier).clearSearch();
                  },
                  tooltip: 'Clear Filters',
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Search Bar with Filter Button
          Row(
            children: [
              // Search Bar
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 56),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search for anime...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                ref.read(searchProvider.notifier).clearSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _performSearch,
                    onChanged: (value) {
                      setState(() {}); // Update suffix icon visibility
                      if (value.isEmpty) {
                        ref.read(searchProvider.notifier).clearSearch();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Filter Button
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  color: searchState.filters.hasActiveFilters
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.surface,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: searchState.filters.hasActiveFilters
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => _showFilterDialog(),
                  tooltip: 'Filters',
                ),
              ),
            ],
          ),

          // Active Filters Display
          if (searchState.filters.hasActiveFilters) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                child: _buildActiveFiltersChips(searchState.filters),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips(SearchFilters filters) {
    final List<Widget> chips = [];

    if (filters.type != null) {
      chips.add(_buildFilterChip(
        'Type: ${filters.type!.displayName}',
        () => ref.read(searchProvider.notifier).updateFilters(
              filters.copyWith(type: null),
            ),
      ));
    }

    if (filters.status != null) {
      chips.add(_buildFilterChip(
        'Status: ${filters.status!.displayName}',
        () => ref.read(searchProvider.notifier).updateFilters(
              filters.copyWith(status: null),
            ),
      ));
    }

    if (filters.minScore != null) {
      chips.add(_buildFilterChip(
        'Min Score: ${filters.minScore!.toStringAsFixed(1)}',
        () => ref.read(searchProvider.notifier).updateFilters(
              filters.copyWith(minScore: null),
            ),
      ));
    }

    if (filters.genreIds.isNotEmpty) {
      chips.add(_buildFilterChip(
        'Genres: ${filters.genreIds.length}',
        () => ref.read(searchProvider.notifier).updateFilters(
              filters.copyWith(genreIds: []),
            ),
      ));
    }

    if (filters.startYear != null || filters.endYear != null) {
      final yearText =
          '${filters.startYear ?? 'Any'} - ${filters.endYear ?? 'Any'}';
      chips.add(_buildFilterChip(
        'Year: $yearText',
        () => ref.read(searchProvider.notifier).updateFilters(
              filters.copyWith(startYear: null, endYear: null),
            ),
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      side: BorderSide(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildEmptyState(double keyboardHeight) {
    final searchHistory = ref.watch(searchProvider).searchHistory;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: keyboardHeight + 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (keyboardHeight == 0) ...[
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Discover Anime',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for your favorite anime or use filters to explore new titles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildQuickSearches(),
            ],

            // Recent searches - always visible but condensed when keyboard is open
            if (searchHistory.isNotEmpty) ...[
              if (keyboardHeight == 0) const SizedBox(height: 32),
              _buildRecentSearches(searchHistory, keyboardHeight > 0),
            ],

            // Flexible spacer
            if (keyboardHeight == 0) const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, double keyboardHeight) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: keyboardHeight + 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final filters = ref.read(searchProvider).filters;
                if (filters.query?.isNotEmpty == true ||
                    filters.hasActiveFilters) {
                  ref.read(searchProvider.notifier).search(
                        query: filters.query,
                        filters: filters,
                        refresh: true,
                      );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(double keyboardHeight) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          top: 32,
          bottom: keyboardHeight + 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or adjust your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
                ref.read(searchProvider.notifier).updateFilters(
                      SearchFilters.empty(),
                    );
                ref.read(searchProvider.notifier).clearSearch();
              },
              icon: const Icon(Icons.filter_list_off),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGrid(SearchState searchState, double keyboardHeight) {
    final crossAxisCount = OverflowUtils.getResponsiveGridCount(
      context,
      itemWidth: 160.0,
      minCount: 2,
      maxCount: 4,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8, // Reduced spacing like trending section
          mainAxisSpacing: 12, // Slightly less vertical spacing
          childAspectRatio: 0.68, // Optimized for compact content section
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final anime = searchState.results[index];
            return RepaintBoundary(
              key: ValueKey('anime_${anime.malId}'),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fade,
                transitionDuration: const Duration(milliseconds: 500),
                closedBuilder: (context, openContainer) => AnimeCard(
                  anime: anime,
                  heroContext: 'search',
                  onTap: openContainer,
                ),
                openBuilder: (context, closeContainer) =>
                    AnimeDetailsScreen(anime: anime),
                closedElevation: 0,
                openElevation: 0,
              ),
            );
          },
          childCount: searchState.results.length,
        ),
      ),
    );
  }

  Widget _buildQuickSearches() {
    final quickSearches = [
      'Attack on Titan',
      'One Piece',
      'Demon Slayer',
      'Naruto',
      'Death Note',
      'Your Name',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickSearches.map((search) {
            return ActionChip(
              label: Text(search),
              onPressed: () {
                _searchController.text = search;
                _performSearch(search);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(List<String> searchHistory,
      [bool isCompact = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                ref.read(searchProvider.notifier).clearSearchHistory();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...searchHistory.take(isCompact ? 3 : 5).map((query) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 56),
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(searchProvider.notifier).removeFromHistory(query);
                },
              ),
              onTap: () {
                _searchController.text = query;
                _performSearch(query);
              },
            ),
          );
        }),
      ],
    );
  }

  void _performSearch(String query) {
    _searchFocusNode.unfocus();
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).search(
            query: query.trim(),
            refresh: true,
          );
    }
  }

  void _showFilterDialog() {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        currentFilters: ref.read(searchProvider).filters,
        onFiltersChanged: (filters) {
          ref.read(searchProvider.notifier).updateFilters(filters);
          // Auto-search if there's an active query or filters
          final currentQuery = _searchController.text.trim();
          if (currentQuery.isNotEmpty || filters.hasActiveFilters) {
            ref.read(searchProvider.notifier).search(
                  query: currentQuery.isNotEmpty ? currentQuery : null,
                  filters: filters,
                  refresh: true,
                );
          }
        },
      ),
    );
  }
}

// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onFiltersChanged;

  const _FilterBottomSheet({
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late SearchFilters _tempFilters;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.currentFilters.copyWith();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.9;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: screenHeight * 0.3,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter Anime',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_tempFilters.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempFilters = SearchFilters.empty();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  _buildStatusFilter(),
                  const SizedBox(height: 24),
                  _buildScoreFilter(),
                  const SizedBox(height: 24),
                  _buildYearFilter(),
                  const SizedBox(height: 24),
                  _buildGenreFilter(),
                  const SizedBox(height: 80), // Extra space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltersChanged(_tempFilters);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    final types = [
      AnimeType.tv,
      AnimeType.movie,
      AnimeType.ova,
      AnimeType.special,
      AnimeType.ona,
      AnimeType.music,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = _tempFilters.type == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempFilters = _tempFilters.copyWith(
                    type: selected ? type : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      AnimeStatus.airing,
      AnimeStatus.complete,
      AnimeStatus.upcoming,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statuses.map((status) {
            final isSelected = _tempFilters.status == status;
            return FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempFilters = _tempFilters.copyWith(
                    status: selected ? status : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScoreFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Minimum Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_tempFilters.minScore != null)
              Text(
                _tempFilters.minScore!.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _tempFilters.minScore ?? 0.0,
          min: 0.0,
          max: 10.0,
          divisions: 100,
          label: (_tempFilters.minScore ?? 0.0).toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _tempFilters = _tempFilters.copyWith(
                minScore: value > 0 ? value : null,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0.0', style: TextStyle(fontSize: 12)),
            const Text('10.0', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildYearFilter() {
    final currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Release Year',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: _tempFilters.startYear,
                      hint: const Text('Any'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: List.generate(
                        currentYear - 1960 + 1,
                        (index) {
                          final year = currentYear - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        },
                      ),
                      onChanged: (year) {
                        setState(() {
                          _tempFilters = _tempFilters.copyWith(
                            startYear: year,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: _tempFilters.endYear,
                      hint: const Text('Any'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: List.generate(
                        currentYear - 1960 + 1,
                        (index) {
                          final year = currentYear - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        },
                      ),
                      onChanged: (year) {
                        setState(() {
                          _tempFilters = _tempFilters.copyWith(
                            endYear: year,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreFilter() {
    // Mock genres - replace with actual genre data
    final genres = [
      {'id': 1, 'name': 'Action'},
      {'id': 2, 'name': 'Adventure'},
      {'id': 4, 'name': 'Comedy'},
      {'id': 8, 'name': 'Drama'},
      {'id': 10, 'name': 'Fantasy'},
      {'id': 14, 'name': 'Horror'},
      {'id': 22, 'name': 'Romance'},
      {'id': 24, 'name': 'Sci-Fi'},
      {'id': 26, 'name': 'Shoujo'},
      {'id': 27, 'name': 'Shounen'},
      {'id': 31, 'name': 'Super Power'},
      {'id': 37, 'name': 'Supernatural'},
      {'id': 39, 'name': 'Thriller'},
      {'id': 9, 'name': 'Ecchi'},
      {'id': 19, 'name': 'Music'},
      {'id': 23, 'name': 'School'},
      {'id': 36, 'name': 'Slice of Life'},
      {'id': 30, 'name': 'Sports'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres (${_tempFilters.genreIds.length} selected)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres.map((genre) {
            final genreId = genre['id'] as int;
            final isSelected = _tempFilters.genreIds.contains(genreId);
            return FilterChip(
              label: Text(genre['name'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newGenreIds = List<int>.from(_tempFilters.genreIds);
                  if (selected) {
                    newGenreIds.add(genreId);
                  } else {
                    newGenreIds.remove(genreId);
                  }
                  _tempFilters = _tempFilters.copyWith(
                    genreIds: newGenreIds,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
