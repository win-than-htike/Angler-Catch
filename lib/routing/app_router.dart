import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/app_state.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/catch_log/log_catch_screen.dart';
import 'shell_screen.dart';

/// App router configuration.
class AppRouter {
  static GoRouter router(AppState appState) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isOnboardingComplete = appState.isOnboardingComplete;
        final isOnboarding = state.matchedLocation == '/onboarding';

        if (!isOnboardingComplete && !isOnboarding) {
          return '/onboarding';
        }

        if (isOnboardingComplete && isOnboarding) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: _MapPlaceholder()),
            ),
            GoRoute(
              path: '/forecast',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: _ForecastPlaceholder()),
            ),
            GoRoute(
              path: '/history',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: _HistoryPlaceholder()),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: _ProfilePlaceholder()),
            ),
          ],
        ),
        GoRoute(
          path: '/log-catch',
          builder: (context, state) => const LogCatchScreen(),
        ),
      ],
    );
  }
}

// Placeholder widgets that will be replaced with actual screens in ShellScreen
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ForecastPlaceholder extends StatelessWidget {
  const _ForecastPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _HistoryPlaceholder extends StatelessWidget {
  const _HistoryPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
