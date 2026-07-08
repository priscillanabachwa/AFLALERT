import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? placeName;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.placeName,
  });
}

class LocationService {
  /// Resolves the device's current coordinates plus a short, human-readable
  /// place name (e.g. "Kampala, Wakiso, Uganda"). Returns `null` if location
  /// services/permissions aren't available or resolution fails for any
  /// reason — callers should treat location as best-effort.
  Future<LocationResult?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('LocationService: Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Location permission not granted.');
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 10));

      String? placeName;
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          final String name = [place.locality, place.subAdministrativeArea, place.country]
              .where((part) => part != null && part.trim().isNotEmpty)
              .join(', ');
          placeName = name.isEmpty ? null : name;
        }
      } catch (error) {
        debugPrint('LocationService Error resolving place name: $error');
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: placeName,
      );
    } catch (error) {
      debugPrint('LocationService Error resolving location: $error');
      return null;
    }
  }

  /// Convenience wrapper for callers that only need the place name.
  Future<String?> getCurrentPlaceName() async {
    final LocationResult? result = await getCurrentLocation();
    return result?.placeName;
  }
}
