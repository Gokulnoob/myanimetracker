import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/overflow_utils.dart';

class AnimeCard extends ConsumerWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final bool showProgressBar;
  final bool showRating;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onTap,
    this.showProgressBar = false,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEntry = ref.watch(animeInListProvider(anime.malId));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anime Image
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: anime.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Rating Badge
                  if (showRating && anime.score != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getScoreColor(anime.score!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: anime.score!.toStringAsFixed(1).toSafeText(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                      ),
                    ),

                  // Status Badge
                  if (userEntry != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(userEntry.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _getStatusIcon(userEntry.status).toSafeText(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),

                  // Favorite Icon
                  if (userEntry?.isFavorite == true)
                    const Positioned(
                      bottom: 8,
                      right: 8,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),

            // Anime Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  SizedBox(
                    height: 36,
                    child: anime.displayTitle.toSafeText(
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Episode count or Year
                  (anime.episodes != null
                          ? '${anime.episodes} episodes'
                          : anime.year?.toString() ?? 'Unknown')
                      .toSafeText(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                  ),

                  // Progress Bar (if user is watching)
                  if (showProgressBar &&
                      userEntry != null &&
                      userEntry.totalEpisodes != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          userEntry.progressText.toSafeText(
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          LinearProgressIndicator(
                            value: userEntry.progressPercentage,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(userEntry.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 7.0) return Colors.lightGreen;
    if (score >= 6.0) return Colors.orange;
    if (score >= 5.0) return Colors.deepOrange;
    return Colors.red;
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
}
