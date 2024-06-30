import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class OSMService {
  static Future<Map<String, double>?> getCoordinates(
      String street, String houseNumber, String zipCode, String city) async {
    final String query = [
      if (houseNumber.isNotEmpty) houseNumber,
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (zipCode.isNotEmpty) zipCode,
    ].join(', ');

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'lat': double.parse(data[0]['lat']),
          'lon': double.parse(data[0]['lon']),
        };
      }
    }
    return null;
  }

  static Future<String?> getPlaceFromCoordinates(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final displayName = data[0]['display_name'];
        final parts = displayName.split(',');
        if (parts.length >= 2) {
          // Return format: "PLZ, Ort"
          return parts[0].trim() + ', ' + parts[1].trim();
        } else {
          return displayName;
        }
      }
    }
    return null;
  }

  static Future<bool> validateAddress(
      String street, String houseNumber, String zipCode, String city) async {
    final String query = [
      if (houseNumber.isNotEmpty) houseNumber,
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (zipCode.isNotEmpty) zipCode,
    ].join(', ');

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.isNotEmpty;
    } else {
      return false;
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
