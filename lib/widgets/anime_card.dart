import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animations/animations.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class AnimeCard extends ConsumerStatefulWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final bool showProgressBar;
  final bool showRating;
  final String? heroContext;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onTap,
    this.showProgressBar = false,
    this.showRating = true,
    this.heroContext,
  });

  @override
  ConsumerState<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends ConsumerState<AnimeCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEntry = ref.watch(animeInListProvider(widget.anime.malId));
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.onTap != null
              ? _buildCard(
                  context,
                  userEntry,
                  colorScheme,
                  widget.onTap!,
                )
              : OpenContainer(
                  transitionType: ContainerTransitionType.fade,
                  transitionDuration: const Duration(milliseconds: 500),
                  closedBuilder: (context, openContainer) => _buildCard(
                    context,
                    userEntry,
                    colorScheme,
                    openContainer,
                  ),
                  openBuilder: (context, closeContainer) => const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ), // Proper fallback widget
                  closedElevation: _elevationAnimation.value,
                  openElevation: 0,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, userEntry, ColorScheme colorScheme,
      VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                      colorScheme.secondaryContainer.withValues(alpha: 0.1),
                    ],
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image Section
                AspectRatio(
                  aspectRatio: 3 / 4, // Standard anime poster ratio
                  child: _buildHeroSection(context, userEntry, colorScheme),
                ),

                // Content Section
                Flexible(
                  child: _buildContentSection(context, userEntry, colorScheme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, userEntry, ColorScheme colorScheme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with Hero Animation
        Hero(
          tag: 'anime-image-${widget.anime.malId}',
          child: CachedNetworkImage(
            imageUrl: widget.anime.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.errorContainer,
                    colorScheme.errorContainer.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ),

        // Gradient Overlay for better text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Floating Elements
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              // Rating Badge
              if (widget.showRating && widget.anime.score != null)
                _buildScoreBadge(context, colorScheme),

              const SizedBox(height: 8),

              // Favorite Icon
              if (userEntry?.isFavorite == true)
                _buildFavoriteIcon(colorScheme),
            ],
          ),
        ),

        // Status Badge (Bottom Left)
        if (userEntry != null)
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildStatusBadge(context, userEntry.status, colorScheme),
          ),
      ],
    );
  }

  Widget _buildContentSection(
      BuildContext context, userEntry, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4), // Optimized padding
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Hero Animation
            Flexible(
              child: Hero(
                tag:
                    'anime-title-${widget.anime.malId}-${widget.heroContext ?? "default"}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.anime.displayTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2, // Slightly increased for readability
                          color: colorScheme.onSurface,
                          fontSize: 12, // Reduced font size
                        ),
                    maxLines: 2, // Consistent 2 lines for all titles
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2), // Minimal spacing

            // Metadata Row - Only show essential info
            Flexible(
              child: Row(
                children: [
                  // Episode Count or Year
                  Icon(
                    Icons.tv_outlined,
                    size: 10, // Further reduced
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2), // Minimal spacing
                  Expanded(
                    child: Text(
                      widget.anime.episodes != null
                          ? '${widget.anime.episodes} eps'
                          : widget.anime.year?.toString() ?? 'TBA',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 9, // Reduced font size
                            height: 1.0,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Type Badge - More compact
                  if ((widget.anime.type?.length ?? 0) <=
                      6) // Only show short types
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1), // Reduced padding
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(3), // Smaller radius
                        ),
                        child: Text(
                          widget.anime.type ?? 'N/A',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8, // Reduced font size
                                    height: 1.0,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Progress Bar (if user is watching) - More compact
            if (widget.showProgressBar &&
                userEntry != null &&
                userEntry.totalEpisodes != null)
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(top: 2), // Minimal margin
                  child: _buildProgressSection(context, userEntry, colorScheme),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context, ColorScheme colorScheme) {
    final score = widget.anime.score!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getScoreColor(score).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.favorite,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, WatchStatus status, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getStatusIcon(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context, userEntry, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 12, // Smaller icon
              color: colorScheme.primary,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                userEntry.progressText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10, // Smaller text
                      height: 1.0,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2), // Minimal spacing
        ClipRRect(
          borderRadius: BorderRadius.circular(3), // Smaller radius
          child: LinearProgressIndicator(
            value: userEntry.progressPercentage,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(userEntry.status),
            ),
            minHeight: 3, // Thinner progress bar
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return const Color(0xFF4CAF50); // Green
    if (score >= 7.5) return const Color(0xFF8BC34A); // Light Green
    if (score >= 6.5) return const Color(0xFFFF9800); // Orange
    if (score >= 5.5) return const Color(0xFFFF5722); // Deep Orange
    return const Color(0xFFF44336); // Red
  }

  Color _getStatusColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return const Color(0xFF2196F3); // Blue
      case WatchStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case WatchStatus.planToWatch:
        return const Color(0xFF9E9E9E); // Grey
      case WatchStatus.onHold:
        return const Color(0xFFFF9800); // Orange
      case WatchStatus.dropped:
        return const Color(0xFFF44336); // Red
    }
  }

  String _getStatusIcon(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return '▶';
      case WatchStatus.completed:
        return '✓';
      case WatchStatus.planToWatch:
        return '📋';
      case WatchStatus.onHold:
        return '⏸';
      case WatchStatus.dropped:
        return '✗';
    }
  }

  String _getStatusText(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return 'Watching';
      case WatchStatus.completed:
        return 'Completed';
      case WatchStatus.planToWatch:
        return 'Plan to Watch';
      case WatchStatus.onHold:
        return 'On Hold';
      case WatchStatus.dropped:
        return 'Dropped';
    }
  }
}
