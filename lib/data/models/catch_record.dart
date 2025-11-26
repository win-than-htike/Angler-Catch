import 'package:latlong2/latlong.dart';

/// Represents a fishing catch record.
class CatchRecord {
  final String id;
  final String species;
  final double? weight; // in pounds
  final double? length; // in inches
  final String baitUsed;
  final double? depth; // in feet
  final DateTime timestamp;
  final LatLng location;
  final String? locationName;
  final WeatherSnapshot? weather;
  final WaterConditions? waterConditions;
  final String? notes;
  final String? photoUrl;

  const CatchRecord({
    required this.id,
    required this.species,
    this.weight,
    this.length,
    required this.baitUsed,
    this.depth,
    required this.timestamp,
    required this.location,
    this.locationName,
    this.weather,
    this.waterConditions,
    this.notes,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'species': species,
        'weight': weight,
        'length': length,
        'bait_used': baitUsed,
        'depth': depth,
        'timestamp': timestamp.toIso8601String(),
        'latitude': location.latitude,
        'longitude': location.longitude,
        'location_name': locationName,
        'weather': weather?.toJson(),
        'water_conditions': waterConditions?.toJson(),
        'notes': notes,
        'photo_url': photoUrl,
      };

  factory CatchRecord.fromJson(Map<String, dynamic> json) => CatchRecord(
        id: json['id'] as String,
        species: json['species'] as String,
        weight: json['weight'] as double?,
        length: json['length'] as double?,
        baitUsed: json['bait_used'] as String,
        depth: json['depth'] as double?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        location: LatLng(
          json['latitude'] as double,
          json['longitude'] as double,
        ),
        locationName: json['location_name'] as String?,
        weather: json['weather'] != null
            ? WeatherSnapshot.fromJson(json['weather'] as Map<String, dynamic>)
            : null,
        waterConditions: json['water_conditions'] != null
            ? WaterConditions.fromJson(
                json['water_conditions'] as Map<String, dynamic>)
            : null,
        notes: json['notes'] as String?,
        photoUrl: json['photo_url'] as String?,
      );

  CatchRecord copyWith({
    String? id,
    String? species,
    double? weight,
    double? length,
    String? baitUsed,
    double? depth,
    DateTime? timestamp,
    LatLng? location,
    String? locationName,
    WeatherSnapshot? weather,
    WaterConditions? waterConditions,
    String? notes,
    String? photoUrl,
  }) =>
      CatchRecord(
        id: id ?? this.id,
        species: species ?? this.species,
        weight: weight ?? this.weight,
        length: length ?? this.length,
        baitUsed: baitUsed ?? this.baitUsed,
        depth: depth ?? this.depth,
        timestamp: timestamp ?? this.timestamp,
        location: location ?? this.location,
        locationName: locationName ?? this.locationName,
        weather: weather ?? this.weather,
        waterConditions: waterConditions ?? this.waterConditions,
        notes: notes ?? this.notes,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}

/// Weather conditions at time of catch.
class WeatherSnapshot {
  final double temperature; // Fahrenheit
  final double humidity; // percentage
  final double windSpeed; // mph
  final String windDirection;
  final double pressure; // hPa
  final String condition;
  final double? moonPhase; // 0-1

  const WeatherSnapshot({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.condition,
    this.moonPhase,
  });

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'wind_speed': windSpeed,
        'wind_direction': windDirection,
        'pressure': pressure,
        'condition': condition,
        'moon_phase': moonPhase,
      };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) =>
      WeatherSnapshot(
        temperature: (json['temperature'] as num).toDouble(),
        humidity: (json['humidity'] as num).toDouble(),
        windSpeed: (json['wind_speed'] as num).toDouble(),
        windDirection: json['wind_direction'] as String,
        pressure: (json['pressure'] as num).toDouble(),
        condition: json['condition'] as String,
        moonPhase: json['moon_phase'] as double?,
      );
}

/// Water conditions at fishing spot.
class WaterConditions {
  final double? temperature; // Fahrenheit
  final String clarity;
  final double? level; // relative level

  const WaterConditions({
    this.temperature,
    required this.clarity,
    this.level,
  });

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'clarity': clarity,
        'level': level,
      };

  factory WaterConditions.fromJson(Map<String, dynamic> json) =>
      WaterConditions(
        temperature: json['temperature'] as double?,
        clarity: json['clarity'] as String,
        level: json['level'] as double?,
      );
}
