import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Result of a location lookup: a short display line (e.g. "Andheri West,
/// Mumbai") plus raw coordinates in case they're needed later (e.g. to
/// save with an address).
class CurrentLocationResult {
  final String displayAddress;
  final double latitude;
  final double longitude;

  CurrentLocationResult({
    required this.displayAddress,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  /// Requests permission (if needed), fetches the device's current GPS
  /// position, and reverse-geocodes it into a short human-readable address.
  /// Throws a descriptive Exception if permission is denied or location
  /// services are off, so the caller can show a helpful message.
  static Future<CurrentLocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are turned off. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Please enable it from app settings.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    String display = 'Current location';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.subLocality, p.locality, p.administrativeArea]
            .where((s) => s != null && s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) {
          display = parts.join(', ');
        }
      }
    } catch (_) {
      // Reverse geocoding failed (e.g. no internet) — fall back to a
      // generic label; the coordinates are still returned and usable.
    }

    return CurrentLocationResult(
      displayAddress: display,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
