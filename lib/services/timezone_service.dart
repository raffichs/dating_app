// lib/services/timezone_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimezoneService {
  static const String apiKey = '9X6XDK6WWVL7'; // 🔑 Replace with your real key
  static const String baseUrl = 'https://api.timezonedb.com/v2.1/get-time-zone';

  static Future<String?> fetchTimezone(double lat, double lng) async {
    final url = Uri.parse(
      '$baseUrl?key=$apiKey&format=json&by=position&lat=$lat&lng=$lng',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['zoneName']; // e.g., "Asia/Jakarta"
      } else {
        print('API error: ${data['message']}');
      }
    } else {
      print('HTTP error: ${response.statusCode}');
    }
    return null;
  }
}
