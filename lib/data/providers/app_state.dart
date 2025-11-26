import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/catch_record.dart';
import '../models/forecast.dart';
import '../models/user_profile.dart';
import '../repositories/catch_repository.dart';
import '../repositories/user_repository.dart';
import '../services/forecast_service.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../services/weather_service.dart';

/// Main application state provider.
class AppState extends ChangeNotifier {
  final CatchRepository _catchRepository;
  final UserRepository _userRepository;
  final LocationService _locationService;
  final WeatherService _weatherService;
  final ForecastService _forecastService;
  final PhotoService _photoService;

  AppState({
    required CatchRepository catchRepository,
    required UserRepository userRepository,
    required LocationService locationService,
    required WeatherService weatherService,
    required ForecastService forecastService,
    PhotoService? photoService,
  }) : _catchRepository = catchRepository,
       _userRepository = userRepository,
       _locationService = locationService,
       _weatherService = weatherService,
       _forecastService = forecastService,
       _photoService = photoService ?? PhotoService();

  // State
  bool _isLoading = false;
  String? _error;
  LatLng? _currentLocation;
  List<CatchRecord> _catches = [];
  List<WeatherForecast> _weatherForecast = [];
  List<BiteForecast> _biteForecast = [];
  List<Hotspot> _hotspots = [];
  UserProfile? _userProfile;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  LatLng? get currentLocation => _currentLocation;
  List<CatchRecord> get catches => _catches;
  List<WeatherForecast> get weatherForecast => _weatherForecast;
  List<BiteForecast> get biteForecast => _biteForecast;
  List<Hotspot> get hotspots => _hotspots;
  UserProfile? get userProfile => _userProfile;

  bool get isOnboardingComplete => _userRepository.isOnboardingComplete();

  /// Initializes the app state.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = _userRepository.getProfile();
      _catches = _catchRepository.getAllCatches();
      await _loadLocation();
      await _loadForecasts();
      _hotspots = _forecastService.generateHotspots(_catches);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLocation() async {
    _currentLocation = await _locationService.getCurrentLocation();
  }

  Future<void> _loadForecasts() async {
    if (_currentLocation == null) return;

    try {
      _weatherForecast = _weatherService.getMockForecast();

      _biteForecast = _weatherForecast.map((weather) {
        return _forecastService.generateForecast(
          date: weather.date,
          weather: weather,
          historicalCatches: _catches,
          location: _currentLocation!,
        );
      }).toList();
    } catch (e) {
      _weatherForecast = _weatherService.getMockForecast();
    }
  }

  /// Completes onboarding.
  Future<void> completeOnboarding() async {
    await _userRepository.completeOnboarding();
    notifyListeners();
  }

  /// Adds a new catch record.
  Future<void> addCatch(CatchRecord catchRecord) async {
    await _catchRepository.addCatch(catchRecord);
    _catches = _catchRepository.getAllCatches();
    _hotspots = _forecastService.generateHotspots(_catches);

    // Update stats
    final stats = _catchRepository.getStatistics();
    await _userRepository.updateStats(
      UserStats(
        totalCatches: stats['totalCatches'] as int,
        biggestCatch: stats['biggestCatch'] as double?,
        mostCaughtSpecies: stats['mostCaughtSpecies'] as String?,
        mostUsedBait: stats['mostUsedBait'] as String?,
        fishingDays: stats['fishingDays'] as int,
      ),
    );
    _userProfile = _userRepository.getProfile();

    notifyListeners();
  }

  /// Deletes a catch record.
  Future<void> deleteCatch(String id) async {
    // Find the catch to get its photo path before deleting
    final catchToDelete = _catches.firstWhere(
      (c) => c.id == id,
      orElse: () => throw StateError('Catch not found'),
    );

    // Delete associated photo if it exists
    if (catchToDelete.photoUrl != null) {
      await _photoService.deletePhoto(catchToDelete.photoUrl);
    }

    await _catchRepository.deleteCatch(id);
    _catches = _catchRepository.getAllCatches();
    _hotspots = _forecastService.generateHotspots(_catches);
    notifyListeners();
  }

  /// Updates user profile.
  Future<void> updateProfile(UserProfile profile) async {
    await _userRepository.saveProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  /// Updates user settings.
  Future<void> updateSettings(UserSettings settings) async {
    await _userRepository.updateSettings(settings);
    _userProfile = _userRepository.getProfile();
    notifyListeners();
  }

  /// Refreshes location.
  Future<void> refreshLocation() async {
    _currentLocation = await _locationService.getCurrentLocation();
    await _loadForecasts();
    notifyListeners();
  }

  /// Refreshes forecasts.
  Future<void> refreshForecasts() async {
    _isLoading = true;
    notifyListeners();

    await _loadForecasts();

    _isLoading = false;
    notifyListeners();
  }

  /// Gets catches for a specific date.
  List<CatchRecord> getCatchesForDate(DateTime date) {
    return _catches.where((c) {
      return c.timestamp.year == date.year &&
          c.timestamp.month == date.month &&
          c.timestamp.day == date.day;
    }).toList();
  }

  /// Gets the best bite time for today.
  HourlyPrediction? getBestBiteTime() {
    if (_biteForecast.isEmpty) return null;
    final today = _biteForecast.first;
    return today.hourlyPredictions.reduce(
      (a, b) => a.biteScore > b.biteScore ? a : b,
    );
  }
}
