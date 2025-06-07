import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const String baseUrl =
      'https://6842c522e1347494c31de2fd.mockapi.io/api/v1/users';

  static Future<bool> registerUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      // print('Register error: $e');
      return false;
    }
  }

  static Future<List<UserModel>> fetchAllUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  static Future<void> addLikeToUser(
      String targetUserId, String currentUserId) async {
    final url =
        'https://6842c522e1347494c31de2fd.mockapi.io/api/v1/users/$targetUserId';

    // Ambil user target dulu
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Failed to fetch user");

    final data = json.decode(response.body);
    List<String> likedBy = List<String>.from(data['likedBy'] ?? []);

    // Tambahkan like jika belum ada
    if (!likedBy.contains(currentUserId)) {
      likedBy.add(currentUserId);

      // PATCH ke MockAPI
      final patchResponse = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'likedBy': likedBy}),
      );

      if (patchResponse.statusCode != 200) {
        throw Exception("Failed to update likedBy");
      }
    }
  }

  static Future<void> removeLikeFromUser(
      String? targetUserId, String currentUserId) async {
    final url =
        'https://6842c522e1347494c31de2fd.mockapi.io/api/v1/users/$targetUserId';

    // Fetch the target user first
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Failed to fetch user");

    final data = json.decode(response.body);
    List<String> likedBy = List<String>.from(data['likedBy'] ?? []);

    // Remove like if exists
    if (likedBy.contains(currentUserId)) {
      likedBy.remove(currentUserId);

      // PATCH to MockAPI
      final patchResponse = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'likedBy': likedBy}),
      );

      if (patchResponse.statusCode != 200) {
        throw Exception("Failed to update likedBy");
      }
    }
  }
}
