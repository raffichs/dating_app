import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:final_tpm/models/user_model.dart';
import 'package:final_tpm/services/user_service.dart';
import 'package:final_tpm/widgets/clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  Map<String, double> userDistances = {};

  // Sensor related variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isTiltEnabled = true;
  double _tiltThreshold = 10; // Sensitivity threshold
  DateTime _lastTiltAction = DateTime.now();
  Duration _tiltCooldown = const Duration(milliseconds: 2000);

  final String baseUrl =
      'https://6842c522e1347494c31de2fd.mockapi.io/api/v1/users';

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _initializeTiltSensor();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _initializeTiltSensor() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_isTiltEnabled || _swipeItems.isEmpty) return;

      // Check cooldown to prevent rapid swipes
      if (DateTime.now().difference(_lastTiltAction) < _tiltCooldown) return;

      // event.x represents left/right tilt
      // Positive x = tilted right, Negative x = tilted left
      if (event.x > _tiltThreshold) {
        // Tilt right - swipe right (like)
        _performTiltSwipe(true);
      } else if (event.x < -_tiltThreshold) {
        // Tilt left - swipe left (dislike)
        _performTiltSwipe(false);
      }
    });
  }

  void _performTiltSwipe(bool isLike) {
    if (_swipeItems.isEmpty) return;

    _lastTiltAction = DateTime.now();

    // Get current card
    // final currentItem = _swipeItems[1];

    // Perform the action
    if (isLike) {
      // currentItem.likeAction?.call();
      _showTiltFeedback("👎 Passed", Colors.red);
      setState(() {
        _matchEngine.currentItem?.nope();
      });
    } else {
      // currentItem.nopeAction?.call();
      _showTiltFeedback("👍 Liked!", Colors.green);
      setState(() {
        _matchEngine.currentItem?.like();
      });
    }
  }

  void _showTiltFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _toggleTiltSensor() {
    setState(() {
      _isTiltEnabled = !_isTiltEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isTiltEnabled ? "Tilt sensor enabled" : "Tilt sensor disabled"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  final currencyExchangeRatesToIDR = {
    // Major currencies (updated with current rates)
    'USD': 16300.0, // Based on 2025 average around 16,459 IDR per USD
    'EUR': 17800.0, // Based on 2025 average around 17,758 IDR per EUR
    'JPY': 110.0,
    'GBP': 20500.0,
    'CHF': 18000.0,
    'AUD': 10800.0,
    'CAD': 12000.0,
    'NZD': 9800.0,

    // Asian currencies
    'CNY': 2250.0,
    'INR': 195.0,
    'KRW': 12.5,
    'SGD': 12100.0,
    'MYR': 3600.0,
    'THB': 460.0,
    'PHP': 285.0,
    'VND': 0.66,
    'PKR': 58.0,
    'BDT': 136.0,
    'LKR': 49.0,
    'MMK': 7.8,
    'KHR': 4.0,
    'LAK': 0.78,
    'MNT': 5.8,
    'KZT': 32.0,
    'UZS': 1.3,
    'TWD': 500.0,
    'HKD': 2100.0,
    'MOP': 2000.0,

    // European currencies
    'TRY': 480.0,
    'RUB': 165.0,
    'PLN': 4000.0,
    'UAH': 390.0,
    'CZK': 680.0,
    'HUF': 42.0,
    'RON': 3500.0,
    'BGN': 9100.0,
    'HRK': 2400.0,
    'RSD': 150.0,
    'BAM': 9100.0,
    'ALL': 175.0,
    'MKD': 290.0,
    'BYN': 4900.0,
    'DKK': 2400.0,
    'SEK': 1550.0,
    'NOK': 1480.0,
    'ISK': 118.0,

    // American currencies
    'BRL': 2700.0,
    'ARS': 16.0,
    'MXN': 800.0,
    'CLP': 16.8,
    'COP': 3.8,
    'PEN': 4300.0,
    'VES': 0.4,
    'UYU': 420.0,
    'PYG': 2.2,
    'BOB': 2350.0,
    'PAB': 16300.0,
    'CRC': 32.0,
    'GTQ': 2100.0,
    'HNL': 660.0,
    'NIO': 440.0,
    'CUP': 680.0,
    'JMD': 105.0,
    'DOP': 270.0,
    'HTG': 122.0,
    'TTD': 2400.0,
    'BBD': 8150.0,

    // African currencies
    'ZAR': 900.0,
    'NGN': 10.3,
    'EGP': 330.0,
    'KES': 126.0,
    'ETB': 130.0,
    'GHS': 1050.0,
    'MAD': 1600.0,
    'DZD': 122.0,
    'TND': 5200.0,
    'LYD': 3350.0,
    'SDG': 27.0,
    'UGX': 4.4,
    'TZS': 6.9,
    'RWF': 12.0,
    'ZMW': 580.0,
    'ZWL': 0.05,
    'BWP': 1200.0,
    'NAD': 900.0,
    'MZN': 255.0,
    'AOA': 13.5,
    'XAF': 26.0, // Central African CFA franc
    'XOF': 26.0, // West African CFA franc
    'CDF': 5.8,

    // Middle Eastern currencies
    'SAR': 4350.0,
    'AED': 4440.0,
    'QAR': 4480.0,
    'KWD': 53000.0,
    'BHD': 43200.0,
    'OMR': 42400.0,
    'JOD': 23000.0,
    'LBP': 1.8,
    'SYP': 0.13,
    'IQD': 12.4,
    'IRR': 0.39,
    'ILS': 4400.0,
    'YER': 65.0,

    // Oceania currencies
    'PGK': 4100.0,
    'FJD': 7200.0,
    'WST': 5900.0,
    'TOP': 6900.0,
    'VUV': 137.0,
    'SBD': 1950.0,
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
                debugPrint("Added like from $currentUserId to ${user.id}");
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
        actions: [
          IconButton(
            icon: Icon(
              _isTiltEnabled
                  ? Icons.screen_rotation
                  : Icons.screen_lock_rotation,
              color: _isTiltEnabled ? Colors.white : Colors.grey,
            ),
            onPressed: _toggleTiltSensor,
            tooltip:
                _isTiltEnabled ? "Disable tilt sensor" : "Enable tilt sensor",
          ),
        ],
      ),
      body: Column(
        children: [
          // Tilt instruction banner
          if (_isTiltEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.deepPurple.withOpacity(0.1),
              child: const Text(
                "📱 Tilt your phone left to pass, right to like!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
            ),

          // Main swipe content
          Expanded(
            child: _swipeItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SwipeCards(
                      matchEngine: _matchEngine,
                      itemBuilder: (context, index) {
                        final user = _swipeItems[index].content as UserModel;
                        final distance = userDistances[user.id] ?? -1;
                        final targetRate =
                            currencyExchangeRatesToIDR[user.currency];

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
                                  backgroundImage:
                                      NetworkImage(user.coverImageUrl),
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
                                    style:
                                        const TextStyle(color: Colors.blueGrey),
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (conversionText != null)
                                      Flexible(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Text(
                                            conversionText,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.teal),
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
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          TimezoneClock(
                                              timezone: user.timezone),
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
                          const SnackBar(
                              content: Text("No more users to show.")),
                        );
                        _isTiltEnabled =
                            false; // Disable tilt when no more cards
                      },
                      upSwipeAllowed: false,
                      fillSpace: true,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
