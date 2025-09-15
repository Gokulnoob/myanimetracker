import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/services/services.dart';

class AnimeDetailsScreen extends ConsumerStatefulWidget {
  final Anime anime;

  const AnimeDetailsScreen({
    super.key,
    required this.anime,
  });

  // Static method for easy navigation
  static Route<void> route(Anime anime) {
    return MaterialPageRoute(
      builder: (context) => AnimeDetailsScreen(anime: anime),
    );
  }

  @override
  ConsumerState<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends ConsumerState<AnimeDetailsScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 200;
    if (showButton != _showFloatingButton) {
      setState(() {
        _showFloatingButton = showButton;
      });
      if (showButton) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEntry = ref.watch(animeInListProvider(widget.anime.malId));

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, userEntry),
          _buildAnimeInfo(),
          _buildSynopsis(),
          _buildDetailsSection(),
          _buildGenresSection(),
          _buildStatsSection(),
          _buildRelatedSection(),
          // Add some bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddToListBottomSheet(context, userEntry),
          icon: Icon(userEntry != null ? Icons.edit : Icons.add),
          label: Text(userEntry != null ? 'Edit' : 'Add to List'),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserAnimeEntry? userEntry) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: widget.anime.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Content overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.anime.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.anime.titleEnglish != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.anime.titleEnglish!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.anime.score != null) ...[
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.anime.score!.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (userEntry != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(userEntry.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            userEntry.status.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimeInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.anime.imageUrl,
                width: 120,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 160,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Info details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Type', widget.anime.type ?? 'Unknown'),
                  _buildInfoRow('Episodes', '${widget.anime.episodes ?? '?'}'),
                  _buildInfoRow('Status', widget.anime.status ?? 'Unknown'),
                  if (widget.anime.aired != null)
                    _buildInfoRow('Aired', widget.anime.aired!),
                  if (widget.anime.season != null && widget.anime.year != null)
                    _buildInfoRow('Season',
                        '${widget.anime.season} ${widget.anime.year}'),
                  if (widget.anime.source != null)
                    _buildInfoRow('Source', widget.anime.source!),
                  if (widget.anime.rating != null)
                    _buildInfoRow('Rating', widget.anime.rating!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsis() {
    if (widget.anime.synopsis == null || widget.anime.synopsis!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Synopsis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.anime.synopsis!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    final details = <String, String?>{
      'Japanese Title': widget.anime.titleJapanese,
      'English Title': widget.anime.titleEnglish,
      'Duration': widget.anime.duration,
      'Studios': widget.anime.studios.map((s) => s.name).join(', '),
    };

    final nonEmptyDetails = details.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .toList();

    if (nonEmptyDetails.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...nonEmptyDetails
                .map((entry) => _buildInfoRow(entry.key, entry.value!)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresSection() {
    if (widget.anime.genres.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genres',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.anime.genres.map((genre) {
                return Chip(
                  label: Text(genre.name),
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = <String, String?>{
      'Score': widget.anime.score?.toStringAsFixed(2),
      'Ranked': widget.anime.rank != null ? '#${widget.anime.rank}' : null,
      'Popularity': widget.anime.popularity != null
          ? '#${widget.anime.popularity}'
          : null,
      'Scored By': widget.anime.scoredBy?.toString(),
    };

    final nonEmptyStats = stats.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .toList();

    if (nonEmptyStats.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: nonEmptyStats.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          Text(
                            entry.value!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedSection() {
    // For now, this is a placeholder for related anime
    // In a real app, you'd fetch related anime from the API
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Color _getStatusColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return Colors.green;
      case WatchStatus.completed:
        return Colors.blue;
      case WatchStatus.onHold:
        return Colors.orange;
      case WatchStatus.dropped:
        return Colors.red;
      case WatchStatus.planToWatch:
        return Colors.purple;
    }
  }

  void _showAddToListBottomSheet(
      BuildContext context, UserAnimeEntry? userEntry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddToListBottomSheet(
        anime: widget.anime,
        existingEntry: userEntry,
      ),
    );
  }
}

class _AddToListBottomSheet extends ConsumerStatefulWidget {
  final Anime anime;
  final UserAnimeEntry? existingEntry;

  const _AddToListBottomSheet({
    required this.anime,
    this.existingEntry,
  });

  @override
  ConsumerState<_AddToListBottomSheet> createState() =>
      _AddToListBottomSheetState();
}

class _AddToListBottomSheetState extends ConsumerState<_AddToListBottomSheet> {
  late WatchStatus _selectedStatus;
  late int _score;
  late int _episodesWatched;
  late String _notes;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _selectedStatus = widget.existingEntry!.status;
      _score = widget.existingEntry!.personalScore?.round() ?? 0;
      _episodesWatched = widget.existingEntry!.episodesWatched;
      _notes = widget.existingEntry!.personalNotes ?? '';
      _isFavorite = widget.existingEntry!.isFavorite;
    } else {
      _selectedStatus = WatchStatus.planToWatch;
      _score = 0;
      _episodesWatched = 0;
      _notes = '';
      _isFavorite = false;
    }
  }

  void _handleStatusChange(WatchStatus newStatus) {
    // Smart status handling - automatically set appropriate values based on status
    if (widget.anime.episodes != null) {
      switch (newStatus) {
        case WatchStatus.completed:
          // Set episodes to total when marked as completed
          _episodesWatched = widget.anime.episodes!;
          break;
        case WatchStatus.planToWatch:
          // Reset to 0 when planning to watch
          _episodesWatched = 0;
          break;
        case WatchStatus.watching:
          // If coming from plan to watch, set to 1
          // Otherwise, leave current progress
          if (_selectedStatus == WatchStatus.planToWatch) {
            _episodesWatched = 1;
          }
          break;
        case WatchStatus.onHold:
          // Keep current progress
          break;
        case WatchStatus.dropped:
          // Keep current progress (where they dropped it)
          break;
      }
    }

    // Set score suggestions based on status
    switch (newStatus) {
      case WatchStatus.completed:
        // If no score set, suggest they rate it
        if (_score == 0) {
          // Don't auto-set score, but could show a hint
        }
        break;
      case WatchStatus.dropped:
        // Dropped anime typically get lower scores, but don't force it
        break;
      case WatchStatus.planToWatch:
        // Clear score when planning to watch
        _score = 0;
        break;
      default:
        // Keep existing score for watching/on-hold
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  widget.existingEntry != null ? 'Edit Entry' : 'Add to List',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status selection
                        Text(
                          'Status',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: WatchStatus.values.map((status) {
                            final isSelected = _selectedStatus == status;
                            return ChoiceChip(
                              label: Text(status.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedStatus = status;
                                    // Smart status handling
                                    _handleStatusChange(status);
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Score
                        Text(
                          'Score',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _score.toDouble(),
                                min: 0,
                                max: 10,
                                divisions: 10,
                                label: _score == 0
                                    ? 'Not scored'
                                    : _score.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _score = value.round();
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                _score == 0 ? 'N/A' : _score.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Episodes watched
                        if (widget.anime.episodes != null) ...[
                          Text(
                            'Episodes Watched',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _episodesWatched.toDouble(),
                                  min: 0,
                                  max: widget.anime.episodes!.toDouble(),
                                  divisions: widget.anime.episodes!,
                                  label:
                                      '$_episodesWatched / ${widget.anime.episodes}',
                                  onChanged: (value) {
                                    setState(() {
                                      _episodesWatched = value.round();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '$_episodesWatched / ${widget.anime.episodes}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Favorite toggle
                        Row(
                          children: [
                            Text(
                              'Add to Favorites',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _isFavorite,
                              onChanged: (value) {
                                setState(() {
                                  _isFavorite = value;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Notes
                        Text(
                          'Notes',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (value) {
                            _notes = value;
                          },
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Add your notes here...',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: _notes),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Row(
                  children: [
                    if (widget.existingEntry != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _removeFromList(context),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveEntry(context),
                        icon: const Icon(Icons.save),
                        label: Text(
                            widget.existingEntry != null ? 'Update' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveEntry(BuildContext context) {
    if (widget.existingEntry != null) {
      // Update existing entry
      final entry = widget.existingEntry!;
      entry.updateStatus(_selectedStatus);
      entry.updateProgress(_episodesWatched);
      entry.updateScore(_score.toDouble());
      entry.updateNotes(_notes.isEmpty ? null : _notes);
      if (_isFavorite != entry.isFavorite) {
        entry.toggleFavorite();
      }

      // Save through HiveService directly
      HiveService.saveUserAnimeEntry(entry);
    } else {
      // Create new entry using provider method
      ref.read(userAnimeListsProvider.notifier).addAnimeToList(
            widget.anime.malId,
            _selectedStatus,
            totalEpisodes: widget.anime.episodes,
          );

      // If we need to set additional properties, get and update the entry
      if (_score > 0 ||
          _notes.isNotEmpty ||
          _isFavorite ||
          _episodesWatched > 0) {
        final entry = HiveService.getUserAnimeEntry(widget.anime.malId);
        if (entry != null) {
          if (_score > 0) entry.updateScore(_score.toDouble());
          if (_notes.isNotEmpty) entry.updateNotes(_notes);
          if (_isFavorite) entry.toggleFavorite();
          if (_episodesWatched > 0) entry.updateProgress(_episodesWatched);
          HiveService.saveUserAnimeEntry(entry);
        }
      }
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingEntry != null
              ? 'Entry updated successfully'
              : 'Added to your list',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFromList(BuildContext context) {
    ref.read(userAnimeListsProvider.notifier).removeAnime(widget.anime.malId);
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from your list'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
