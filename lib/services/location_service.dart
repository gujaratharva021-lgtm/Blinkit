import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CurrentLocationResult {
  final String displayAddress;
  final double latitude;
  final double longitude;
  final String streetLine;
  final String cityLine;

  CurrentLocationResult({
    required this.displayAddress,
    required this.latitude,
    required this.longitude,
    this.streetLine = '',
    this.cityLine = '',
  });
}

class LocationService {
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
    String streetLine = '';
    String cityLine = '';
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

        streetLine = [p.subThoroughfare, p.thoroughfare, p.subLocality]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        if (streetLine.isEmpty && p.name != null && p.name!.isNotEmpty) {
          streetLine = p.name!;
        }

        cityLine = [p.locality, p.administrativeArea, p.postalCode]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
      }
    } catch (_) {
      // Reverse geocoding failed - fall back to a generic label.
    }

    return CurrentLocationResult(
      displayAddress: display,
      latitude: position.latitude,
      longitude: position.longitude,
      streetLine: streetLine,
      cityLine: cityLine,
    );
  }
}