import 'package:flutter/foundation.dart';
import 'package:angler_catch/data/models/forecast.dart';
import 'package:angler_catch/data/providers/app_state.dart';

/// Mock implementation of AppState for testing.
class MockAppState extends ChangeNotifier implements AppState {
  MockAppState() {
    _biteForecast = _generateMockBiteForecast();
    _weatherForecast = _generateMockWeatherForecast();
  }

  List<BiteForecast> _biteForecast = [];
  List<WeatherForecast> _weatherForecast = [];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<BiteForecast> get biteForecast => _biteForecast;

  @override
  List<WeatherForecast> get weatherForecast => _weatherForecast;

  @override
  HourlyPrediction? getBestBiteTime() {
    if (_biteForecast.isEmpty) return null;
    final today = _biteForecast.first;
    return today.hourlyPredictions.reduce(
      (a, b) => a.biteScore > b.biteScore ? a : b,
    );
  }

  @override
  Future<void> refreshForecasts() async {
    notifyListeners();
  }

  /// Generates mock bite forecast with 24 hourly predictions.
  List<BiteForecast> _generateMockBiteForecast() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (dayIndex) {
      final date = today.add(Duration(days: dayIndex));
      return BiteForecast(
        date: date,
        hourlyPredictions: List.generate(24, (hourIndex) {
          final hour = DateTime(date.year, date.month, date.day, hourIndex);
          // Create varied bite scores with peaks around 6am and 6pm
          final baseScore = 40.0;
          final morningBoost = (hourIndex >= 5 && hourIndex <= 8) ? 30.0 : 0.0;
          final eveningBoost = (hourIndex >= 17 && hourIndex <= 20)
              ? 25.0
              : 0.0;
          final score = (baseScore + morningBoost + eveningBoost).clamp(
            0.0,
            100.0,
          );

          // Mark 6am and 6pm as solunar peaks
          final isSolunarPeak = hourIndex == 6 || hourIndex == 18;

          return HourlyPrediction(
            hour: hour,
            biteScore: score,
            temperature: 72.0 + (hourIndex - 12).abs() * 0.5,
            windSpeed: 5.0 + hourIndex % 5,
            weatherCondition: 'Partly Cloudy',
            pressure: 1013.0,
            isSolunarPeak: isSolunarPeak,
          );
        }),
        overallScore: 65.0 + dayIndex * 2,
        summary: 'Good fishing conditions expected.',
        tips: ['Fish early morning', 'Use live bait'],
      );
    });
  }

  List<WeatherForecast> _generateMockWeatherForecast() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (dayIndex) {
      final date = today.add(Duration(days: dayIndex));
      return WeatherForecast(
        date: date,
        tempHigh: 78.0 + dayIndex,
        tempLow: 62.0 + dayIndex,
        condition: 'Partly Cloudy',
        icon: '02d',
        windSpeed: 8.0,
        humidity: 65,
        pressure: 1015.0,
        moonPhase: 0.25,
        moonPhaseName: 'First Quarter',
      );
    });
  }

  // Stub implementations for unused properties/methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
