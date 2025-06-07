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
    // Asia
    'Indonesia': 'IDR',
    'Japan': 'JPY',
    'China': 'CNY',
    'India': 'INR',
    'South Korea': 'KRW',
    'Thailand': 'THB',
    'Philippines': 'PHP',
    'Malaysia': 'MYR',
    'Singapore': 'SGD',
    'Vietnam': 'VND',
    'Pakistan': 'PKR',
    'Bangladesh': 'BDT',
    'Sri Lanka': 'LKR',
    'Myanmar': 'MMK',
    'Cambodia': 'KHR',
    'Laos': 'LAK',
    'Mongolia': 'MNT',
    'Kazakhstan': 'KZT',
    'Uzbekistan': 'UZS',
    'Taiwan': 'TWD',
    'Hong Kong': 'HKD',
    'Macau': 'MOP',

    // Europe
    'Germany': 'EUR',
    'France': 'EUR',
    'Italy': 'EUR',
    'Spain': 'EUR',
    'Netherlands': 'EUR',
    'United Kingdom': 'GBP',
    'Switzerland': 'CHF',
    'Sweden': 'SEK',
    'Norway': 'NOK',
    'Denmark': 'DKK',
    'Russia': 'RUB',
    'Poland': 'PLN',
    'Ukraine': 'UAH',
    'Turkey': 'TRY', // Handle both Turkey and Türkiye
    'Türkiye': 'TRY',
    'Czech Republic': 'CZK',
    'Hungary': 'HUF',
    'Romania': 'RON',
    'Bulgaria': 'BGN',
    'Croatia': 'HRK',
    'Serbia': 'RSD',
    'Bosnia and Herzegovina': 'BAM',
    'Albania': 'ALL',
    'North Macedonia': 'MKD',
    'Belarus': 'BYN',
    'Finland': 'EUR',
    'Austria': 'EUR',
    'Belgium': 'EUR',
    'Luxembourg': 'EUR',
    'Portugal': 'EUR',
    'Greece': 'EUR',
    'Ireland': 'EUR',
    'Iceland': 'ISK',

    // Americas
    'United States': 'USD',
    'Canada': 'CAD',
    'Mexico': 'MXN',
    'Brazil': 'BRL',
    'Argentina': 'ARS',
    'Chile': 'CLP',
    'Colombia': 'COP',
    'Peru': 'PEN',
    'Venezuela': 'VES',
    'Uruguay': 'UYU',
    'Paraguay': 'PYG',
    'Bolivia': 'BOB',
    'Ecuador': 'USD',
    'Panama': 'PAB',
    'Costa Rica': 'CRC',
    'Guatemala': 'GTQ',
    'Honduras': 'HNL',
    'Nicaragua': 'NIO',
    'El Salvador': 'USD',
    'Cuba': 'CUP',
    'Jamaica': 'JMD',
    'Dominican Republic': 'DOP',
    'Haiti': 'HTG',
    'Trinidad and Tobago': 'TTD',
    'Barbados': 'BBD',

    // Africa
    'South Africa': 'ZAR',
    'Nigeria': 'NGN',
    'Egypt': 'EGP',
    'Kenya': 'KES',
    'Ethiopia': 'ETB',
    'Ghana': 'GHS',
    'Morocco': 'MAD',
    'Algeria': 'DZD',
    'Tunisia': 'TND',
    'Libya': 'LYD',
    'Sudan': 'SDG',
    'Uganda': 'UGX',
    'Tanzania': 'TZS',
    'Rwanda': 'RWF',
    'Zambia': 'ZMW',
    'Zimbabwe': 'ZWL',
    'Botswana': 'BWP',
    'Namibia': 'NAD',
    'Mozambique': 'MZN',
    'Angola': 'AOA',
    'Cameroon': 'XAF',
    'Ivory Coast': 'XOF',
    'Senegal': 'XOF',
    'Mali': 'XOF',
    'Burkina Faso': 'XOF',
    'Niger': 'XOF',
    'Chad': 'XAF',
    'Central African Republic': 'XAF',
    'Republic of the Congo': 'XAF',
    'Democratic Republic of the Congo': 'CDF',
    'Gabon': 'XAF',
    'Equatorial Guinea': 'XAF',

    // Middle East
    'Saudi Arabia': 'SAR',
    'United Arab Emirates': 'AED',
    'Qatar': 'QAR',
    'Kuwait': 'KWD',
    'Bahrain': 'BHD',
    'Oman': 'OMR',
    'Jordan': 'JOD',
    'Lebanon': 'LBP',
    'Syria': 'SYP',
    'Iraq': 'IQD',
    'Iran': 'IRR',
    'Israel': 'ILS',
    'Yemen': 'YER',

    // Oceania
    'Australia': 'AUD',
    'New Zealand': 'NZD',
    'Papua New Guinea': 'PGK',
    'Fiji': 'FJD',
    'Samoa': 'WST',
    'Tonga': 'TOP',
    'Vanuatu': 'VUV',
    'Solomon Islands': 'SBD',
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
