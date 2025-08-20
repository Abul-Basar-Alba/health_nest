import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This example fetches a dummy user for demonstration
    // In a real app, you would pass the user ID and fetch data from Firestore
    final user = UserModel(
      id: 'dummy_id',
      name: 'John Doe',
      email: 'john.doe@example.com',
      isPremium: true,
      profileImageUrl: 'https://via.placeholder.com/150',
      isProfilePublic: true,
      height: 175.0,
      weight: 70.0,
      bmi: 22.86,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.name}\'s Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                  user.profileImageUrl ?? 'https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user.isProfilePublic ? 'Public Profile' : 'Private Profile',
              style: TextStyle(
                  color: user.isProfilePublic ? Colors.green : Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow('Email', user.email),
                    const Divider(),
                    if (user.isProfilePublic)
                      _buildInfoRow('Height', '${user.height ?? 'N/A'} cm'),
                    if (user.isProfilePublic) const Divider(),
                    if (user.isProfilePublic)
                      _buildInfoRow('Weight', '${user.weight ?? 'N/A'} kg'),
                    if (user.isProfilePublic) const Divider(),
                    if (user.isProfilePublic)
                      _buildInfoRow(
                          'BMI', user.bmi?.toStringAsFixed(2) ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Logic to start a new chat with this user
                // Navigator.pushNamed(context, '/chat', arguments: {'otherUserId': user.id});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Starting a chat with ${user.name}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
