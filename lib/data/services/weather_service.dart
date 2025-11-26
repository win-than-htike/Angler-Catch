import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';
import '../models/forecast.dart';

/// Service for fetching weather data from OpenWeather API.
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches current weather for a location.
  Future<Map<String, dynamic>> getCurrentWeather(LatLng location) async {
    final url = Uri.parse(
      '${AppConstants.openWeatherBaseUrl}/weather'
      '?lat=${location.latitude}'
      '&lon=${location.longitude}'
      '&appid=${AppConstants.openWeatherApiKey}'
      '&units=imperial',
    );

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }

    throw WeatherServiceException(
      'Failed to fetch weather: ${response.statusCode}',
    );
  }

  /// Fetches 7-day forecast with daily data.
  Future<List<WeatherForecast>> getWeeklyForecast(LatLng location) async {
    final url = Uri.parse(
      '${AppConstants.openWeatherBaseUrl}/onecall'
      '?lat=${location.latitude}'
      '&lon=${location.longitude}'
      '&appid=${AppConstants.openWeatherApiKey}'
      '&units=imperial'
      '&exclude=minutely,hourly,alerts',
    );

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final daily = data['daily'] as List;

      return daily
          .map((day) =>
              WeatherForecast.fromOpenWeather(day as Map<String, dynamic>))
          .toList();
    }

    throw WeatherServiceException(
      'Failed to fetch forecast: ${response.statusCode}',
    );
  }

  /// Generates mock forecast data for demo purposes.
  List<WeatherForecast> getMockForecast() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return WeatherForecast(
        date: date,
        tempHigh: 75 + (index % 3) * 5.0,
        tempLow: 55 + (index % 3) * 3.0,
        condition: ['Sunny', 'Partly Cloudy', 'Cloudy'][index % 3],
        icon: ['01d', '02d', '03d'][index % 3],
        windSpeed: 5 + index * 2.0,
        humidity: 50 + index * 5,
        pressure: 1013 + index.toDouble(),
        sunrise: DateTime(date.year, date.month, date.day, 6, 30),
        sunset: DateTime(date.year, date.month, date.day, 19, 45),
        moonPhase: (index * 0.125) % 1.0,
        moonPhaseName: _getMoonPhaseNames()[index % 8],
      );
    });
  }

  List<String> _getMoonPhaseNames() => [
        'New Moon',
        'Waxing Crescent',
        'First Quarter',
        'Waxing Gibbous',
        'Full Moon',
        'Waning Gibbous',
        'Last Quarter',
        'Waning Crescent',
      ];

  void dispose() {
    _client.close();
  }
}

class WeatherServiceException implements Exception {
  final String message;
  WeatherServiceException(this.message);

  @override
  String toString() => 'WeatherServiceException: $message';
}
