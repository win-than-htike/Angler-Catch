import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/angler_button.dart';
import '../../data/providers/app_state.dart';
import '../../data/services/location_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.phishing,
      title: 'Welcome to Angler Catch',
      description:
          'Your AI-powered fishing companion for logging catches and predicting the best bite times.',
      color: AppColors.primaryGreen,
    ),
    OnboardingPage(
      icon: Icons.map_outlined,
      title: 'Discover Hotspots',
      description:
          'Find the best fishing locations with our intelligent hotspot map based on weather and catch data.',
      color: AppColors.waterBlue,
    ),
    OnboardingPage(
      icon: Icons.auto_graph,
      title: 'AI Bite Predictions',
      description:
          'Get accurate forecasts for the best fishing times based on weather, moon phase, and local patterns.',
      color: AppColors.accentOrange,
    ),
    OnboardingPage(
      icon: Icons.location_on,
      title: 'Enable Location',
      description:
          'Allow location access to get personalized forecasts and log your catches accurately.',
      color: AppColors.primaryBrown,
      isLocationPage: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final appState = context.read<AppState>();
    await appState.completeOnboarding();
    await appState.initialize();
  }

  Future<void> _requestLocationPermission() async {
    final locationService = LocationService();
    final hasPermission = await locationService.checkPermissions();

    if (hasPermission) {
      await _completeOnboarding();
    } else {
      final permission = await locationService.requestPermission();
      if (mounted) {
        if (permission.name.contains('denied')) {
          _showLocationDeniedDialog();
        } else {
          await _completeOnboarding();
        }
      }
    }
  }

  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Location Required'),
        content: const Text(
          'Location access is needed for accurate forecasts. '
          'You can enable it later in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _completeOnboarding();
            },
            child: const Text('Skip for Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              LocationService().openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildIndicators(),
            _buildButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppColors.accentOrange
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    final isLastPage = _currentPage == _pages.length - 1;
    final page = _pages[_currentPage];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: AnglerButton(
              label: page.isLocationPage
                  ? 'Enable Location'
                  : (isLastPage ? 'Get Started' : 'Next'),
              icon: page.isLocationPage ? Icons.location_on : null,
              onPressed: page.isLocationPage
                  ? _requestLocationPermission
                  : (isLastPage ? _completeOnboarding : _nextPage),
            ),
          ),
          if (_currentPage > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AnglerButton(
                label: 'Back',
                isOutlined: true,
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLocationPage;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isLocationPage = false,
  });
}
