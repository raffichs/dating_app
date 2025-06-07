import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Future<double?> convert(double amount, String from, String to) async {
    final url = Uri.parse(
        'https://api.exchangerate.host/convert?from=$from&to=$to&amount=$amount');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result']?.toDouble();
    } else {
      return null;
    }
  }
}
