import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/catch_record.dart';
import '../../data/providers/app_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _sortBy = 'date';
  String? _filterSpecies;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        var catches = List<CatchRecord>.from(appState.catches);

        // Apply filter
        if (_filterSpecies != null) {
          catches = catches.where((c) => c.species == _filterSpecies).toList();
        }

        // Apply sort
        switch (_sortBy) {
          case 'date':
            catches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            break;
          case 'species':
            catches.sort((a, b) => a.species.compareTo(b.species));
            break;
          case 'weight':
            catches.sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0));
            break;
        }

        return Scaffold(
          backgroundColor: AppColors.mapDark,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(appState),
              _buildStats(appState),
              _buildFilters(appState),
              if (catches.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                _buildCatchList(catches),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(AppState appState) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.mapDark,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Catch History (${appState.catches.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBrown.withAlpha(100),
                AppColors.mapDark,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(AppState appState) {
    final profile = appState.userProfile;
    final stats = profile?.stats;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '${stats?.totalCatches ?? 0}',
              'Total Catches',
              Icons.phishing,
            ),
            _buildStatItem(
              stats?.biggestCatch != null
                  ? '${stats!.biggestCatch!.toStringAsFixed(1)} lbs'
                  : '-',
              'Biggest',
              Icons.emoji_events,
            ),
            _buildStatItem(
              '${stats?.fishingDays ?? 0}',
              'Days Fished',
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentGold, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildFilters(AppState appState) {
    final species = appState.catches.map((c) => c.species).toSet().toList()
      ..sort();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceCard,
                    items: const [
                      DropdownMenuItem(
                        value: 'date',
                        child: Text('Sort by Date'),
                      ),
                      DropdownMenuItem(
                        value: 'species',
                        child: Text('Sort by Species'),
                      ),
                      DropdownMenuItem(
                        value: 'weight',
                        child: Text('Sort by Weight'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _filterSpecies,
                    isExpanded: true,
                    hint: const Text('All Species'),
                    dropdownColor: AppColors.surfaceCard,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Species'),
                      ),
                      ...species.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _filterSpecies = value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phishing,
            size: 80,
            color: AppColors.textMuted.withAlpha(100),
          ),
          const SizedBox(height: 16),
          const Text(
            'No catches yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start logging your catches!',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  SliverList _buildCatchList(List<CatchRecord> catches) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final catchRecord = catches[index];
        return _CatchCard(
          catchRecord: catchRecord,
          onDelete: () => _confirmDelete(catchRecord),
        );
      }, childCount: catches.length),
    );
  }

  void _confirmDelete(CatchRecord catchRecord) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Catch?'),
        content: Text(
          'Are you sure you want to delete this ${catchRecord.species} catch?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteCatch(catchRecord.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catch deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatchCard extends StatelessWidget {
  final CatchRecord catchRecord;
  final VoidCallback onDelete;

  const _CatchCard({required this.catchRecord, required this.onDelete});

  void _showPhotoViewer(BuildContext context) {
    if (catchRecord.photoUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surfaceCard,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(catchRecord.photoUrl!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    catchRecord.species,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (catchRecord.weight != null) ...[
                        Text(
                          '${catchRecord.weight} lbs',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (catchRecord.length != null)
                        Text(
                          '${catchRecord.length}"',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM d, yyyy • h:mm a',
                    ).format(catchRecord.timestamp),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = catchRecord.photoUrl != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: hasPhoto ? () => _showPhotoViewer(context) : null,
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catchRecord.species,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (catchRecord.weight != null) ...[
                            const Icon(
                              Icons.monitor_weight_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${catchRecord.weight} lbs',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (catchRecord.length != null) ...[
                            const Icon(
                              Icons.straighten,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${catchRecord.length}"',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.catching_pokemon,
                            size: 14,
                            color: AppColors.accentOrange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              catchRecord.baitUsed,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMM d').format(catchRecord.timestamp),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(catchRecord.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (hasPhoto) ...[
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.photo,
                        size: 16,
                        color: AppColors.accentGold,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (catchRecord.photoUrl != null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(catchRecord.photoUrl!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          ),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.set_meal,
        color: AppColors.primaryGreen,
        size: 28,
      ),
    );
  }
}
