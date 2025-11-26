import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/app_state.dart';
import 'data/repositories/catch_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/forecast_service.dart';
import 'data/services/location_service.dart';
import 'data/services/weather_service.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create repositories and services
  final catchRepository = CatchRepository(prefs);
  final userRepository = UserRepository(prefs);
  final locationService = LocationService();
  final weatherService = WeatherService();
  final forecastService = ForecastService();

  // Create app state
  final appState = AppState(
    catchRepository: catchRepository,
    userRepository: userRepository,
    locationService: locationService,
    weatherService: weatherService,
    forecastService: forecastService,
  );

  // Initialize app state if onboarding is complete
  if (userRepository.isOnboardingComplete()) {
    await appState.initialize();
  }

  runApp(AnglerCatchApp(appState: appState));
}

class AnglerCatchApp extends StatelessWidget {
  final AppState appState;

  const AnglerCatchApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, state, child) {
          final router = AppRouter.router(state);

          return MaterialApp.router(
            title: 'Angler Catch',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
