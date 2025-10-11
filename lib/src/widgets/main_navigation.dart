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
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Dashboard',
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_filled, size: 28),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Activity',
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_fire_department_rounded, size: 28),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Exercises',
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center_rounded, size: 28),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Messages',
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.chat_bubble_rounded, size: 28),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Community',
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people_rounded, size: 28),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'AI Coach',
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 28),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Profile',
              child: Icon(Icons.person_rounded),
            ),
            label: '',
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
