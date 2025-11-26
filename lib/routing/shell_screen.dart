import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../features/map/map_screen.dart';
import '../features/forecast/forecast_screen.dart';
import '../features/history/history_screen.dart';
import '../features/profile/profile_screen.dart';

/// Main shell with bottom navigation.
class ShellScreen extends StatefulWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  // Screens without FAB placeholder - indices: 0=Map, 1=Forecast, 2=History, 3=Profile
  final List<Widget> _screens = const [
    MapScreen(),
    ForecastScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  // Convert nav bar index (with FAB gap) to screen index
  int _navToScreenIndex(int navIndex) {
    if (navIndex < 2) return navIndex; // Map, Forecast
    if (navIndex > 2) return navIndex - 1; // History(3->2), Profile(4->3)
    return 0; // FAB (shouldn't happen)
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      // Center FAB - Log Catch
      context.push('/log-catch');
      return;
    }

    final screenIndex = _navToScreenIndex(index);
    setState(() => _currentIndex = screenIndex);

    final routes = ['/', '/forecast', '/history', '/profile'];
    context.go(routes[screenIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/log-catch'),
        backgroundColor: AppColors.accentOrange,
        elevation: 8,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.map_outlined, Icons.map, 'Map'),
              _buildNavItem(
                1,
                Icons.auto_graph_outlined,
                Icons.auto_graph,
                'Forecast',
              ),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(
                3,
                Icons.history_outlined,
                Icons.history,
                'History',
              ),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    // Convert nav index to screen index for comparison
    final screenIndex = _navToScreenIndex(index);
    final isSelected = _currentIndex == screenIndex;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentOrange.withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.accentOrange : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.accentOrange
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
