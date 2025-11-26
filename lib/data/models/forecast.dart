import 'package:latlong2/latlong.dart';

/// Bite prediction forecast.
class BiteForecast {
  final DateTime date;
  final List<HourlyPrediction> hourlyPredictions;
  final double overallScore; // 0-100
  final String summary;
  final List<String> tips;

  const BiteForecast({
    required this.date,
    required this.hourlyPredictions,
    required this.overallScore,
    required this.summary,
    required this.tips,
  });

  String get ratingLabel {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    if (overallScore >= 40) return 'Fair';
    if (overallScore >= 20) return 'Poor';
    return 'Very Poor';
  }
}

/// Hourly bite prediction.
class HourlyPrediction {
  final DateTime hour;
  final double biteScore; // 0-100
  final double temperature;
  final double windSpeed;
  final String weatherCondition;
  final double pressure;
  final bool isSolunarPeak;

  const HourlyPrediction({
    required this.hour,
    required this.biteScore,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCondition,
    required this.pressure,
    required this.isSolunarPeak,
  });
}

/// Fishing hotspot location.
class Hotspot {
  final String id;
  final String name;
  final LatLng location;
  final double intensity; // 0-1
  final List<String> species;
  final int recentCatches;
  final double averageScore;

  const Hotspot({
    required this.id,
    required this.name,
    required this.location,
    required this.intensity,
    required this.species,
    required this.recentCatches,
    required this.averageScore,
  });
}

/// Weather forecast data.
class WeatherForecast {
  final DateTime date;
  final double tempHigh;
  final double tempLow;
  final String condition;
  final String icon;
  final double windSpeed;
  final int humidity;
  final double pressure;
  final DateTime? sunrise;
  final DateTime? sunset;
  final double moonPhase;
  final String moonPhaseName;

  const WeatherForecast({
    required this.date,
    required this.tempHigh,
    required this.tempLow,
    required this.condition,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    this.sunrise,
    this.sunset,
    required this.moonPhase,
    required this.moonPhaseName,
  });

  factory WeatherForecast.fromOpenWeather(Map<String, dynamic> json) {
    final temp = json['temp'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return WeatherForecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      tempHigh: (temp['max'] as num).toDouble(),
      tempLow: (temp['min'] as num).toDouble(),
      condition: weather['main'] as String,
      icon: weather['icon'] as String,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      humidity: json['humidity'] as int,
      pressure: (json['pressure'] as num).toDouble(),
      sunrise: json['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['sunrise'] as int) * 1000)
          : null,
      sunset: json['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['sunset'] as int) * 1000)
          : null,
      moonPhase: (json['moon_phase'] as num).toDouble(),
      moonPhaseName: _getMoonPhaseName((json['moon_phase'] as num).toDouble()),
    );
  }

  static String _getMoonPhaseName(double phase) {
    if (phase == 0 || phase == 1) return 'New Moon';
    if (phase < 0.25) return 'Waxing Crescent';
    if (phase == 0.25) return 'First Quarter';
    if (phase < 0.5) return 'Waxing Gibbous';
    if (phase == 0.5) return 'Full Moon';
    if (phase < 0.75) return 'Waning Gibbous';
    if (phase == 0.75) return 'Last Quarter';
    return 'Waning Crescent';
  }
}
