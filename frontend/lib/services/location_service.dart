
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Checks whether GPS is enabled and requests location permission.
  Future<void> checkLocationPermission() async {
    // Check whether location services are enabled.
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable GPS.',
      );
    }

    // Check current permission.
    LocationPermission permission =
        await Geolocator.checkPermission();

    // Request permission if denied.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission was denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it in app settings.',
      );
    }
  }

  /// Returns a stream of GPS position updates.
  Future<Stream<Position>> getPositionStream() async {
    await checkLocationPermission();

    final locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    intervalDuration: const Duration(seconds: 1),
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// Converts speed from metres per second to kilometres per hour.
  double convertSpeedToKmh(double speedInMetersPerSecond) {
    return speedInMetersPerSecond * 3.6;
  }

  /// Calculates distance between two GPS coordinates in metres.
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
