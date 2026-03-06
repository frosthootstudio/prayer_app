import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Checks permission and returns the current [Position].
  /// Returns null if permission is denied or location service is off.
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      // Fallback to last known position (still useful for prayer calc)
      return Geolocator.getLastKnownPosition();
    }
  }

  /// Returns the city name for the given coordinates using reverse geocoding.
  /// Falls back to "lat, lng" string on any error.
  Future<String> getCityName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 10));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return p.locality?.isNotEmpty == true
            ? p.locality!
            : p.subAdministrativeArea?.isNotEmpty == true
                ? p.subAdministrativeArea!
                : p.administrativeArea ?? _coordString(lat, lng);
      }
    } catch (_) {
      // Network or geocoder not available
    }
    return _coordString(lat, lng);
  }

  String _coordString(double lat, double lng) =>
      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
}
