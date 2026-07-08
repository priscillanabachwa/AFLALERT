import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Resolves the device's current location into a short, human-readable
  /// place name (e.g. "Kampala, Uganda"). Returns `null` if location
  /// services/permissions aren't available or resolution fails for any
  /// reason — callers should treat location tagging as best-effort.
  Future<String?> getCurrentPlaceName() async {
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

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isEmpty) return null;

      final Placemark place = placemarks.first;
      final String name = [place.locality, place.subAdministrativeArea, place.country]
          .where((part) => part != null && part.trim().isNotEmpty)
          .join(', ');

      return name.isEmpty ? null : name;
    } catch (error) {
      debugPrint('LocationService Error resolving place name: $error');
      return null;
    }
  }
}
