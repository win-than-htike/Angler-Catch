/// User profile information.
class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final List<String> preferredSpecies;
  final List<String> preferredBaits;
  final UserSettings settings;
  final UserStats stats;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    this.preferredSpecies = const [],
    this.preferredBaits = const [],
    required this.settings,
    required this.stats,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'preferred_species': preferredSpecies,
        'preferred_baits': preferredBaits,
        'settings': settings.toJson(),
        'stats': stats.toJson(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        preferredSpecies:
            (json['preferred_species'] as List?)?.cast<String>() ?? [],
        preferredBaits:
            (json['preferred_baits'] as List?)?.cast<String>() ?? [],
        settings: json['settings'] != null
            ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
            : const UserSettings(),
        stats: json['stats'] != null
            ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
            : const UserStats(),
      );

  factory UserProfile.empty(String id) => UserProfile(
        id: id,
        settings: const UserSettings(),
        stats: const UserStats(),
      );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    List<String>? preferredSpecies,
    List<String>? preferredBaits,
    UserSettings? settings,
    UserStats? stats,
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        preferredSpecies: preferredSpecies ?? this.preferredSpecies,
        preferredBaits: preferredBaits ?? this.preferredBaits,
        settings: settings ?? this.settings,
        stats: stats ?? this.stats,
      );
}

/// User app settings.
class UserSettings {
  final bool notificationsEnabled;
  final bool locationEnabled;
  final String unitSystem; // 'imperial' or 'metric'
  final int forecastAlertHours; // hours before prime time to notify
  final double minBiteScoreAlert; // minimum score to trigger alert

  const UserSettings({
    this.notificationsEnabled = true,
    this.locationEnabled = true,
    this.unitSystem = 'imperial',
    this.forecastAlertHours = 2,
    this.minBiteScoreAlert = 70,
  });

  Map<String, dynamic> toJson() => {
        'notifications_enabled': notificationsEnabled,
        'location_enabled': locationEnabled,
        'unit_system': unitSystem,
        'forecast_alert_hours': forecastAlertHours,
        'min_bite_score_alert': minBiteScoreAlert,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
        locationEnabled: json['location_enabled'] as bool? ?? true,
        unitSystem: json['unit_system'] as String? ?? 'imperial',
        forecastAlertHours: json['forecast_alert_hours'] as int? ?? 2,
        minBiteScoreAlert: json['min_bite_score_alert'] as double? ?? 70,
      );

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? locationEnabled,
    String? unitSystem,
    int? forecastAlertHours,
    double? minBiteScoreAlert,
  }) =>
      UserSettings(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        locationEnabled: locationEnabled ?? this.locationEnabled,
        unitSystem: unitSystem ?? this.unitSystem,
        forecastAlertHours: forecastAlertHours ?? this.forecastAlertHours,
        minBiteScoreAlert: minBiteScoreAlert ?? this.minBiteScoreAlert,
      );
}

/// User fishing statistics.
class UserStats {
  final int totalCatches;
  final double? biggestCatch; // weight
  final String? mostCaughtSpecies;
  final String? mostUsedBait;
  final int fishingDays;

  const UserStats({
    this.totalCatches = 0,
    this.biggestCatch,
    this.mostCaughtSpecies,
    this.mostUsedBait,
    this.fishingDays = 0,
  });

  Map<String, dynamic> toJson() => {
        'total_catches': totalCatches,
        'biggest_catch': biggestCatch,
        'most_caught_species': mostCaughtSpecies,
        'most_used_bait': mostUsedBait,
        'fishing_days': fishingDays,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalCatches: json['total_catches'] as int? ?? 0,
        biggestCatch: json['biggest_catch'] as double?,
        mostCaughtSpecies: json['most_caught_species'] as String?,
        mostUsedBait: json['most_used_bait'] as String?,
        fishingDays: json['fishing_days'] as int? ?? 0,
      );
}
