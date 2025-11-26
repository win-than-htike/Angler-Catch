import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/forecast.dart';
import '../models/catch_record.dart';

/// Service for generating AI bite predictions.
class ForecastService {
  final Random _random = Random();

  /// Generates bite forecast based on weather and historical data.
  BiteForecast generateForecast({
    required DateTime date,
    required WeatherForecast weather,
    required List<CatchRecord> historicalCatches,
    required LatLng location,
  }) {
    final hourlyPredictions = _generateHourlyPredictions(date, weather);
    final overallScore = _calculateOverallScore(hourlyPredictions);
    final summary = _generateSummary(overallScore, weather);
    final tips = _generateTips(weather, overallScore);

    return BiteForecast(
      date: date,
      hourlyPredictions: hourlyPredictions,
      overallScore: overallScore,
      summary: summary,
      tips: tips,
    );
  }

  List<HourlyPrediction> _generateHourlyPredictions(
    DateTime date,
    WeatherForecast weather,
  ) {
    return List.generate(24, (hour) {
      final hourTime = DateTime(date.year, date.month, date.day, hour);
      final isSolunarPeak = _isSolunarPeakHour(hour, weather.moonPhase);
      final biteScore = _calculateHourlyScore(
        hour: hour,
        weather: weather,
        isSolunarPeak: isSolunarPeak,
      );

      return HourlyPrediction(
        hour: hourTime,
        biteScore: biteScore,
        temperature: _interpolateTemperature(
          hour,
          weather.tempLow,
          weather.tempHigh,
        ),
        windSpeed: weather.windSpeed + _random.nextDouble() * 3 - 1.5,
        weatherCondition: weather.condition,
        pressure: weather.pressure,
        isSolunarPeak: isSolunarPeak,
      );
    });
  }

  double _calculateHourlyScore({
    required int hour,
    required WeatherForecast weather,
    required bool isSolunarPeak,
  }) {
    var score = 50.0;

    // Time of day factor (dawn/dusk best)
    if (hour >= 5 && hour <= 8) score += 20; // Dawn
    if (hour >= 17 && hour <= 20) score += 20; // Dusk
    if (hour >= 11 && hour <= 14) score -= 10; // Midday less active

    // Pressure factor (stable/rising best)
    if (weather.pressure >= 1010 && weather.pressure <= 1020) {
      score += 15;
    } else if (weather.pressure < 1005 || weather.pressure > 1025) {
      score -= 10;
    }

    // Wind factor (light wind best)
    if (weather.windSpeed < 10) {
      score += 10;
    } else if (weather.windSpeed > 20) {
      score -= 15;
    }

    // Moon phase factor
    final moonScore = _getMoonPhaseScore(weather.moonPhase);
    score += moonScore;

    // Solunar peak bonus
    if (isSolunarPeak) score += 15;

    // Weather condition factor
    score += _getWeatherConditionScore(weather.condition);

    // Add slight randomness
    score += _random.nextDouble() * 10 - 5;

    return score.clamp(0, 100);
  }

  bool _isSolunarPeakHour(int hour, double moonPhase) {
    // Simplified solunar calculation
    // Major periods: moon overhead and underfoot
    // Minor periods: moonrise and moonset
    final majorPeriod1 = (moonPhase * 24).round() % 24;
    final majorPeriod2 = (majorPeriod1 + 12) % 24;
    final minorPeriod1 = (majorPeriod1 + 6) % 24;
    final minorPeriod2 = (majorPeriod1 + 18) % 24;

    return hour == majorPeriod1 ||
        hour == majorPeriod2 ||
        hour == minorPeriod1 ||
        hour == minorPeriod2 ||
        hour == majorPeriod1 + 1 ||
        hour == majorPeriod2 + 1;
  }

  double _getMoonPhaseScore(double phase) {
    // New moon and full moon are considered best
    if (phase < 0.1 || phase > 0.9) return 15; // New moon
    if (phase > 0.4 && phase < 0.6) return 15; // Full moon
    if (phase > 0.2 && phase < 0.3) return 5; // First quarter
    if (phase > 0.7 && phase < 0.8) return 5; // Last quarter
    return 0;
  }

  double _getWeatherConditionScore(String condition) {
    switch (condition.toLowerCase()) {
      case 'cloudy':
      case 'overcast':
        return 10; // Fish more active
      case 'partly cloudy':
        return 5;
      case 'rain':
      case 'light rain':
        return 15; // Often excellent fishing
      case 'sunny':
      case 'clear':
        return -5; // Fish go deeper
      case 'thunderstorm':
      case 'storm':
        return -20; // Dangerous, fish inactive
      default:
        return 0;
    }
  }

