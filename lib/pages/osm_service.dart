import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OSMService {
  static Future<bool> validateAddress(String street, String houseNumber, String zipCode, String city) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?street=$houseNumber $street&city=$city&postalcode=$zipCode&format=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.isNotEmpty;
    } else {
      return false;
    }
  }

  static Future<Map<String, double>?> getCoordinates(String street, String houseNumber, String zipCode, String city) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?street=$houseNumber $street&city=$city&postalcode=$zipCode&format=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      if (data.isNotEmpty) {
        final firstResult = data.first;
        final lat = double.parse(firstResult['lat']);
        final lon = double.parse(firstResult['lon']);
        return {'lat': lat, 'lon': lon};
      }
    }
    return null;
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // Erdradius in Kilometern
    final dLat = _degreeToRadian(lat2 - lat1);
    final dLon = _degreeToRadian(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) * cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Abstand in Kilometern
  }

  static double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}
