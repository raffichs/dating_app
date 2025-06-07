import 'package:flutter/material.dart';
import '../pages/profile_page.dart';
import '../pages/match_page.dart';
import '../pages/like_page.dart';
import '../pages/feedback_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    ProfilePage(),
    MatchPage(),
    LikePage(),
    FeedbackPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Match'),
    BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'Likes'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Kesan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
      ),
    );
  }
}