  double _interpolateTemperature(int hour, double low, double high) {
    // Temperature peaks around 3pm, lowest around 5am
    final peakHour = 15;
    final lowHour = 5;

    if (hour <= lowHour || hour >= 22) {
      return low + (high - low) * 0.1;
    } else if (hour <= peakHour) {
      final progress = (hour - lowHour) / (peakHour - lowHour);
      return low + (high - low) * progress;
    } else {
      final progress = (hour - peakHour) / (22 - peakHour);
      return high - (high - low) * progress * 0.5;
    }
  }

  double _calculateOverallScore(List<HourlyPrediction> predictions) {
    // Average of top 6 hours
    final scores = predictions.map((p) => p.biteScore).toList()..sort();
    final topScores = scores.reversed.take(6);
    return topScores.reduce((a, b) => a + b) / 6;
  }

  String _generateSummary(double score, WeatherForecast weather) {
    if (score >= 80) {
      return 'Excellent conditions! ${weather.condition} skies with '
          '${weather.moonPhaseName}. Prime time for fishing.';
    } else if (score >= 60) {
      return 'Good fishing conditions expected. '
          '${weather.condition} with moderate activity levels.';
    } else if (score >= 40) {
      return 'Fair conditions. Fish may be less active. '
          'Focus on dawn and dusk periods.';
    } else {
      return 'Challenging conditions. Consider waiting for better weather. '
          '${weather.condition} may reduce fish activity.';
    }
  }

  List<String> _generateTips(WeatherForecast weather, double score) {
    final tips = <String>[];

    // Time-based tips
    tips.add('Best hours: 6-8 AM and 5-7 PM');

    // Weather-based tips
    if (weather.windSpeed > 15) {
      tips.add('High winds - fish sheltered areas and use heavier lures');
    } else if (weather.windSpeed < 5) {
      tips.add('Light wind - try topwater lures early and late');
    }

    // Pressure tips
    if (weather.pressure > 1020) {
      tips.add('High pressure - fish deeper structures');
    } else if (weather.pressure < 1005) {
      tips.add('Low pressure - fish may be more active near surface');
    }

    // Moon tips
    if (weather.moonPhase < 0.1 || weather.moonPhase > 0.9) {
      tips.add('New moon - excellent night fishing potential');
    } else if (weather.moonPhase > 0.4 && weather.moonPhase < 0.6) {
      tips.add('Full moon - try fishing at night or very early morning');
    }

    // Condition tips
    if (weather.condition.toLowerCase().contains('cloud')) {
      tips.add('Overcast skies - fish may stay shallower longer');
    }

    return tips.take(4).toList();
  }

  /// Generates hotspots based on catch history.
  List<Hotspot> generateHotspots(List<CatchRecord> catches) {
    if (catches.isEmpty) return _getMockHotspots();

    // Group catches by approximate location
    final locationGroups = <String, List<CatchRecord>>{};

    for (final catchRecord in catches) {
      final key =
          '${(catchRecord.location.latitude * 100).round()},'
          '${(catchRecord.location.longitude * 100).round()}';
      locationGroups.putIfAbsent(key, () => []).add(catchRecord);
    }

    return locationGroups.entries.map((entry) {
      final groupCatches = entry.value;
      final avgLat =
          groupCatches.map((c) => c.location.latitude).reduce((a, b) => a + b) /
          groupCatches.length;
      final avgLng =
          groupCatches
              .map((c) => c.location.longitude)
              .reduce((a, b) => a + b) /
          groupCatches.length;

      final species = groupCatches.map((c) => c.species).toSet().toList();
      final intensity = (groupCatches.length / catches.length).clamp(0.3, 1.0);

      return Hotspot(
        id: entry.key,
        name: groupCatches.first.locationName ?? 'Hotspot',
        location: LatLng(avgLat, avgLng),
        intensity: intensity,
        species: species,
        recentCatches: groupCatches.length,
        averageScore: 70 + _random.nextDouble() * 20,
      );
    }).toList();
  }

  List<Hotspot> _getMockHotspots() {
    return [
      Hotspot(
        id: '1',
        name: 'Miller\'s Cove',
        location: const LatLng(37.7849, -122.4094),
        intensity: 0.9,
        species: ['Largemouth Bass', 'Bluegill'],
        recentCatches: 15,
        averageScore: 85,
      ),
      Hotspot(
        id: '2',
        name: 'Deep Creek Point',
        location: const LatLng(37.7649, -122.4294),
        intensity: 0.7,
        species: ['Rainbow Trout', 'Brown Trout'],
        recentCatches: 8,
        averageScore: 72,
      ),
      Hotspot(
        id: '3',
        name: 'Sunset Bay',
        location: const LatLng(37.7549, -122.3994),
        intensity: 0.5,
        species: ['Crappie', 'Perch'],
        recentCatches: 5,
        averageScore: 65,
      ),
    ];
  }
}
