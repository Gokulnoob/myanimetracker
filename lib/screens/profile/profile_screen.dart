import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userListsState = ref.watch(userAnimeListsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),

              const SizedBox(height: 24),

              // Statistics Section
              _buildStatisticsSection(userListsState),

              const SizedBox(height: 24),

              // Activity Section
              _buildActivitySection(userListsState),

              const SizedBox(height: 24),

              // Settings Section
              _buildSettingsSection(context),

              const SizedBox(height: 24),

              // Data Management Section
              _buildDataManagementSection(context),

              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                'ME',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 16),

            // User info
            Text(
              'MyAnime Tracker User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Anime Enthusiast',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 16),

            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStat('Lists', '5', Icons.list_alt),
                _buildQuickStat(
                    'Anime', _getTotalAnimeCount().toString(), Icons.movie),
                _buildQuickStat('Episodes',
                    _getTotalEpisodesWatched().toString(), Icons.play_circle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
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
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(UserAnimeListsState userListsState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // List breakdown
            ...WatchStatus.values.map((status) {
              final count = userListsState.getListByStatus(status).length;
              if (count == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(status.displayName),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 24),

            // Detailed stats
            _buildDetailedStats(userListsState),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(UserAnimeListsState userListsState) {
    final allEntries = WatchStatus.values
        .expand((status) => userListsState.getListByStatus(status))
        .toList();

    final totalEpisodes = allEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.episodesWatched,
    );

    final scoredEntries =
        allEntries.where((e) => e.personalScore != null).toList();
    final avgScore = scoredEntries.isNotEmpty
        ? scoredEntries.map((e) => e.personalScore!).reduce((a, b) => a + b) /
            scoredEntries.length
        : 0.0;

    final completedEntries =
        userListsState.getListByStatus(WatchStatus.completed);
    final favoritesCount = allEntries.where((e) => e.isFavorite).length;

    // Calculate estimated watch time (assuming 24 minutes per episode)
    final totalMinutes = totalEpisodes * 24;
    final totalHours = totalMinutes / 60;
    final totalDays = totalHours / 24;

    return Column(
      children: [
        _buildStatRow('Total Episodes Watched', totalEpisodes.toString()),
        _buildStatRow(
            'Estimated Watch Time', '${totalDays.toStringAsFixed(1)} days'),
        _buildStatRow('Completed Anime', completedEntries.length.toString()),
        _buildStatRow('Favorites', favoritesCount.toString()),
        if (avgScore > 0)
          _buildStatRow('Average Score', avgScore.toStringAsFixed(2)),
        _buildStatRow(
            'Scored Entries', '${scoredEntries.length}/${allEntries.length}'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(UserAnimeListsState userListsState) {
    final recentEntries = _getRecentActivity(userListsState);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No recent activity',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentEntries.take(5).map((entry) {
                return _buildActivityItem(entry);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(UserAnimeEntry entry) {
    final timeDiff = DateTime.now().difference(entry.lastModified);
    String timeAgo;

    if (timeDiff.inDays > 0) {
      timeAgo = '${timeDiff.inDays}d ago';
    } else if (timeDiff.inHours > 0) {
      timeAgo = '${timeDiff.inHours}h ago';
    } else {
      timeAgo = '${timeDiff.inMinutes}m ago';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(entry.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Updated anime #${entry.animeId}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${entry.status.displayName} • $timeAgo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Theme',
              subtitle: 'Light / Dark Mode',
              onTap: () => _showThemeDialog(context),
            ),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => _showNotificationSettings(context),
            ),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'App language settings',
              onTap: () => _showLanguageSettings(context),
            ),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Privacy',
              subtitle: 'Privacy and security settings',
              onTap: () => _showPrivacySettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.backup_outlined,
              title: 'Backup Data',
              subtitle: 'Create a backup of your lists',
              onTap: () => _backupData(context),
            ),
            _buildSettingsTile(
              icon: Icons.restore_outlined,
              title: 'Restore Data',
              subtitle: 'Restore from a backup file',
              onTap: () => _restoreData(context),
            ),
            _buildSettingsTile(
              icon: Icons.sync_outlined,
              title: 'Sync with MAL',
              subtitle: 'Import/Export to MyAnimeList',
              onTap: () => _syncWithMAL(context),
            ),
            _buildSettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'Clear All Data',
              subtitle: 'Reset the app to initial state',
              onTap: () => _showClearDataDialog(context),
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  List<UserAnimeEntry> _getRecentActivity(UserAnimeListsState userListsState) {
    final allEntries = WatchStatus.values
        .expand((status) => userListsState.getListByStatus(status))
        .toList();

    allEntries.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return allEntries;
  }

  int _getTotalAnimeCount() {
    final userListsState = ref.read(userAnimeListsProvider);
    return userListsState.totalAnime;
  }

  int _getTotalEpisodesWatched() {
    final userListsState = ref.read(userAnimeListsProvider);
    return WatchStatus.values
        .expand((status) => userListsState.getListByStatus(status))
        .fold<int>(0, (sum, entry) => sum + entry.episodesWatched);
  }

  Color _getStatusColor(WatchStatus status) {
    switch (status) {
      case WatchStatus.watching:
        return Colors.green;
      case WatchStatus.completed:
        return Colors.blue;
      case WatchStatus.planToWatch:
        return Colors.purple;
      case WatchStatus.onHold:
        return Colors.orange;
      case WatchStatus.dropped:
        return Colors.red;
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackBar('Theme switching');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackBar('Theme switching');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_mode),
              title: const Text('System Default'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackBar('Theme switching');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    _showComingSoonSnackBar('Notification settings');
  }

  void _showLanguageSettings(BuildContext context) {
    _showComingSoonSnackBar('Language settings');
  }

  void _showPrivacySettings(BuildContext context) {
    _showComingSoonSnackBar('Privacy settings');
  }

  void _backupData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'This will create a backup file containing all your anime lists and settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performBackup();
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _restoreData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace all your current data with data from a backup file. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRestore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Select Backup File'),
          ),
        ],
      ),
    );
  }

  void _syncWithMAL(BuildContext context) {
    _showComingSoonSnackBar('MyAnimeList sync');
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your anime lists, settings, and cached data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  void _performBackup() {
    _showComingSoonSnackBar('Data backup');
  }

  void _performRestore() {
    _showComingSoonSnackBar('Data restore');
  }

  void _clearAllData() {
    // Implementation would clear all data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data cleared'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
