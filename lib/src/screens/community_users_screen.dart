// lib/src/screens/community_users_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import 'messaging/chat_screen.dart';

class CommunityUsersScreen extends StatefulWidget {
  const CommunityUsersScreen({super.key});

  @override
  State<CommunityUsersScreen> createState() => _CommunityUsersScreenState();
}

class _CommunityUsersScreenState extends State<CommunityUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Community Members'),
        ),
        body: const Center(
          child: Text('Please login to view community'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Members'),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  const Text('Error loading community members'),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter out current user and apply search
          var users = snapshot.data!.docs.where((doc) {
            if (doc.id == currentUser.id)
              return false; // Don't show current user

            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();

            if (_searchQuery.isEmpty) return true;
            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }).toList();

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No community members yet'
                        : 'No users found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Users will appear here'
                        : 'Try a different search',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final userId = userDoc.id;
              final userName = userData['name'] ?? 'Unknown User';
              final userEmail = userData['email'] ?? '';
              final isPremium = userData['isPremium'] ?? false;
              final profileImageUrl = userData['profileImageUrl'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal[100],
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              )
                            : null,
                      ),
                      if (isPremium)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    color: Colors.teal,
                    onPressed: () {
                      final chatProvider =
                          Provider.of<ChatProvider>(context, listen: false);
                      final chatId =
                          chatProvider.getChatId(currentUser.id, userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            otherUserId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Show user profile or details
                    _showUserProfile(context, userId, userData);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserProfile(
      BuildContext context, String userId, Map<String, dynamic> userData) {
    final userName = userData['name'] ?? 'Unknown User';
    final userEmail = userData['email'] ?? 'No email';
    final isPremium = userData['isPremium'] ?? false;
    final age = userData['age'];
    final gender = userData['gender'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal[100],
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (isPremium)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium Member',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (age != null || gender != null) ...[
              const Divider(),
              const SizedBox(height: 12),
              if (age != null)
                Row(
                  children: [
                    Icon(Icons.cake, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text('Age: $age'),
                  ],
                ),
              const SizedBox(height: 8),
              if (gender != null)
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text('Gender: $gender'),
                  ],
                ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final chatProvider =
                      Provider.of<ChatProvider>(context, listen: false);
                  final currentUser =
                      Provider.of<UserProvider>(context, listen: false).user;
                  if (currentUser != null) {
                    final chatId =
                        chatProvider.getChatId(currentUser.id, userId);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          otherUserId: userId,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.message),
                label: const Text('Start Conversation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
