import 'package:final_tpm/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  List<UserModel> likedYouUsers = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    loadCurrentUserIdAndFetch();
  }

  Future<void> loadCurrentUserIdAndFetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');

      if (storedUserId == null) {
        debugPrint('No userId found in SharedPreferences');
        setState(() {
          isLoading = false;
        });
        return;
      }

      currentUserId = storedUserId;
      await fetchLikedYouUsers(); // Make sure to await here
    } catch (e) {
      debugPrint('Error in loadCurrentUserIdAndFetch: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLikedYouUsers() async {
    try {
      final users = await UserService.fetchAllUsers();
      debugPrint('Fetched ${users.length} users');
      debugPrint('Current user ID: $currentUserId');

      if (currentUserId == null) {
        throw Exception("Current user ID is null");
      }

      // Find the current user
      final currentUser = users.firstWhere(
        (user) => user.id == currentUserId,
        orElse: () => throw Exception('Current user not found in users list'),
      );

      final likedByIds = currentUser.likedBy ?? [];

      // Filter users whose IDs are in the likedBy array
      final filtered =
          users.where((user) => likedByIds.contains(user.id)).toList();

      setState(() {
        likedYouUsers = filtered;
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Error fetching liked you users: $e');
      debugPrint('$stack');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("They Liked You"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedYouUsers.isEmpty
              ? const Center(child: Text("No one has liked you yet 🥲"))
              : ListView.builder(
                  itemCount: likedYouUsers.length,
                  itemBuilder: (context, index) {
                    final user = likedYouUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user.coverImageUrl),
                        ),
                        title: Text(
                          '${user.username}, ${user.age}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.bio),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                // Remove this user's id from current user's likedBy list
                                setState(() {
                                  likedYouUsers.removeAt(index);
                                });
                                if (currentUserId != null) {
                                  await UserService.removeLikeFromUser(
                                      user.id, currentUserId!);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: Colors.green),
                              onPressed: () async {
                                // simulasi
                                await showMatchNotification(user.username);
                                setState(() {
                                  likedYouUsers.removeAt(index);
                                });
                                if (currentUserId != null) {
                                  await UserService.removeLikeFromUser(
                                      user.id, currentUserId!);
                                } // tampilkan notif
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
