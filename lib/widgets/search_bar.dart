import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/models.dart';
import '../core/providers/providers.dart';

class AnimeSearchBar extends ConsumerStatefulWidget {
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool autofocus;
  final bool showFilters;

  const AnimeSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.showFilters = true,
  });

  @override
  ConsumerState<AnimeSearchBar> createState() => _AnimeSearchBarState();
}

class _AnimeSearchBarState extends ConsumerState<AnimeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final localResults = _controller.text.isNotEmpty
        ? ref.watch(localSearchProvider(_controller.text))
        : <Anime>[];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Search anime...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _showSuggestions = false;
                        });
                        widget.onChanged?.call('');
                      },
                    ),
                  if (widget.showFilters)
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: searchState.filters.hasActiveFilters
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                      onPressed: () => _showFilterDialog(context),
                    ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _showSuggestions = value.isNotEmpty;
              });
              widget.onChanged?.call(value);
            },
            onSubmitted: (value) {
              setState(() {
                _showSuggestions = false;
              });
              widget.onSubmitted?.call(value);
            },
            onTap: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _showSuggestions = true;
                });
              }
            },
          ),
        ),

        // Search suggestions
        if (_showSuggestions && localResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: localResults.map((anime) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      anime.imageUrl,
                      width: 40,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  title: Text(
                    anime.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    anime.episodeProgress,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    _controller.text = anime.displayTitle;
                    setState(() {
                      _showSuggestions = false;
                    });
                    widget.onSubmitted?.call(anime.displayTitle);
                  },
                );
              }).toList(),
            ),
          ),

        // Search history
        if (_showSuggestions &&
            localResults.isEmpty &&
            searchState.searchHistory.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent searches',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(searchProvider.notifier)
                              .clearSearchHistory();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
                ...searchState.searchHistory.take(5).map((query) {
                  return ListTile(
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(query),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () async {
                        await ref
                            .read(searchProvider.notifier)
                            .removeFromHistory(query);
                      },
                    ),
                    onTap: () {
                      _controller.text = query;
                      setState(() {
                        _showSuggestions = false;
                      });
                      widget.onSubmitted?.call(query);
                    },
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SearchFiltersSheet(),
    );
  }
}

class SearchFiltersSheet extends ConsumerStatefulWidget {
  const SearchFiltersSheet({super.key});

  @override
  ConsumerState<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends ConsumerState<SearchFiltersSheet> {
  late SearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = ref.read(searchProvider).filters.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Search Filters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filters.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Type Filter
          Text(
            'Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AnimeType.values.map((type) {
              return FilterChip(
                label: Text(type.displayName),
                selected: _filters.type == type,
                onSelected: (selected) {
                  setState(() {
                    _filters = _filters.copyWith(
                      type: selected ? type : null,
                    );
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Score Range
          Text(
            'Minimum Score',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _filters.minScore ?? 0.0,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            label: (_filters.minScore ?? 0.0).toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(minScore: value);
              });
            },
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
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
                    ref.read(searchProvider.notifier).updateFilters(_filters);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
