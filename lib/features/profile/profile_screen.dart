import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_profile.dart';
import '../../data/providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final profile = appState.userProfile;

        return Scaffold(
          backgroundColor: AppColors.mapDark,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, profile),
              SliverToBoxAdapter(child: _buildProfileHeader(profile)),
              SliverToBoxAdapter(child: _buildStatsSection(profile)),
              SliverToBoxAdapter(
                child: _buildSettingsSection(context, profile),
              ),
              SliverToBoxAdapter(child: _buildAboutSection(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, UserProfile? profile) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.mapDark,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditProfileDialog(context, profile),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile? profile) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? 'Angler',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (profile?.email != null)
                  Text(
                    profile!.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getAnglerLevel(profile?.stats.totalCatches ?? 0),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAnglerLevel(int catches) {
    if (catches >= 100) return 'Master Angler';
    if (catches >= 50) return 'Expert Angler';
    if (catches >= 25) return 'Skilled Angler';
    if (catches >= 10) return 'Intermediate';
    return 'Beginner';
  }

  Widget _buildStatsSection(UserProfile? profile) {
    final stats = profile?.stats;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatTile(
                'Total Catches',
                '${stats?.totalCatches ?? 0}',
                Icons.phishing,
                AppColors.accentOrange,
              ),
              const SizedBox(width: 12),
              _buildStatTile(
                'Days Fished',
                '${stats?.fishingDays ?? 0}',
                Icons.calendar_today,
                AppColors.waterBlue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatTile(
                'Biggest Catch',
                stats?.biggestCatch != null
                    ? '${stats!.biggestCatch!.toStringAsFixed(1)} lbs'
                    : '-',
                Icons.emoji_events,
                AppColors.accentGold,
              ),
              const SizedBox(width: 12),
              _buildStatTile(
                'Top Species',
                stats?.mostCaughtSpecies ?? '-',
                Icons.set_meal,
                AppColors.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, UserProfile? profile) {
    final settings = profile?.settings ?? const UserSettings();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive bite forecast alerts',
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                context.read<AppState>().updateSettings(
                  settings.copyWith(notificationsEnabled: value),
                );
              },
              activeColor: AppColors.accentOrange,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'Enable for accurate forecasts',
            trailing: Switch(
              value: settings.locationEnabled,
              onChanged: (value) {
                context.read<AppState>().updateSettings(
                  settings.copyWith(locationEnabled: value),
                );
              },
              activeColor: AppColors.accentOrange,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.straighten,
            title: 'Units',
            subtitle: settings.unitSystem == 'imperial'
                ? 'Imperial (lbs, ft)'
                : 'Metric (kg, m)',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: () => _showUnitsDialog(context, settings),
          ),
          _buildSettingsTile(
            icon: Icons.alarm,
            title: 'Alert Threshold',
            subtitle:
                'Notify when bite score ≥ ${settings.minBiteScoreAlert.round()}%',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
            onTap: () => _showAlertThresholdDialog(context, settings),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentOrange),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear All Data',
            subtitle: 'Delete all catches and settings',
            trailing: const Icon(Icons.chevron_right, color: AppColors.error),
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile? profile) {
    final nameController = TextEditingController(text: profile?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (profile != null) {
                context.read<AppState>().updateProfile(
                  profile.copyWith(name: nameController.text),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, UserSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Imperial (lbs, ft, °F)'),
              leading: Radio<String>(
                value: 'imperial',
                groupValue: settings.unitSystem,
                onChanged: (value) {
                  context.read<AppState>().updateSettings(
                    settings.copyWith(unitSystem: value),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Metric (kg, m, °C)'),
              leading: Radio<String>(
                value: 'metric',
                groupValue: settings.unitSystem,
                onChanged: (value) {
                  context.read<AppState>().updateSettings(
                    settings.copyWith(unitSystem: value),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertThresholdDialog(BuildContext context, UserSettings settings) {
    var threshold = settings.minBiteScoreAlert;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          title: const Text('Alert Threshold'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notify when bite score is ${threshold.round()}% or higher',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Slider(
                value: threshold,
                min: 50,
                max: 90,
                divisions: 8,
                activeColor: AppColors.accentOrange,
                onChanged: (value) => setState(() => threshold = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AppState>().updateSettings(
                  settings.copyWith(minBiteScoreAlert: threshold),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your catches and reset settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear data logic would go here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
