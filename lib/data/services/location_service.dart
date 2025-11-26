import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';

/// Service for handling device location.
class LocationService {
  /// Checks if location services are enabled and permissions granted.
  Future<bool> checkPermissions() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      // Handle platform exceptions gracefully
      return false;
    }
  }

  /// Requests location permissions.
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Gets the current device location.
  Future<LatLng> getCurrentLocation() async {
    final hasPermission = await checkPermissions();

    if (!hasPermission) {
      return const LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return const LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      );
    }
  }

  /// Streams location updates.
  Stream<LatLng> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // meters
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  /// Calculates distance between two points in miles.
  double calculateDistance(LatLng from, LatLng to) {
    final distanceInMeters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return distanceInMeters / 1609.34; // Convert to miles
  }

  /// Opens device location settings.
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  /// Opens app settings for permissions.
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }
}
