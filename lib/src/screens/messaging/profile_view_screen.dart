import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';

class ProfileViewScreen extends StatelessWidget {
  final UserModel user;
  const ProfileViewScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Access the current user from the UserProvider
    final currentUserProvider = Provider.of<UserProvider>(context);
    final currentUserId = currentUserProvider.user?.id;

    if (currentUserId == null) {
      // Handle the case where the current user is not logged in
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('Please log in to view profiles.'),
        ),
      );
    }

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
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback to a default icon on image load error
                debugPrint('Error loading image for user: ${user.name}');
              },
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
                final chatProvider =
                    Provider.of<ChatProvider>(context, listen: false);
                final chatId = chatProvider.getChatId(currentUserId!, user.id);

                // Navigate to the ChatScreen with the required arguments
                Navigator.pushNamed(context, '/chat', arguments: {
                  'chatId': chatId,
                  'otherUserId': user.id,
                });
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
