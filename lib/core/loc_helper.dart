import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Mengembalikan alamat dalam format "Kota, Negara"
Future<String> getCurrentLocationString() async {
  Position position = await _determinePosition();

  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  Placemark place = placemarks[0];
  return "${place.administrativeArea}, ${place.country}";
}

/// Mengembalikan Position (latitude dan longitude)
Future<Position> getCurrentLatLng() async {
  return await _determinePosition();
}

/// Fungsi internal: Cek izin dan ambil posisi
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
