import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashHelper {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password); // ubah ke byte array
    final digest = sha256.convert(bytes); // hash pakai SHA256
    return digest.toString(); // hasil dalam bentuk string hex
  }
}