import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/screens/community_screen.dart';
import 'package:health_nest/src/screens/dashboard_screen.dart';
import 'package:health_nest/src/screens/documentation_screen.dart';
import 'package:health_nest/src/screens/paid_services_screen.dart';
import 'package:health_nest/src/screens/recommendation_screen.dart';
import 'package:provider/provider.dart';

// Import all your screen widgets here

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    CommunityScreen(),
    RecommendationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isStandardUser = !(userProvider.user?.isPremium ?? false);

    // Conditionally add screens to the list
    final List<Widget> navScreens = [..._widgetOptions];
    if (isStandardUser) {
      navScreens.add(const PaidServicesScreen());
    }

    // You can add DocumentationScreen here if it's for everyone, or only for premium.
    // Based on your last request, it was for standard users.
    if (isStandardUser) {
      navScreens.add(const DocumentationScreen());
    }

    return Scaffold(
      body: Center(
        child: navScreens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Community',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt_rounded),
            label: 'AI Coach',
          ),
          if (isStandardUser)
            const BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_rounded),
              label: 'Premium',
            ),
          if (isStandardUser)
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Docs',
            ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
      ),
    );
  }
}
