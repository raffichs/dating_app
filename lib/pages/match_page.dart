import 'dart:convert';
import 'dart:math';

import 'package:final_tpm/models/user_model.dart';
import 'package:final_tpm/services/user_service.dart';
import 'package:final_tpm/widgets/clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:http/http.dart' as http;

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  Map<String, double> userDistances = {};

  final String baseUrl =
      'https://6842c522e1347494c31de2fd.mockapi.io/api/v1/users';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  final currencyExchangeRatesToIDR = {
    'USD': 16000.0,
    'EUR': 17000.0,
    'JPY': 110.0,
    'GBP': 20000.0,
    'TRY': 500.0,
    'KRW': 12.0,
    'CNY': 2200.0,
    'MYR': 3500.0,
    'SGD': 12000.0,
    'VND': 0.65,
    'THB': 450.0,
    'PHP': 280.0,
    'AUD': 10500.0,
    'CAD': 11700.0,
    'INR': 190.0,
  };

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedInUserId = prefs.getString('userId');
      final currentUserLat = prefs.getDouble('lat');
      final currentUserLng = prefs.getDouble('lng');
      debugPrint("Current user location: $currentUserLat, $currentUserLng");

      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<UserModel> users = data
            .map((json) => UserModel.fromJson(json))
            .where((user) => user.id != loggedInUserId)
            .toList();

        userDistances.clear(); // reset jarak sebelumnya

        for (var user in users) {
          if (currentUserLat != null && currentUserLng != null) {
            final distance = calculateDistance(
                currentUserLat, currentUserLng, user.lat, user.lng);
            userDistances[user.id!] = distance;
          } else {
            userDistances[user.id!] = -1; // -1 jika tidak bisa dihitung
          }
        }

        _swipeItems = users.map((user) {
          return SwipeItem(
            content: user,
            likeAction: () async {
              final currentUserId = prefs.getString('userId');
              if (currentUserId != null && user.id != null) {
                await UserService.addLikeToUser(user.id!, currentUserId);
                debugPrint("Liked ${user.username}");
              }
            },
            nopeAction: () {
              debugPrint("Disliked ${user.username}");
            },
          );
        }).toList();

        setState(() {
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
        });
      } else {
        debugPrint("Failed to load users: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _swipeItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (context, index) {
                  // final prefs = SharedPreferences.getInstance();
                  // final loggedInCurrency = prefs.getString('userId');
                  final user = _swipeItems[index].content as UserModel;
                  final distance = userDistances[user.id] ?? -1;
                  final targetRate = currencyExchangeRatesToIDR[user.currency];

                  String? conversionText;
                  if (targetRate != null && targetRate > 0) {
                    conversionText =
                        "Your ${targetRate.toStringAsFixed(0)} IDR means 1 ${user.currency} for them";
                  }
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(user.coverImageUrl),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${user.username}, ${user.age}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(user.country,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          if (distance >= 0)
                            Text(
                              "${distance.toStringAsFixed(2)} km away",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (conversionText != null)
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      conversionText,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.teal),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user.timezone,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    TimezoneClock(timezone: user.timezone),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.bio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onStackFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No more users to show.")),
                  );
                },
                upSwipeAllowed: false,
                fillSpace: true,
              ),
            ),
    );
  }
}
