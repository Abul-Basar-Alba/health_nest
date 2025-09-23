import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../constants/app_strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  // Use a Stream to listen for real-time changes in the users collection
  Stream<QuerySnapshot>? _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view the community.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          // Filter out the current user from the list
          final otherUsers = snapshot.data!.docs
              .where((doc) => doc.id != currentUser.id)
              .toList();

          if (otherUsers.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final userDoc = otherUsers[index];
              final userModel = UserModel.fromFirestore(userDoc);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(userModel.profileImageUrl ??
                        'https://via.placeholder.com/150'),
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to a default icon on image load error
                      debugPrint(
                          'Error loading image for user: ${userModel.name}');
                    },
                  ),
                  title: Text(
                    userModel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(userModel.email),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () {
                    // Navigate to the ProfileViewScreen for the selected user
                    Navigator.pushNamed(context, '/profile-view',
                        arguments: userModel);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
