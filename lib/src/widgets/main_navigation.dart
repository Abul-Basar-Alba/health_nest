// health_nest/lib/src/widgets/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:health_nest/src/screens/dashboard_screen.dart';
import 'package:health_nest/src/screens/activity_dashboard_screen.dart'; // New: Activity Dashboard
import 'package:health_nest/src/screens/exercise_screen.dart'; // New: Exercise Screen
import 'package:health_nest/src/screens/community_screen.dart';
import 'package:health_nest/src/screens/recommendation_screen.dart';
import 'package:health_nest/src/screens/profile_screen.dart'; // Import Profile Screen
import 'package:health_nest/src/screens/messaging/chat_list_screen.dart'; // Import Messaging Screen

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const ActivityDashboardScreen(), // New: Activity Dashboard Screen
    const ExerciseScreen(), // New: Exercise Screen
    const ChatListScreen(), // New: Messaging Screen
    const CommunityScreen(),
    const RecommendationScreen(),
    const ProfileScreen(), // New: Profile Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk_rounded), // Activity Tracker
            label: 'Activity',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded), // Exercise Library
            label: 'Exercises',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded), // Messaging icon
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Community',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt_rounded),
            label: 'AI Coach',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), // Profile icon
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
