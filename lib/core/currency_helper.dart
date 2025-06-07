import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<String> getUserCurrency() async {
  Position position = await _determinePosition();

  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  Placemark place = placemarks[0];

  final country = place.country;

  // Manual mapping
  final countryToCurrencyMap = {
    'Indonesia': 'IDR',
    'Japan': 'JPY',
    'United States': 'USD',
    'United Kingdom': 'GBP',
    'Germany': 'EUR',
    'France': 'EUR',
    'India': 'INR',
    'Australia': 'AUD',
    'Canada': 'CAD',
    'China': 'CNY',
    'South Korea': 'KRW',
    'Russia': 'RUB',
    'Brazil': 'BRL',
    'Mexico': 'MXN',
    'Italy': 'EUR',
    'Spain': 'EUR',
    'Netherlands': 'EUR',
    'Sweden': 'SEK',
    'Switzerland': 'CHF',
    'Norway': 'NOK',
    'Turkey': 'TRY',
    'Thailand': 'THB',
    'Philippines': 'PHP',
    'Malaysia': 'MYR',
    'Singapore': 'SGD',
    'Vietnam': 'VND',
    'Argentina': 'ARS',
    'South Africa': 'ZAR',
    'New Zealand': 'NZD',
    'Saudi Arabia': 'SAR',
    'United Arab Emirates': 'AED',
    'Egypt': 'EGP',
    'Nigeria': 'NGN',
    'Pakistan': 'PKR',
    'Bangladesh': 'BDT',
    'Ukraine': 'UAH',
    'Poland': 'PLN',
  };

  String? currency = countryToCurrencyMap[country ?? ''];

  return currency ?? 'not set';
}

Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location service is disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied.');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
