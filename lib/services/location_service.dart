import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'nominatim_service.dart';

class CurrentLocationResult {
  final double latitude;
  final double longitude;
  final String displayAddress;

  CurrentLocationResult({
    required this.latitude,
    required this.longitude,
    required this.displayAddress,
  });
}

class LocationService {
  static Timer? _timer;

  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  static Future<CurrentLocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Please turn on location services to detect your address.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Enable it from app settings.');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final reverse = await NominatimService.reverseGeocode(pos.latitude, pos.longitude);
    final address = reverse.cityLine.isNotEmpty
        ? reverse.cityLine
        : (reverse.streetLine.isNotEmpty ? reverse.streetLine : 'Current Location');

    return CurrentLocationResult(
      latitude: pos.latitude,
      longitude: pos.longitude,
      displayAddress: address,
    );
  }

  static void startTracking() {
    _timer?.cancel();
    _sendCurrentLocation();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendCurrentLocation();
    });
  }

  static void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _sendCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await ApiService.updateLocation(pos.latitude, pos.longitude);
    } catch (_) {
      // Silently skip a failed location update; next timer tick will retry.
    }
  }
}