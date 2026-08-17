import 'dart:convert';
import 'package:http/http.dart' as http;

/// A single search suggestion returned by Nominatim (OpenStreetMap's free
/// geocoding service - no API key or billing required).
class PlaceSuggestion {
  final String displayName;
  final double lat;
  final double lng;

  PlaceSuggestion({
    required this.displayName,
    required this.lat,
    required this.lng,
  });
}

/// Result of reverse-geocoding a lat/lng into an address, split into the
/// same streetLine/cityLine shape LocationService uses, so both flows
/// (GPS current-location and manual map pin) feed the address form the
/// same way.
class ReverseGeocodeResult {
  final String streetLine;
  final String cityLine;

  ReverseGeocodeResult({this.streetLine = '', this.cityLine = ''});
}

/// Thin wrapper around the public Nominatim API (openstreetmap.org). Free
/// and keyless, but usage-policy-limited to ~1 request/second and requires
/// identifying the app via a User-Agent header - both handled below.
///
/// https://operations.osmfoundation.org/policies/nominatim/
class NominatimService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org';

  // Nominatim's usage policy requires a descriptive User-Agent so they can
  // contact the app owner if usage is misbehaving. Update the contact
  // email before shipping to production.
  static const _headers = {
    'User-Agent': 'GoFreshApp/1.0 (contact: support@gofresh.app)',
  };

  /// Searches for places matching [query], biased toward India. Returns an
  /// empty list on any network/parse error rather than throwing, since this
  /// backs live search-as-you-type and a transient failure shouldn't crash
  /// the picker.
  static Future<List<PlaceSuggestion>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': query,
        'format': 'jsonv2',
        'limit': '6',
        'countrycodes': 'in',
      });
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return PlaceSuggestion(
          displayName: item['display_name'] as String? ?? '',
          lat: double.parse(item['lat'] as String),
          lng: double.parse(item['lon'] as String),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Reverse-geocodes [lat]/[lng] into a street line and city line.
  /// Returns blank lines (not an exception) on failure - the caller falls
  /// back to letting the user type the address manually.
  static Future<ReverseGeocodeResult> reverseGeocode(
      double lat, double lng) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'jsonv2',
      });
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return ReverseGeocodeResult();

      final Map<String, dynamic> data = jsonDecode(response.body);
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final streetParts = [
        address['house_number'],
        address['road'],
        address['suburb'] ?? address['neighbourhood'],
      ].where((s) => s != null && s.toString().isNotEmpty).map((s) => s.toString()).toList();
      String streetLine = streetParts.join(', ');
      if (streetLine.isEmpty) {
        streetLine = data['display_name'] as String? ?? '';
      }

      final cityParts = [
        address['city'] ?? address['town'] ?? address['village'],
        address['state'],
        address['postcode'],
      ].where((s) => s != null && s.toString().isNotEmpty).map((s) => s.toString()).toList();
      final cityLine = cityParts.join(', ');

      return ReverseGeocodeResult(streetLine: streetLine, cityLine: cityLine);
    } catch (_) {
      return ReverseGeocodeResult();
    }
  }
}