// health_nest/lib/src/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isStandardUser = userProvider.user?.isPremium == false;
    final bool isAdmin = userProvider.user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userProvider.user?.name ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _buildGrid(context, isStandardUser, isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isStandardUser, bool isAdmin) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // Exercise button
        _buildDashboardButton(
          context,
          title: 'Exercise',
          icon: Icons.run_circle_rounded,
          color: Colors.lightGreen.shade600,
          onTap: () => Navigator.pushNamed(context, '/exercise'),
        ),
        // Step Count button
        _buildDashboardButton(
          context,
          title: 'Step Counter',
          icon: Icons.directions_walk_rounded,
          color: Colors.blue.shade600,
          onTap: () => Navigator.pushNamed(context, '/step-count'),
        ),
        // Messaging button
        _buildDashboardButton(
          context,
          title: 'Messaging',
          icon: Icons.message_rounded,
          color: Colors.teal.shade600,
          onTap: () => Navigator.pushNamed(context, '/chat-list'),
        ),
        // History button
        _buildDashboardButton(
          context,
          title: 'History',
          icon: Icons.history,
          color: Colors.brown.shade600,
          onTap: () => Navigator.pushNamed(context, '/history'),
        ),
        // Calculator button
        _buildDashboardButton(
          context,
          title: 'Calculator',
          icon: Icons.calculate_rounded,
          color: Colors.purple.shade600,
          onTap: () => Navigator.pushNamed(context, '/calculator'),
        ),
        // Community button
        _buildDashboardButton(
          context,
          title: 'Community',
          icon: Icons.groups_rounded,
          color: Colors.pink.shade600,
          onTap: () => Navigator.pushNamed(context, '/community'),
        ),
        // Nutrition button
        _buildDashboardButton(
          context,
          title: 'Nutrition',
          icon: Icons.fastfood_rounded,
          color: Colors.orange.shade600,
          onTap: () => Navigator.pushNamed(context, '/nutrition'),
        ),
        // Recommendations button
        _buildDashboardButton(
          context,
          title: 'Recommendations',
          icon: Icons.lightbulb_rounded,
          color: Colors.green.shade600,
          onTap: () => Navigator.pushNamed(context, '/recommendations'),
        ),

        // Progress Tracker button
        _buildDashboardButton(
          context,
          title: 'Progress Tracker',
          icon: Icons.show_chart_rounded,
          color: Colors.indigo.shade600,
          onTap: () => Navigator.pushNamed(context, '/progress-tracker'),
        ),

        // Conditional button for Admin/User
        if (isAdmin)
          _buildDashboardButton(
            context,
            title: 'Admin Panel',
            icon: Icons.admin_panel_settings_rounded,
            color: Colors.red.shade600,
            onTap: () => Navigator.pushNamed(context, '/admin-panel'),
          ),
        if (!isAdmin)
          _buildDashboardButton(
            context,
            title: 'Contact Admin',
            icon: Icons.email_rounded,
            color: Colors.red.shade600,
            onTap: () => Navigator.pushNamed(context, '/admin-contact'),
          ),

        if (isStandardUser)
          _buildDashboardButton(
            context,
            title: 'Paid Services',
            icon: Icons.workspace_premium_rounded,
            color: Colors.amber.shade600,
            onTap: () => Navigator.pushNamed(context, '/paid-services'),
          ),
        if (isStandardUser)
          _buildDashboardButton(
            context,
            title: 'Documentation',
            icon: Icons.menu_book_rounded,
            color: Colors.teal.shade600,
            onTap: () => Navigator.pushNamed(context, '/documentation'),
          ),
      ],
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
