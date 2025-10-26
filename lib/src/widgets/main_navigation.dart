// health_nest/lib/src/widgets/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/screens/admin_contact_screen.dart';
import 'package:health_nest/src/screens/admin_dashboard_screen.dart';
import 'package:health_nest/src/screens/calculator_screen.dart';
import 'package:health_nest/src/screens/community_screen.dart';
import 'package:health_nest/src/screens/documentation_screen.dart';
import 'package:health_nest/src/screens/exercise_screen.dart';
import 'package:health_nest/src/screens/history/history_screen.dart';
import 'package:health_nest/src/screens/home_screen.dart';
import 'package:health_nest/src/screens/messaging/chat_list_screen.dart';
import 'package:health_nest/src/screens/profile_screen.dart';
import 'package:health_nest/src/screens/recommendation_screen.dart';
import 'package:health_nest/src/screens/step_counter_dashboard_screen.dart';
import 'package:health_nest/src/services/admin_service.dart';
import 'package:provider/provider.dart';

// Simple Draggable FAB for MainNavigation
class _DraggableFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  const _DraggableFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  @override
  _DraggableFABState createState() => _DraggableFABState();
}

class _DraggableFABState extends State<_DraggableFAB>
    with TickerProviderStateMixin {
  Offset _position = const Offset(300, 400);
  bool _isVisible = true;
  bool _showCloseButton = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    _position = Offset(screenWidth - 84, screenHeight - 180);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to show FAB from external calls
  void showFAB() {
    if (mounted) {
      setState(() {
        _isVisible = true;
        _showCloseButton = false;
      });
    }
  }

  void _onTap() {
    if (_showCloseButton) {
      widget.onPressed?.call();
      setState(() => _showCloseButton = false);
    } else {
      setState(() => _showCloseButton = true);
      _animationController
          .forward()
          .then((_) => _animationController.reverse());
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _showCloseButton) {
          setState(() => _showCloseButton = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show small indicator when hidden that can be tapped to restore
    if (!_isVisible) {
      return Positioned(
        right: 20,
        bottom: 120,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isVisible = true;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade300.withOpacity(0.8),
                  Colors.red.shade300.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: _onTap,
        onPanUpdate: (details) {
          setState(() => _position += details.delta);
        },
        onPanEnd: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          setState(() {
            _position = Offset(
              _position.dx.clamp(20, screenWidth - 84),
              _position.dy.clamp(100, screenHeight - 180),
            );
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade500,
                          Colors.deepOrange.shade600,
                          Colors.red.shade400,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          spreadRadius: 3,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        if (_showCloseButton)
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.6),
                            spreadRadius: 6,
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _showCloseButton
                              ? Icons.play_arrow_rounded
                              : Icons.local_fire_department_rounded,
                          color: widget.foregroundColor ?? Colors.white,
                          size: 28,
                        ),
                        if (_showCloseButton)
                          Positioned(
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LOG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_showCloseButton)
              Positioned(
                right: -8,
                top: -8,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isVisible = false;
                    _showCloseButton = false; // Reset close button state
                    // No auto re-show - only manual control
                  }),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final GlobalKey<_DraggableFABState> _fabKey = GlobalKey<_DraggableFABState>();

  // Main 5 screens for bottom navigation
  final List<Widget> _mainScreens = <Widget>[
    const HomeScreen(), // 🏠 Home - Modern animated home screen
    const RecommendationScreen(), // 🧠 AI Coach
    const ExerciseScreen(), // 🏋️ Workouts
    const CommunityScreen(), // 👥 Community
    const ProfileScreen(), // 👤 Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Navigation to drawer screens
  void _navigateToScreen(Widget screen) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (context) => screen),
    )
        .then((result) {
      // When returning from activity page, show FAB again
      if (screen is StepCounterDashboardScreen) {
        _fabKey.currentState?.showFAB();

        // If result is a tab index, switch to that tab
        if (result is int && result >= 0 && result < 5) {
          setState(() {
            _selectedIndex = result;
          });
        }
      }
    });
  }

  // Navigation to drawer screens by route
  void _navigateToDrawerScreen(String route) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/Lucid_Origin_A_premium_modern_and_minimalist_3D_app_logo_for_H_0.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'HealthNest',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      drawer: _buildNavigationDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _mainScreens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );

    // Return scaffold with overlay
    return Stack(
      children: [
        scaffold,
        _DraggableFAB(
          key: _fabKey,
          onPressed: () {
            _navigateToScreen(const StepCounterDashboardScreen());
          },
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          tooltip: 'Step Counter',
          child: const Icon(Icons.directions_walk),
        ),
      ],
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'HealthNest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your AI Health Assistant',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.chat_bubble_outline,
            title: 'Messages',
            onTap: () => _navigateToScreen(const ChatListScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.directions_walk,
            title: 'Step Counter',
            onTap: () => _navigateToScreen(const StepCounterDashboardScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.history,
            title: 'History',
            onTap: () => _navigateToScreen(const HistoryScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.calculate_outlined,
            title: 'Health Calculator',
            onTap: () => _navigateToScreen(const CalculatorScreen()),
          ),
          const Divider(thickness: 1),
          _buildDrawerItem(
            icon: Icons.star_outline,
            title: 'Premium Services',
            onTap: () => _navigateToDrawerScreen('/premium-services'),
          ),
          _buildDrawerItem(
            icon: Icons.description_outlined,
            title: 'Documentation',
            onTap: () => _navigateToScreen(const DocumentationScreen()),
          ),
          _buildDrawerItem(
            icon: Icons.contact_support_outlined,
            title: 'Contact Admin',
            onTap: () => _navigateToScreen(const AdminContactScreen()),
          ),

          // 🔒 SECURE Admin Panel - শুধুমাত্র authorized admin emails
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return FutureBuilder<bool>(
                future: AdminService.isCurrentUserAdmin(),
                builder: (context, adminSnapshot) {
                  final isAdmin = adminSnapshot.data ?? false;

                  return FutureBuilder<bool>(
                    future: AdminService.canBecomeAdmin(),
                    builder: (context, canBecomeAdminSnapshot) {
                      final canBecomeAdmin =
                          canBecomeAdminSnapshot.data ?? false;

                      if (isAdmin) {
                        // Already admin - show admin tools
                        return Column(
                          children: [
                            const Divider(thickness: 1),
                            _buildDrawerItem(
                              icon: Icons.admin_panel_settings_rounded,
                              title: 'User & Payment Management',
                              onTap: () => _navigateToScreen(
                                  const AdminDashboardScreen()),
                            ),
                            _buildDrawerItem(
                              icon: Icons.cloud,
                              title: 'Firebase Console',
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed('/vscode-firebase-manager');
                              },
                            ),
                          ],
                        );
                      } else if (canBecomeAdmin) {
                        // Authorized email but not admin yet
                        return Column(
                          children: [
                            const Divider(thickness: 1),
                            _buildDrawerItem(
                              icon: Icons.security_rounded,
                              title: 'Enable Admin Access',
                              onTap: () async {
                                Navigator.of(context).pop();
                                final success =
                                    await AdminService.makeCurrentUserAdmin();
                                if (success && context.mounted) {
                                  await userProvider.refreshUser();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🎉 Admin access granted!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      } else {
                        // Unauthorized - no admin options
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              );
            },
          ),

          const Divider(thickness: 1),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              // Navigate to settings
              Navigator.of(context).pop();
            },
          ),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // Show about dialog
              Navigator.of(context).pop();
              _showAboutDialog();
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // Handle logout
              Navigator.of(context).pop();
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green.shade600,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? Colors.green.shade100
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home, size: 24),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 1
                    ? Colors.green.shade100
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, size: 24),
            ),
            label: 'AI Coach',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 2
                    ? Colors.green.shade100
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, size: 24),
            ),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 3
                    ? Colors.green.shade100
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.group, size: 24),
            ),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedIndex == 4
                    ? Colors.green.shade100
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, size: 24),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About HealthNest'),
          content: const Text(
            'HealthNest is an AI-powered health tracking application designed to help you achieve your wellness goals through personalized insights and community support.',
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle actual logout logic here
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}
