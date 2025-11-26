import 'package:angler_catch/data/models/catch_record.dart';
import 'package:angler_catch/data/models/forecast.dart';
import 'package:angler_catch/data/models/user_profile.dart';
import 'package:angler_catch/data/providers/app_state.dart';
import 'package:angler_catch/data/services/photo_service.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class MockAppState extends ChangeNotifier implements AppState {
  MockAppState();

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  LatLng? get currentLocation => const LatLng(37.7749, -122.4194);

  @override
  List<BiteForecast> get biteForecast => [_createMockForecast()];

  @override
  List<WeatherForecast> get weatherForecast => [_createMockWeather()];

  @override
  List<CatchRecord> get catches => [];

  @override
  List<Hotspot> get hotspots => [];

  @override
  UserProfile? get userProfile => null;

  @override
  bool get isOnboardingComplete => true;

  @override
  PhotoService get photoService => PhotoService();

  @override
  Future<void> refreshForecasts() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<void> addCatch(CatchRecord catchRecord) async {}

  @override
  Future<void> deleteCatch(String id) async {}

  @override
  Future<void> updateProfile(UserProfile profile) async {}

  @override
  Future<void> updateSettings(UserSettings settings) async {}

  @override
  Future<void> refreshLocation() async {}

  @override
  List<CatchRecord> getCatchesForDate(DateTime date) => [];

  @override
  HourlyPrediction? getBestBiteTime() {
    if (biteForecast.isEmpty) return null;
    return biteForecast.first.hourlyPredictions.first;
  }

  BiteForecast _createMockForecast() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final hourlyPredictions = List.generate(24, (index) {
      final hour = startOfDay.add(Duration(hours: index));
      final isSolunarPeak = index == 6 || index == 18;
      return HourlyPrediction(
        hour: hour,
        biteScore: 50.0 + (index % 5) * 10,
        temperature: 72.0,
        windSpeed: 5.0,
        weatherCondition: 'Partly Cloudy',
        pressure: 1013.0,
        isSolunarPeak: isSolunarPeak,
      );
    });

    return BiteForecast(
      date: startOfDay,
      hourlyPredictions: hourlyPredictions,
      overallScore: 75.0,
      summary: 'Good fishing conditions expected',
      tips: ['Fish early morning', 'Use live bait'],
    );
  }

  WeatherForecast _createMockWeather() {
    final now = DateTime.now();
    return WeatherForecast(
      date: now,
      tempHigh: 78.0,
      tempLow: 65.0,
      condition: 'Partly Cloudy',
      icon: '02d',
      windSpeed: 8.0,
      humidity: 65,
      pressure: 1015.0,
      sunrise: DateTime(now.year, now.month, now.day, 6, 30),
      sunset: DateTime(now.year, now.month, now.day, 19, 45),
      moonPhase: 0.5,
      moonPhaseName: 'Full Moon',
    );
  }
}
