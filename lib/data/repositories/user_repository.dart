import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

/// Repository for managing user data.
class UserRepository {
  final SharedPreferences _prefs;

  UserRepository(this._prefs);

  /// Checks if onboarding is complete.
  bool isOnboardingComplete() {
    return _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  /// Marks onboarding as complete.
  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.keyOnboardingComplete, true);
  }

  /// Gets the current user profile.
  UserProfile getProfile() {
    final jsonString = _prefs.getString(AppConstants.keyUserProfile);
    if (jsonString == null) {
      return UserProfile.empty(const Uuid().v4());
    }
    return UserProfile.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Saves the user profile.
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(
      AppConstants.keyUserProfile,
      json.encode(profile.toJson()),
    );
  }

  /// Updates user settings.
  Future<void> updateSettings(UserSettings settings) async {
    final profile = getProfile();
    await saveProfile(profile.copyWith(settings: settings));
  }

  /// Updates user stats.
  Future<void> updateStats(UserStats stats) async {
    final profile = getProfile();
    await saveProfile(profile.copyWith(stats: stats));
  }

  /// Clears all user data.
  Future<void> clearAllData() async {
    await _prefs.remove(AppConstants.keyUserProfile);
    await _prefs.remove(AppConstants.keyOnboardingComplete);
  }
}
