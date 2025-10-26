// lib/src/screens/activity_dashboard_wrapper.dart

import 'package:flutter/material.dart';
import 'package:health_nest/src/screens/activity_dashboard_screen.dart';

class ActivityDashboardWrapper extends StatefulWidget {
  const ActivityDashboardWrapper({super.key});

  @override
  State<ActivityDashboardWrapper> createState() =>
      _ActivityDashboardWrapperState();
}

class _ActivityDashboardWrapperState extends State<ActivityDashboardWrapper> {
  final GlobalKey<ActivityDashboardScreenState> _dashboardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.directions_walk, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text(
              'Health Nest',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Reset Button
          IconButton(
            onPressed: () {
              _dashboardKey.currentState?.showResetDialog();
            },
            icon: Icon(Icons.refresh, color: Colors.red.shade600),
            tooltip: 'Reset Daily Steps',
          ),
          // Goal Setting Button
          IconButton(
            onPressed: () {
              _dashboardKey.currentState?.showGoalDialog();
            },
            icon: Icon(Icons.flag, color: Colors.green.shade600),
            tooltip: 'Set Daily Goal',
          ),
          // Premium Lock Icon
          IconButton(
            onPressed: () {
              _dashboardKey.currentState?.showPremiumDialog();
            },
            icon: Icon(Icons.workspace_premium, color: Colors.amber.shade700),
            tooltip: 'Premium Features',
          ),
        ],
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ActivityDashboardScreen(key: _dashboardKey),
    );
  }
}
