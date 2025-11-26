/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Angler Catch';
  static const String appVersion = '1.0.0';

  // API Keys (replace with actual keys)
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String mapboxAccessToken = 'YOUR_MAPBOX_ACCESS_TOKEN';

  // API Endpoints
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String mapboxStyleUrl =
      'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}';

  // Storage keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserProfile = 'user_profile';
  static const String keyLocationEnabled = 'location_enabled';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Default values
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 12.0;

  // Fish species (common freshwater)
  static const List<String> fishSpecies = [
    'Largemouth Bass',
    'Smallmouth Bass',
    'Striped Bass',
    'Rainbow Trout',
    'Brown Trout',
    'Brook Trout',
    'Walleye',
    'Northern Pike',
    'Musky',
    'Channel Catfish',
    'Blue Catfish',
    'Crappie',
    'Bluegill',
    'Perch',
    'Carp',
    'Salmon',
    'Steelhead',
    'Other',
  ];

  // Bait types
  static const List<String> baitTypes = [
    'Live Worm',
    'Minnow',
    'Crawfish',
    'Shad',
    'Nightcrawler',
    'Leech',
    'Cricket',
    'Artificial Worm',
    'Crankbait',
    'Spinnerbait',
    'Jig',
    'Topwater Lure',
    'Fly',
    'Spoon',
    'Swimbait',
    'PowerBait',
    'Other',
  ];

  // Weather conditions
  static const List<String> weatherConditions = [
    'Sunny',
    'Partly Cloudy',
    'Cloudy',
    'Overcast',
    'Light Rain',
    'Heavy Rain',
    'Foggy',
    'Windy',
    'Stormy',
  ];

  // Water clarity options
  static const List<String> waterClarity = [
    'Crystal Clear',
    'Clear',
    'Slightly Stained',
    'Stained',
    'Muddy',
  ];
}
