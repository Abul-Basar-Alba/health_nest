import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider2.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text('HealthNest'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              userProvider.setUser(null);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${userProvider.user?.name ?? 'User'}!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/calculator'),
              child: Text('Go to Calculator'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/nutrition'),
              child: Text('Go to Nutrition'),
            ),
          ],
        ),
      ),
    );
  }
}