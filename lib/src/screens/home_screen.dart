import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut() async {
    if (!mounted) return;
    final authService = AuthService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await authService.signOut();
    if (!mounted) return;
    userProvider.setUser(null);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthNest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${userProvider.user?.name ?? 'User'}!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/calculator'),
              child: const Text('Go to Calculator'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/nutrition'),
              child: const Text('Go to Nutrition'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/exercise'),
              child: const Text('Go to Step Counter'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/history'),
              child: const Text('View History'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/feedback'),
              child: const Text('Get Feedback'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
